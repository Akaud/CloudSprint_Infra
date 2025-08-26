module "my_app_ecr" {
  source          = "../../modules/ecr"
  repository_name = "my-app-repo-${var.ENV}"
  tags = {
    Environment = var.ENV
  }
}

module "s3" {
  source        = "../../modules/s3"
  bucket_name   = "myproject-dev-bucket-${var.ENV}"
  lifecycle_days = 30
  tags = {
    Environment = var.ENV
  }
}

module "ecs" {
  source    = "../../modules/ecs"
  repo_url = module.my_app_ecr.repository_url
  tags = {
      Environment = var.ENV
   }
}