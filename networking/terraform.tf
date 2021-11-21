terraform {
  required_version  = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.4.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-notedwin"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "cloudflare" {
  email = var.CLOUDFLARE_EMAIL
  api_token = var.CLOUDFLARE_API_TOKEN
  api_user_service_key = var.api_user_service_key
}

data "aws_caller_identity" "current" {}
