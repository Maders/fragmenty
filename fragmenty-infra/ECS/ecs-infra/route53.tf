resource "aws_route53_zone" "fragmenty" {
  name = var.custom_domain
}

resource "aws_route53_record" "fragmenty" {
  zone_id = aws_route53_zone.fragmenty.id
  name    = var.custom_domain
  type    = "A"

  alias {
    name                   = aws_lb.fragmenty.dns_name
    zone_id                = aws_lb.fragmenty.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.custom_domain
  validation_method = "DNS"

  tags = {
    Terraform = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  depends_on = [aws_route53_zone.fragmenty]

  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.fragmenty.id
  ttl     = 60
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]

}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

