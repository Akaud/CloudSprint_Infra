# Use existing VPC provided by team
data "aws_vpc" "existing" {
  id = "vpc-030d14759050848aa" # Use provided VPC
}

# Private subnet for Aurora and ECS
resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.existing.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.AWS_REGION}a"

  tags = {
    Name = "private-subnet-${var.ENV}"
  }
}

# Public subnet for ALB (if needed later)
resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.existing.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.AWS_REGION}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${var.ENV}"
  }
}
