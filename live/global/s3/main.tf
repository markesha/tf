provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state444a4"
    region = "us-east-1"
    key = "global/s3/terraform.tfstate"
    encrypt = true
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state444a4"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
