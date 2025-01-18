terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "camp-hopkins-tf-state"
    dynamodb_table = "camp-hopkins-tf-lock"
    encrypt        = true
    key            = "terraform.tfstate"
    # access_key     = var.access_key
    # secret_key     = var.secret_key
    region         = "us-east-1"
  }
}

module "camp-hopkins-static-site" {
  bucket_name      = "camp-hopkins-content-bucket"
  cf_dist_name     = "camp-hopkins-cf"
  path_to_bundle   = "../dist"
  project_name     = "camp-hopkins"
  root_domain_name = "camphopkins.com"
  source           = "./modules/static-site"
}

module "terraform-be" {
  secret_key = var.secret_key
  access_key = var.access_key
  bucket_name          = "camp-hopkins-tf-state"
  dynamodb_name        = "camp-hopkins-tf-lock"
  enable_state_locking = true
  project_name         = "camp-hopkins"
  region               = "us-east-1"
  source               = "./modules/backend"
}

