############################################
# Route53 Zone (root)
############################################
data "aws_route53_zone" "root" {
  name         = "${var.root_domain}."
  private_zone = false
}

############################################
# ACM: Landing (shaqserver.com)
############################################
resource "aws_acm_certificate" "landing" {
  domain_name       = var.root_domain
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "landing_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.landing.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.root.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "landing" {
  certificate_arn         = aws_acm_certificate.landing.arn
  validation_record_fqdns = [for r in aws_route53_record.landing_cert_validation : r.fqdn]
}

############################################
# ACM: Additional app subdomains
############################################
resource "aws_acm_certificate" "meowmart" {
  domain_name       = "${var.additional_subdomains[0]}.${var.root_domain}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "meowmart_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.meowmart.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.root.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "meowmart" {
  certificate_arn         = aws_acm_certificate.meowmart.arn
  validation_record_fqdns = [for r in aws_route53_record.meowmart_cert_validation : r.fqdn]
}

############################################
# ACM: Slide (custom subdomain)
############################################
resource "aws_acm_certificate" "slide" {
  domain_name       = "${var.additional_subdomains[1]}.${var.root_domain}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "slide_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.slide.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.root.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "slide" {
  certificate_arn         = aws_acm_certificate.slide.arn
  validation_record_fqdns = [for r in aws_route53_record.slide_cert_validation : r.fqdn]
}

############################################
# Route53 A/ALIAS records -> shared ALB
############################################

# Root: shaqserver.com
resource "aws_route53_record" "landing_alias" {
  zone_id         = data.aws_route53_zone.root.zone_id
  name            = var.root_domain
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.alb.id
    evaluate_target_health = false
  }

  depends_on = [data.kubernetes_ingress_v1.main]
}

# Additional app aliases
resource "aws_route53_record" "meowmart_alias" {
  zone_id         = data.aws_route53_zone.root.zone_id
  name            = "${var.additional_subdomains[0]}.${var.root_domain}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.alb.id
    evaluate_target_health = false
  }

  depends_on = [data.kubernetes_ingress_v1.main]
}

resource "aws_route53_record" "slide_alias" {
  zone_id         = data.aws_route53_zone.root.zone_id
  name            = "${var.additional_subdomains[1]}.${var.root_domain}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.alb.id
    evaluate_target_health = false
  }

  depends_on = [data.kubernetes_ingress_v1.main]
}

# 1. Request the wildcard cert
resource "aws_acm_certificate" "wildcard" {
  domain_name               = "*.${var.root_domain}"
  subject_alternative_names = [var.root_domain]
  validation_method         = "DNS"
  lifecycle { create_before_destroy = true }
}

# 2. Create DNS validation records in your hosted zone
resource "aws_route53_record" "wildcard_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id

  name = each.value.name
  type = each.value.type
  # ACM can reuse the same DNS validation record for the apex and wildcard certs.
  # Keep this aligned with the landing cert record to avoid perpetual drift.
  ttl             = 60
  records         = [each.value.record]
  allow_overwrite = true
}

# 3. Validate the cert using the records above
resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_validation : record.fqdn]
}

data "aws_route53_zone" "primary" {
  name         = "${var.root_domain}."
  private_zone = false
}
