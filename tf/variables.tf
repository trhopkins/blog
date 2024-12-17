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
}

# variable "bucket_name" {
#   type        = string
#   description = "Bucket name without the www. prefix, normally domain_name"
# }

# variable "acm_certificate_arn" {
#   type        = string
#   description = "ARN of the ACM certificate for domain_name"
# }

# variable "route53_zone_id" {
#   type        = string
#   description = "ID of the Route 53 zone"
# }

