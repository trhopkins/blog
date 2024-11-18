resource "aws_s3_bucket" "blog" {
	bucket = "camphopkins-xyz-terraform"
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.blog.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "blog" {
  for_each = fileset("html/", "*")
  bucket = aws_s3_bucket.blog.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "blog" {
  for_each = fileset("html/", "*")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "html/${each.value}"
  etag = filemd5("html/${each.value}")
  content_type = "text/html"
}

