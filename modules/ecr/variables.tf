variable "repository_name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "scan_on_push" {
  description = "Indicates whether to scan images on push."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the ECR repository."
  type        = map(string)
  default     = {}
}