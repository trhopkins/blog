/**
*  Looks up the hosted zone based on the zone name
*  Only retrives the data if the custom_domain variable is provided
**/
data "aws_route53_zone" "hosted_zone" {
  count = var.root_domain_name != "" ? 1 : 0
  name         = var.root_domain_name
  private_zone = false
}

// Get an SSL/TLS cert for the specified domain
resource "aws_acm_certificate" "site_cert" {
  count = var.root_domain_name != "" ? 1 : 0

  domain_name               = var.root_domain_name
  subject_alternative_names = ["www.${var.root_domain_name}"] // creates root and sub-domain i.e. example.com and www.example.com
  validation_method         = "DNS"
  # validation_method         = "EMAIL"
  lifecycle {
    create_before_destroy = true // if cert already exists, create the new one before destroying the old one
  }

  tags = local.acm_cert_tags
}

// Creates Route53 alias records for the root domain and maps it to the Cloudfront domain name
resource "aws_route53_record" "root_domain" {
  count   = var.root_domain_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.hosted_zone[0].id
  name    = var.root_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

// Creates Route53 alias records for the www subdomain and maps it to the Cloudfront domain name
resource "aws_route53_record" "www" {
  count   = var.root_domain_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.hosted_zone[0].id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

// Create Route 53 DNS records for ACM certificate validation
resource "aws_route53_record" "cert_validation_record" {
  // Create records for the domain and all sub-domains 
  for_each = var.root_domain_name != "" ? {
    for dvo in aws_acm_certificate.site_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60 // DNS records cached for 60 seconds before re-requesting
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone[0].id
}


// Validate ACM certificates
resource "aws_acm_certificate_validation" "cert_validation" {
  count = var.root_domain_name != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.site_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn] // list of FQDNs that implement the validation
}

