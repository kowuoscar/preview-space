provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "capstone-bootstrap-s3" {
  bucket = "capstone-bootstrap-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "Capstone Bootstrap Bucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "capstone-bootstrap-dynamodb" {
  name           = "CapstoneBootstrapLockTable-${data.aws_caller_identity.current.account_id}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "capstone-bootstrap-dynamodb"
    Environment = "Dev"
  }
}