variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-east-1"
}

variable "lifecycle_days" {
  description = "Number of days before moving media to Intelligent-Tiering"
  type        = number
  default     = 30
}

variable "enable_public_access" {
  description = "Enable public access block (set to false for public buckets)"
  type        = bool
  default     = true
}

variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "enable_public_read" {
  description = "Enable public read access (for static websites)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
