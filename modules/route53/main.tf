## data zone
data "aws_route53_zone" "domain" {
  name = var.domain
}

## data acm certificate
data "aws_acm_certificate" "acm" {
  domain = var.domain
}

## A record
resource "aws_route53_record" "domain" {
    zone_id = data.aws_route53_zone.domain.zone_id
    name = var.domain
    type = "A"

    alias {
        name = var.alb.dns_name
        zone_id = var.alb.zone_id
        evaluate_target_health = false
    }
}