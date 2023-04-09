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

