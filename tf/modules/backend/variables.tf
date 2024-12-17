variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Terraform State Bucket Name"
  type        = string
}

variable "enable_state_locking" {
  description = "Whether to create the DynamoDB table for state locking"
  type        = bool
  default     = false
}

variable "dynamodb_name" {
  description = "Terraform Locking DB Name"
  type        = string
  default     = null
}

variable "aws_profile" {
  description = "AWS Account to use"
  type        = string
}

variable "project_name" {
  description = "The project name that will be applied to tags"
  type        = string
}

