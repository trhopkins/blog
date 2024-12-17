resource "aws_s3_bucket" "web_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = local.web_bucket_tags
}

resource "aws_s3_bucket_versioning" "web_bucket_versioning" {
  bucket = aws_s3_bucket.web_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket        = "${var.project_name}-cf-logs"
  force_destroy = true
  tags          = local.web_bucket_tags
}

resource "aws_s3_bucket_ownership_controls" "cloudfront-logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# // Allow all origins
# resource "aws_s3_bucket_cors_configuration" "web_bucket_cors_config" {
#   bucket = aws_s3_bucket.web_bucket.id
#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "HEAD"]
#     allowed_origins = ["*"]
#   }
# }

# // Objects in S3 are server-side encrypted
# resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_sse" {
#   bucket = aws_s3_bucket.web_bucket.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#   bucket     = aws_s3_bucket.web_bucket.id
#   acl        = "private"
#   depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
# }

# # Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
# resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
#   bucket = aws_s3_bucket.web_bucket.id
#   rule {
#     object_ownership = "ObjectWriter"
#   }
# }

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.web_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = data.aws_iam_policy_document.web_s3_policy.json
}

# // upload FE bundle to S3
# resource "aws_s3_object" "uploaded_files" {
#   bucket = aws_s3_bucket.web_bucket.id
#   for_each = fileset(var.path_to_bundle, "**/*.*")
#   key      = each.value
#   source   = "${var.path_to_bundle}/${each.value}"
#   etag     = filemd5("${var.path_to_bundle}/${each.value}")
#   # map content type based on file extension TODO CLEAN UP THIS IS A BIT MESSY
#   content_type        = lookup(var.content_types, ".${element(split(".", each.value), 1)}", "application/octet-stream")
#   content_disposition = "inline"
# }

resource "aws_s3_object" "blog_contents" {
  bucket              = aws_s3_bucket.web_bucket.id
  for_each            = fileset(var.path_to_bundle, "**/*.*")
  key                 = replace(each.value, var.path_to_bundle, "")
  source              = "${var.path_to_bundle}/${each.value}"
  etag                = filemd5("${var.path_to_bundle}/${each.value}")
  content_type        = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
  # content_disposition = "inline"
}

