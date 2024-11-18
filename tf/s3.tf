resource "aws_s3_bucket" "bucket" {
	bucket = "camphopkins-xyz-1234567890"
}

resource "aws_s3_object" "blog_contents" {
  for_each = fileset("../html/", "*")
  bucket = aws_s3_bucket.bucket.id
  key = each.value
  source = "../html/${each.value}"
  etag = filemd5("../html/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "blog_config" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_config" {
  for_each = fileset("../html/", "*")
  bucket = aws_s3_bucket.bucket.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "blog_config" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_public_s3_access.json
}

data "aws_iam_policy_document" "allow_public_s3_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [ format("%s/*", aws_s3_bucket.bucket.arn) ]
  }
}

