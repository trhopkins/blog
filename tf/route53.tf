resource "aws_route53_zone" "primary" {
  name = "camphopkins.com"
}

resource "aws_route53_record" "root_a_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name = var.domain_name
  type = "A"
  alias {
    name = aws_cloudfront_distribution.s3.domain_name
    zone_id = aws_cloudfront_distribution.s3.hosted_zone_id
    evaluate_target_health = false
  }
}

# resource "aws_route53_record" "site_cert_dns" {
#   allow_overwrite = true
#   name = aws_acm_certificate.site_certificate.domain_name
# }

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.site_certificate.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = aws_route53_zone.primary.id
}

# resource "aws_route53_record" "site_cert_dns" {
#   allow_overwrite = true
#   name            = tolist(aws_acm_certificate.site_certificate.domain_validation_options)[0].resource_record_name
#   records         = [tolist(aws_acm_certificate.site_certificate.domain_validation_options)[0].resource_record_value]
#   type            = tolist(aws_acm_certificate.site_certificate.domain_validation_options)[0].resource_record_type
#   zone_id         = var.route53_zone_id
#   ttl             = 60
# }
