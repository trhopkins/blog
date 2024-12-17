locals {
  web_bucket_tags = {
    Name        = var.bucket_name
    environment = var.env
    project     = var.project_name
  }

  cf_distribution_tags = {
    Name        = var.cf_dist_name
    environment = var.env
    project     = var.project_name
  }

  acm_cert_tags = {
    project     = var.project_name
    environment = var.env
  }
}

