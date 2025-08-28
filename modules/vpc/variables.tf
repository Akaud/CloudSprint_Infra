variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}

variable "ENV" {
  type = string
}

variable "AWS_REGION" {
  type = string
}