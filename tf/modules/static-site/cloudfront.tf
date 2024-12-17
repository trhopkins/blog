resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for Cloudfront"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = var.default_root_object
  tags                = local.cf_distribution_tags
  price_class         = var.cf_price_class
  aliases = var.root_domain_name != "" ? [
    var.root_domain_name,
    "www.${var.root_domain_name}"
  ] : []

  logging_config {
    include_cookies = false
    # bucket = "${var.bucket_name}-cf-logs.amazonaws.com"
    bucket = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix = "cf-logs"
  }

  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    # origin_access_control_id = aws_cloudfront_origin_access_control.site-oac.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    # cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
    target_origin_id       = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    viewer_protocol_policy = "redirect-to-https"

    # These TTL's are typical for SPA's. Adjust to meet caching needs accordingly
    # See below link to learn more about cloudfront caching behavior
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Expiration.html#ExpirationDownloadDist
    # Minimum time to cache a file is 0 seconds
    min_ttl = 0
    # Default caching TTL = 1 Day
    default_ttl = var.cf_ttl
    # Max caching TTL = 1 year
    max_ttl = 60 * 60 * 24 * 365
    # Compress static file to reduce bandwidth
    compress = true
    forwarded_values {

      query_string = false
      ## For CORS
      headers = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin", "Access-Control-Allow-Origin"]
      cookies {
        # Prevent cloudfront from caching things based on cookies as these are going to change with the hashed object. 
        # Setting this to 'none' allows cloudfront to properly cache values and prevent errors and misses.
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Add our cert for https
  viewer_certificate {
    acm_certificate_arn            = var.root_domain_name != "" ? aws_acm_certificate.site_cert[0].arn : null // Add certs for custom domain name, else none
    ssl_support_method             = "sni-only"
    # minimum_protocol_version       = "TLSv1.2_2018"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = var.root_domain_name != "" ? false : true // use default cert if we do not provide one
  }

  # Uncomment following block if caching becomes too sticky
  # This block disallows caching index.html only, which will force cloudfront to reach for new html and app version on every request, which may fix caching issues
  # ordered_cache_behavior {
  #   path_pattern     = "/index.html"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id       = aws_s3_bucket.web_bucket.bucket_regional_domain_name
  #   forwarded_values {
  #     query_string = false

  #       forward = "none"
  #     }
  #   }
  #   min_ttl                = 0
  #   default_ttl            = 0
  #   max_ttl                = 0
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  #   custom_error_response {
  #     error_caching_min_ttl = 300
  #     error_code            = 403
  #     response_code         = 200
  #     response_page_path    = "/index.html"
  #   }

  #   custom_error_response {
  #     error_caching_min_ttl = 300
  #     error_code            = 404
  #     response_code         = 200
  #     response_page_path    = "/index.html"
  #   }
}

# resource "aws_cloudfront_origin_access_control" "site-oac" {
#   name = "s3-cloudfront-oac"
#   origin_access_control_origin_type = "s3"
#   signing_behavior = "always"
#   signing_protocol = "sigv4"
# }

