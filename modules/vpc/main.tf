resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "team3-cloud-sprint-vpc-${var.ENV}"
    Environment = var.ENV
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.AWS_REGION

  tags = {
    Name = "private-subnet-${var.ENV}"
  }
}
