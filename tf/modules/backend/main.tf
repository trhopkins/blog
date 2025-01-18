terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket        = var.bucket_name
  tags          = local.tags
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

// Conditionally creates state locking table
resource "aws_dynamodb_table" "tf_locks" {
  count        = var.enable_state_locking ? 1 : 0
  name         = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  tags         = local.tags
  attribute {
    name = "LockID"
    type = "S"
  }
}

