variable "vpc_id" {
  description = "VPC ID where ECS resources will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "team3-cluster"
}

variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
  default     = "team3-cluster-task"
}

variable "container_image" {
  description = "Docker image to run in ECS"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU units for the Fargate task"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Memory (in MB) for the Fargate task"
  type        = string
  default     = "1024"
}

variable "tags" {
  description = "Tags to apply to the ECS service"
  type        = map(string)
  default     = {}
}

variable "repo_url" {
  type        = string
  description = "link to ecr"
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy"
  default     = "latest"
}
