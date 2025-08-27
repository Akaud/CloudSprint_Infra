terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket  = "team3-terraform-backend-2025aug"
    key     = "infra.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}


provider "aws" {
  region  = var.AWS_REGION
  profile = "dev-mfa"
}