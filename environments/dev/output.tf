# S3 Bucket Outputs
output "wagtail_static_site_bucket_name" {
  description = "Name of the wagtail static site bucket"
  value       = module.wagtail_static_site.bucket_name
}

output "wagtail_static_site_website_endpoint" {
  description = "Website endpoint for wagtail static site"
  value       = module.wagtail_static_site.website_endpoint
}

output "wagtail_static_site_cloudfront_url" {
  description = "CloudFront URL for wagtail static site"
  value       = module.wagtail_static_site.cloudfront_url
}

output "wagtail_media_bucket_name" {
  description = "Name of the wagtail media bucket"
  value       = module.wagtail_media.bucket_name
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.my_app_ecr.repository_url
}
