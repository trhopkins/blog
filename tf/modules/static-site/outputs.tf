output "bucket_id" {
  description = "Bucket ID for s3 holding our website files"
  value       = aws_s3_bucket.web_bucket.id
}

output "cloudfront_domain_name" {
  description = "Cloudfront domain name"
  value       = aws_cloudfront_distribution.cf_distribution.domain_name
}

output "cloudfront_dist_id" {
  description = "Cloudfront distribution id"
  value       = aws_cloudfront_distribution.cf_distribution.id
}

