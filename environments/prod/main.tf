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

module "ecs" {
  source   = "../../modules/ecs"
  repo_url = module.my_app_ecr.repository_url
  tags = {
    Environment = var.ENV
  }
}

module "aurora" {
  source             = "../../modules/aurora_dsql"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags = {
    Environment = var.ENV
  }
}

module "vpc" {
  source = "../../modules/vpc"
  ENV    = var.ENV
  tags = {
    Environment = var.ENV
  }
}