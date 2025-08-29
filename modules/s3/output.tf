output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "website_endpoint" {
  description = "Website endpoint for the S3 bucket (if static website hosting is enabled)"
  value       = var.enable_static_website ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain for the S3 bucket (if static website hosting is enabled)"
  value       = var.enable_static_website ? aws_s3_bucket_website_configuration.this[0].website_domain : null
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name (if static website hosting is enabled)"
  value       = var.enable_static_website ? aws_cloudfront_distribution.static_site[0].domain_name : null
}

output "cloudfront_url" {
  description = "CloudFront distribution URL (if static website hosting is enabled)"
  value       = var.enable_static_website ? "https://${aws_cloudfront_distribution.static_site[0].domain_name}" : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (if static website hosting is enabled)"
  value       = var.enable_static_website ? aws_cloudfront_distribution.static_site[0].id : null
}