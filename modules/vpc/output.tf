output "vpc_id" {
  description = "The ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "private_subnet_ids" {
  description = "List of existing private subnet IDs"
  value       = data.aws_subnets.private.ids
}

output "public_subnet_ids" {
  description = "List of existing public subnet IDs"
  value       = data.aws_subnets.public.ids
}

output "private_subnet_cidrs" {
  description = "List of existing private subnet CIDR blocks"
  value       = [for subnet in data.aws_subnet.private : subnet.cidr_block]
}

output "public_subnet_cidrs" {
  description = "List of existing public subnet CIDR blocks"
  value       = [for subnet in data.aws_subnet.public : subnet.cidr_block]
}