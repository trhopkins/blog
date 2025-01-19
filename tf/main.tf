terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "camphopkins-tf-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    # dynamodb_table = "camphopkins-tf-lock"
    encrypt = true
    profile = "terraform"
  }
}

module "camphopkins-static-site" {
  source           = "./modules/static-site"
  project_name     = "camphopkins"
  bucket_name      = "camphopkins-content-bucket"
  cf_dist_name     = "camphopkins-cf"
  root_domain_name = "camphopkins.com"
  path_to_bundle   = "../dist"
}

# module "terraform-be" {
#   source               = "./modules/backend"
#   region               = "us-east-1"
#   aws_profile          = "terraform"
#   bucket_name          = "camphopkins-tf-state"
#   project_name         = "camphopkins"
#   enable_state_locking = true
#   dynamodb_name        = "camphopkins-tf-lock"
# }

