# Wagtail static site bucket
module "wagtail_static_site" {
  source                = "../../modules/s3"
  bucket_name           = "wagtail-static-site-${var.ENV}"
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

# Wagtail media files bucket
module "wagtail_media" {
  source                = "../../modules/s3"
  bucket_name           = "wagtail-media-${var.ENV}"
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
