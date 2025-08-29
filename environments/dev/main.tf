module "my_app_ecr" {
  source          = "../../modules/ecr"
  repository_name = "team3-cloud-sprint-${var.ENV}"
  tags = {
    Environment = var.ENV
  }
}

module "wagtail_static_site" {
  source                = "../../modules/s3"
  bucket_name           = "wagtail-static-site-${var.ENV}-${random_string.bucket_suffix.result}"
  region                = var.AWS_REGION
  lifecycle_days        = 30
  enable_public_access  = true
  enable_static_website = true
  enable_public_read    = true
  tags = {
    Environment = var.ENV
    Purpose     = "wagtail-static-site"
  }
}

module "wagtail_media" {
  source                = "../../modules/s3"
  bucket_name           = "wagtail-media-${var.ENV}-${random_string.bucket_suffix.result}"
  region                = var.AWS_REGION
  lifecycle_days        = 30
  enable_public_access  = true
  enable_static_website = false
  enable_public_read    = true
  tags = {
    Environment = var.ENV
    Purpose     = "wagtail-media"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "vpc" {
  source     = "../../modules/vpc"
  ENV        = var.ENV
  AWS_REGION = var.AWS_REGION
  tags = {
    Environment = var.ENV
  }
}

module "ecs" {
  source   = "../../modules/ecs"
  vpc_id   = module.vpc.vpc_id
  repo_url = module.my_app_ecr.repository_url
  tags = {
    Environment = var.ENV
  }
}

module "aurora" {
  source                 = "../../modules/aurora_dsql"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ecs_security_group_ids = [module.ecs.security_group_id]
  tags = {
    Environment = var.ENV
  }
}

output "cloudfront_url" {
  description = "CloudFront distribution URL"
  value       = module.wagtail_static_site.cloudfront_url
}

# Outputs for GitHub Actions pipeline
output "static_bucket_name" {
  description = "Name of the static S3 bucket"
  value       = module.wagtail_static_site.bucket_name
}

output "media_bucket_name" {
  description = "Name of the media S3 bucket"
  value       = module.wagtail_media.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.wagtail_static_site.cloudfront_distribution_id
}

        # IAM module for GitHub Actions - temporarily commented out due to permissions
        # module "iam" {
        #   source = "../../modules/iam"
        # 
        #   environment                = var.ENV
        #   aws_account_id            = "597765856364"  # Your AWS Account ID
        #   github_repository         = "Akaud/CloudSprint_Infra"  # Your actual repository
        #   s3_static_bucket_name     = module.wagtail_static_site.bucket_name
        #   s3_media_bucket_name      = module.wagtail_media.bucket_name
        #   cloudfront_distribution_id = module.wagtail_static_site.cloudfront_distribution_id
        # 
        #   tags = {
        #     Environment = var.ENV
        #     Purpose     = "github-actions"
        #   }
        # }

        # Outputs for GitHub Actions user - temporarily commented out due to permissions
        # output "github_actions_user_arn" {
        #   description = "ARN of the GitHub Actions IAM user"
        #   value       = module.iam.github_actions_user_arn
        # }
        # 
        # output "github_actions_access_key_id" {
        #   description = "Access Key ID for GitHub Actions"
        #   value       = module.iam.github_actions_access_key_id
        #   sensitive   = true
        # }
        # 
        # output "github_actions_secret_access_key" {
        #   description = "Secret Access Key for GitHub Actions"
        #   value       = module.iam.github_actions_secret_access_key
        #   sensitive   = true
        # }