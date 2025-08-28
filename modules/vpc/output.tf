output "vpc_id" {
  description = "The ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "private_subnet_ids" {
  description = "A list of the private subnet IDs"
  value       = [aws_subnet.private.id]
}
