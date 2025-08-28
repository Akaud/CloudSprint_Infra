output "vpc_id" {
  description = "The ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public.id]
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = [aws_subnet.private_a.cidr_block, aws_subnet.private_b.cidr_block]
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = [aws_subnet.public.cidr_block]
}