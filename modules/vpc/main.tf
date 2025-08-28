# Use existing VPC provided by team
data "aws_vpc" "existing" {
  id = "vpc-030d14759050848aa"  # Use provided VPC
}

# Use existing private subnets instead of creating new ones
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# Use existing public subnets instead of creating new ones
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Get subnet details for outputs
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}
