terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "preview-space-452183714072"
    region = "eu-west-1"
    key = "terraform/10-cluster"
    dynamodb_table = "PreviewSpaceStateLockTable-452183714072"
    encrypt = true
  }
}