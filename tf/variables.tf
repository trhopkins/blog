variable "domain_name" {
  type        = string
  description = "The domain name for the website"
}

variable "access_key" {
  type        = string
  description = "Access key to AWS console for terraform user"
}

variable "secret_key" {
  type        = string
  description = "Secret key to AWS console"
}

variable "aws_region" {
  type        = string
  description = "AWS Region to deploy in"
  default = "us-east-1"
}

