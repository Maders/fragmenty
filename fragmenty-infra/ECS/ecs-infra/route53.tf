resource "aws_route53_zone" "fragmenty" {
  name = var.custom_domain
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.custom_domain
  validation_method = "DNS"

  tags = {
    Name = "Fragmenty_TLS_Cert"
  }

  lifecycle {
    create_before_destroy = true
  }
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

resource "aws_route53_record" "cert_validation" {

  depends_on = [aws_route53_record.fragmenty]

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.fragmenty.id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.fragmenty.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn


  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}
