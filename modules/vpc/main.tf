# Use existing VPC provided by team
data "aws_vpc" "existing" {
  id = "vpc-030d14759050848aa" # Use provided VPC
}

# Private subnet for Aurora and ECS
resource "aws_subnet" "private_a" {
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.AWS_REGION}a"

  tags = {
    Name = "private-subnet-${var.ENV}-a"
  }
}

# Private subnet for Aurora and ECS in AZ 'b'
resource "aws_subnet" "private_b" {
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = "10.0.7.0/24" # Use a new, non-conflicting CIDR block
  availability_zone = "${var.AWS_REGION}b"

  tags = {
    Name = "private-subnet-${var.ENV}-b"
  }
}

# Public subnet for ALB (if needed later)
resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.existing.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.ENV}"
  }
}
