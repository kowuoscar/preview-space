provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "preview-space-s3" {
  bucket = "preview-space-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Preview Space Bucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "preview-space-dynamodb" {
  name           = "PreviewSpaceStateLockTable-${data.aws_caller_identity.current.account_id}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "preview-space-dynamodb"
    Environment = "Dev"
  }
}