locals {
  s3_origin_id = "s3bucketaccess"
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = local.s3_origin_id
}

resource "aws_cloudfront_distribution" "s3" {
  origin {
    # origin_access_control_id = aws_cloudfront_origin_access_identity.oai.id
    # origin_id = local.s3_origin_id
    domain_name = aws_s3_bucket.blog.bucket_regional_domain_name
    origin_id = aws_s3_bucket.blog.bucket_regional_domain_name
    s3_origin_config {
      # origin_access_identity = aws_cloudfront_origin_access_identity.oai.id
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
    # custom_origin_config {
    #   http_port = 80
    #   https_port = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Camp Hopkins personal blog"
  default_root_object = "index.html"
  aliases             = [var.domain_name]
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    # viewer_protocol_policy = "https-only"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    compress = true
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # acm_certificate_arn      = aws_acm_certificate.site_certificate.arn
    acm_certificate_arn      = aws_acm_certificate.site_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
    cloudfront_default_certificate = false
  }
}

