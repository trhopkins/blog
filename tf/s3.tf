resource "aws_s3_bucket" "blog" {
	bucket = "camphopkins-xyz"
}

resource "aws_s3_bucket_versioning" "blog" {
  bucket = aws_s3_bucket.blog.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "blog_contents_js" {
  for_each = fileset("../html/public/", "**.js")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "application/javascript"
}

resource "aws_s3_object" "blog_contents_ico" {
  for_each = fileset("../html/public/", "**.ico")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "image/x-icon"
}

resource "aws_s3_object" "blog_contents_png" {
  for_each = fileset("../html/public/", "**.png")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "image/png"
}

resource "aws_s3_object" "blog_contents_svg" {
  for_each = fileset("../html/public/", "**.svg")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "blog_contents_xml" {
  for_each = fileset("../html/public/", "**.xml")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "text/xml"
}

resource "aws_s3_object" "blog_contents_css" {
  for_each = fileset("../html/public/", "**.css")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_object" "blog_contents_html" {
  for_each = fileset("../html/public/", "**.html")
  bucket = aws_s3_bucket.blog.id
  key = each.value
  source = "../html/public/${each.value}"
  etag = filemd5("../html/public/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "blog_config" {
  bucket = aws_s3_bucket.blog.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "blog_config" {
  for_each = fileset("../html/public/", "*")
  bucket = aws_s3_bucket.blog.id
  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "blog_config" {
  bucket = aws_s3_bucket.blog.id
  policy = data.aws_iam_policy_document.allow_public_s3_access.json
}

data "aws_iam_policy_document" "allow_public_s3_access" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [ format("%s/*", aws_s3_bucket.blog.arn) ]
  }
  statement {
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::531782379741:user/tf"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [ format("%s/*", aws_s3_bucket.blog.arn) ]
  }
}

