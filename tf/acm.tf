resource "aws_acm_certificate" "site_certificate" {
  # provider = aws.us-east-1
  domain_name = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.site_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

# may not be needed?
# resource "aws_acm_certificate_validation" "site_certificate" {
#   provider = aws.us-east-1
#   certificate_arn = aws_acm_certificate.site_certificate.arn
#   validation_record_fqdns = [aws_route53_record.root_a_record.fqdn]
# }

