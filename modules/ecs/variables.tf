variable "tags" {
  description = "Tags to apply to the ECS service"
  type        = map(string)
  default     = {}
}
