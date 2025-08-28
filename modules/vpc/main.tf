# Create new VPC in eu-west-2 (London)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "team3-cloudsprint-vpc-${var.ENV}"
    Environment = var.ENV
  }
}

# Private subnet for Aurora and ECS
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.AWS_REGION}a"

  tags = {
    Name = "private-subnet-${var.ENV}"
  }
}

# Public subnet for ALB (if needed later)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.ENV}"
  }
}
