output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.foo.name
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.foo.arn
}

output "task_definition" {
  description = "Task definition ARN (family:revision)"
  value       = aws_ecs_task_definition.app.arn
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "service_desired_count" {
  description = "Initial desired task count (before autoscaling)"
  value       = aws_ecs_service.app.desired_count
}

output "security_group_id" {
  description = "Security group used by ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "vpc_id" {
  description = "VPC used by the service"
  value       = data.aws_vpc.main.id
}

output "subnet_ids" {
  description = "Subnets where tasks can run"
  value       = data.aws_subnets.main.ids
}
