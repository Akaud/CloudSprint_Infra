variable "vpc_id" {
  description = "The ID of the VPC where the database will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the database will be placed."
  type        = list(string)
}

variable "db_name" {
  description = "The name for the database and its resources."
  type        = string
  default     = "cloudsprint-app-db"
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
}