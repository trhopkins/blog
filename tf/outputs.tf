output "s3_bucket_id" {
  value = aws_s3_bucket_website_configuration.blog_config.website_endpoint
}

output "policy" {
  value = aws_s3_bucket_policy.blog_config.policy
}

