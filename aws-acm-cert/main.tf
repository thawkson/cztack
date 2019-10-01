locals {
  tags = {
    Name      = "${var.project}-${var.env}-${var.service}"
    project   = var.project
    env       = var.env
    service   = var.service
    owner     = var.owner
    managedBy = "terraform"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.cert_domain_name
  subject_alternative_names = keys(var.cert_subject_alternative_names)
  validation_method         = "DNS"
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = aws_acm_certificate.cert.domain_validation_options

  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = lookup(var.cert_subject_alternative_names, each.value.domain_name, var.aws_route53_zone_id)
  records = [each.value.resource_record_value]
  ttl     = var.validation_record_ttl

  allow_overwrite = var.allow_validation_record_overwrite
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation.*.fqdn
}
