terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 5.0"
		}
	}
  backend "s3" {
    bucket = "camphopkins-xyz-terraform"
    key = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "camphopkins-xyz-state-lock"
  }
}

provider "aws" {
	region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

