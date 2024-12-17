resource "aws_s3_bucket" "blog" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "blog" {
  bucket = aws_s3_bucket.blog.id
  versioning_configuration {
    status = "Enabled"
  }
}

variable "upload_dir" {
  default = "../hugo/public"
}

variable "mime_types" {
  default = {
    css  = "text/css"
    htm  = "text/html"
    html = "text/html"
    xml  = "text/xml"
    gif  = "image/gif"
    ico  = "image/x-icon"
    jpeg = "image/jpeg"
    png  = "image/png"
    svg  = "image/svg"
    svg  = "image/svg+xml"
    ttf  = "font/ttf"
    js   = "application/javascript"
    json = "application/json"
    map  = "application/javascript"
    pdf  = "application/pdf"
  }
}

resource "aws_s3_object" "blog_contents" {
  bucket              = aws_s3_bucket.blog.id
  for_each            = fileset(var.upload_dir, "**/*.*")
  key                 = replace(each.value, var.upload_dir, "")
  source              = "${var.upload_dir}/${each.value}"
  etag                = filemd5("${var.upload_dir}/${each.value}")
  content_type        = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
  content_disposition = "inline"
}

resource "aws_s3_bucket_website_configuration" "blog_config" {
  bucket = aws_s3_bucket.blog.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "blog_config" {
  # bucket = aws_s3_bucket.blog.bucket
  bucket = aws_s3_bucket.blog.id
  cors_rule {
    # allowed_headers = ["Authorization", "Content-Length"]
    # allowed_methods = ["GET", "POST"]
    # allowed_origins = ["https://${var.domain_name}"]
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket     = aws_s3_bucket.blog.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_acl_ownership" {
  bucket = aws_s3_bucket.blog.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_config" {
  for_each                = fileset("../hugo/public/", "*")
  bucket                  = aws_s3_bucket.blog.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "blog_config" {
  bucket = aws_s3_bucket.blog.id
  policy = data.aws_iam_policy_document.allow_public_s3_access.json
}

data "aws_iam_policy_document" "allow_public_s3_access" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.blog.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.oai.iam_arn}"]
    }
  }
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.blog.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::531782379741:user/tf"]
    }
  }
  statement {
    # actions = ["s3:ListObject"]
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.blog.arn}"]
    principals {
      type = "AWS"
      # identifiers = ["arn:aws:iam::531782379741:user/tf"]
      identifiers = ["${aws_cloudfront_origin_access_identity.oai.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.blog.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${var.domain_name}"]
    max_age_seconds = 3000
  }
}

