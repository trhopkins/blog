terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "camphopkins-tf-state"
    # dynamodb_table = "camphopkins-tf-lock"
    encrypt        = true
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

module "camphopkins-static-site" {
  bucket_name      = "camphopkins-content-bucket"
  cf_dist_name     = "camphopkins-cf"
  path_to_bundle   = "../dist"
  project_name     = "camphopkins"
  root_domain_name = "camphopkins.com"
  source           = "./modules/static-site"
}

module "terraform-be" {
  secret_key           = var.secret_key
  access_key           = var.access_key
  bucket_name          = "camphopkins-tf-state"
  dynamodb_name        = "camphopkins-tf-lock"
  enable_state_locking = false
  project_name         = "camphopkins"
  source               = "./modules/backend"
}
