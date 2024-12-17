output "bucket_name" {
  description = "S3 Bucket name for tf state file"
  value       = aws_s3_bucket.tf_state_bucket.id
}

output "dynamodb_name" {
  description = "DynamoDB table name for tf state locking"
  value       = var.enable_state_locking ? aws_dynamodb_table.tf_locks[0].id : null
}

