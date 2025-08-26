variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "lifecycle_days" {
  description = "Number of days before moving media to Intelligent-Tiering"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
