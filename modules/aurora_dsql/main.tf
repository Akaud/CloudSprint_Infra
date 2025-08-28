locals {
  db_identifier = var.db_name
  db_proxy_name = "${replace(local.db_identifier, "_", "-")}-proxy"
}

# Random string for unique resource names
resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${replace(local.db_identifier, "_", "-")}-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "A subnet group for the PostgreSQL database."
}

resource "aws_security_group" "db_security_group" {
  name        = "${replace(local.db_identifier, "_", "-")}-sg"
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

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()_+-=[]{}|:?"
}

# DB Cluster Parameter Group for Aurora PostgreSQL
resource "aws_rds_cluster_parameter_group" "postgres_cluster_parameter_group" {
  name   = "${replace(local.db_identifier, "_", "-")}-cluster-parameter-group"
  family = "aurora-postgresql13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = var.tags
}

# Add IAM role for enhanced monitoring
resource "aws_iam_role" "monitoring_role" {
  name = "${local.db_identifier}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

# Attach policy to the monitoring role
resource "aws_iam_role_policy_attachment" "monitoring_policy_attachment" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_rds_cluster" "postgres_cluster" {
  cluster_identifier              = replace(local.db_identifier, "_", "-")
  engine                          = "aurora-postgresql"
  engine_version                  = "13.9"
  engine_mode                     = "provisioned"  # Changed to provisioned - serverless not available in eu-west-1
  database_name                   = local.db_identifier
  master_username                 = var.db_username
  master_password                 = random_password.db_password.result
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.db_security_group.id]
  backup_retention_period         = 1
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgres_cluster_parameter_group.name
  skip_final_snapshot             = false
  storage_encrypted               = true
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring_role.arn

  tags = var.tags
}

# Aurora instance for provisioned mode
resource "aws_rds_cluster_instance" "postgres_instance" {
  identifier         = "${replace(local.db_identifier, "_", "-")}-instance"
  cluster_identifier = aws_rds_cluster.postgres_cluster.id
  instance_class     = "db.r5.large"  # Supported instance class for Aurora PostgreSQL
  engine             = "aurora-postgresql"
  engine_version     = "13.9"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  auto_minor_version_upgrade = true
  publicly_accessible = false

  tags = var.tags
}

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${replace(local.db_identifier, "_", "-")}-secret-${random_string.unique_suffix.result}"
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
  name = "${replace(local.db_identifier, "_", "-")}-proxy-role-${random_string.unique_suffix.result}"
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

# IAM role for RDS monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${replace(local.db_identifier, "_", "-")}-monitoring-role-${random_string.unique_suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_proxy" "db_proxy" {
  name                  = local.db_proxy_name
  engine_family         = "POSTGRESQL"
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  vpc_subnet_ids        = var.private_subnet_ids
  role_arn              = aws_iam_role.db_proxy_role.arn
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
