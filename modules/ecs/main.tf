locals {
  image_uri = "${var.repo_url}:${var.image_tag}"
}

resource "aws_ecs_cluster" "foo" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# Use VPC ID passed as variable instead of default VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  # Filter for public subnets (for ALB/ECS)
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# --------------------------------------------------------------------------------
# NEW RESOURCES FOR APPLICATION LOAD BALANCER
# --------------------------------------------------------------------------------

# ALB Security Group: This security group allows incoming HTTP traffic on port 80.
# The security group will be attached to the ALB itself.
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = data.aws_vpc.main.id

  # Ingress rule to allow all HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ALB itself
resource "aws_lb" "main" {
  name               = "${var.cluster_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.main.ids

  tags = var.tags
}

# ALB Target Group: The target group is where the ALB sends traffic.
# ECS Fargate tasks with `awsvpc` network mode use `target_type = "ip"`.
resource "aws_lb_target_group" "app" {
  name        = "${var.cluster_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  # Health check configuration to ensure the ALB only sends traffic to healthy tasks
  health_check {
    healthy_threshold   = 3
    interval            = 30
    protocol            = "HTTP"
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = var.tags
}

# ALB Listener: The listener checks for connection requests and forwards them to a target group.
# This listener listens on port 80 and forwards to our `app` target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# --------------------------------------------------------------------------------
# MODIFIED RESOURCES
# --------------------------------------------------------------------------------

# ECS Task Security Group: Now, this security group should only allow traffic from the ALB.
# The public access is now handled by the ALB, not directly on the tasks.
resource "aws_security_group" "ecs_tasks" {
  name   = "ecs-tasks-sg"
  vpc_id = data.aws_vpc.main.id

  # Ingress rule to only allow traffic from the ALB's security group
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.cluster_name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name  = "app"
    image = local.image_uri

    essential    = true
    portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
  }])

  tags = var.tags
}

# ECS Service: The `load_balancer` block is added and the `assign_public_ip` is set to `false`.
resource "aws_ecs_service" "app" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.foo.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    # The tasks are placed in private subnets, but the ALB will be in the public ones.
    subnets         = data.aws_subnets.main.ids
    security_groups = [aws_security_group.ecs_tasks.id]
    # Set this to false since traffic is now routed through the ALB.
    assign_public_ip = false
  }

  # This block attaches the service to the ALB target group.
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app" # Must match the container name in the task definition
    container_port   = var.container_port
  }

  tags = var.tags
}
