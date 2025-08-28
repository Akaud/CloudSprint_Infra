locals {
  db_identifier = var.db_name
  db_proxy_name = "${local.db_identifier}-proxy"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${local.db_identifier}-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "A subnet group for the PostgreSQL database."
}

resource "aws_security_group" "db_security_group" {
  name        = "${local.db_identifier}-sg"
  description = "Security group for the PostgreSQL database"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Allow traffic from ECS security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.ecs_security_group_ids
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_parameter_group" "postgres_parameter_group" {
  name   = "${local.db_identifier}-parameter-group"
  family = "aurora-postgresql13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()_+-=[]{}|:?"
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier              = local.db_identifier
  engine                          = "aurora-postgresql"
  engine_version                  = "13.9"
  engine_mode                     = "serverless"
  database_name                   = local.db_identifier
  master_username                 = var.db_username
  master_password                 = random_password.db_password.result
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.db_security_group.id]
  backup_retention_period         = 1
  db_cluster_parameter_group_name = aws_db_parameter_group.postgres_parameter_group.name
  skip_final_snapshot             = false

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2.0
  }

  scaling_configuration {
    auto_pause               = true
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  monitoring_interval = 60
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${local.db_identifier}-secret"
  description = "DB credentials for RDS Proxy"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    "username" : var.db_username,
    "password" : random_password.db_password.result
  })
}

resource "aws_iam_role" "db_proxy_role" {
  name = "${local.db_identifier}-proxy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "db_proxy_policy_attachment" {
  role       = aws_iam_role.db_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_db_proxy" "db_proxy" {
  name                   = local.db_proxy_name
  engine_family          = "POSTGRESQL"
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  vpc_subnet_ids         = var.private_subnet_ids
  role_arn               = aws_iam_role.db_proxy_role.arn
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.db_secret.arn
  }
  require_tls = true
}

resource "aws_db_proxy_target" "db_proxy_target" {
  db_proxy_name         = aws_db_proxy.db_proxy.name
  db_cluster_identifier = aws_rds_cluster.postgres_cluster.id
  target_group_name     = "default"
}
