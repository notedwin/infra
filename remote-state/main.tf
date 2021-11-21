provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-notedwin"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# don't need locking