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
  default = "../html/public"
}

variable "mime_types" {
  default = {
    htm  = "text/html"
    html = "text/html"
    css  = "text/css"
    xml  = "text/xml"
    svg  = "image/svg+xml"
    png  = "image/png"
    ico  = "image/x-icon"
    jpeg = "image/jpeg"
    svg  = "image/svg"
    ttf  = "font/ttf"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
  }
}

resource "aws_s3_object" "blog_contents" {
  for_each = fileset(var.upload_dir, "**/*.*")
  bucket   = aws_s3_bucket.blog.id
  key      = replace(each.value, var.upload_dir, "")
  source   = "${var.upload_dir}/${each.value}"
  # acl = "public-read"
  etag         = filemd5("${var.upload_dir}/${each.value}")
  content_type = lookup(var.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
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
  bucket = aws_s3_bucket.blog.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_public_access_block" "blog_config" {
  for_each                = fileset("../html/public/", "*")
  bucket                  = aws_s3_bucket.blog.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "blog_config" {
  bucket = aws_s3_bucket.blog.id
  policy = data.aws_iam_policy_document.allow_public_s3_access.json
}

data "aws_iam_policy_document" "allow_public_s3_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [format("%s/*", aws_s3_bucket.blog.arn)]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::531782379741:user/tf"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [format("%s/*", aws_s3_bucket.blog.arn)]
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

