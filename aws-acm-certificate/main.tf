locals {
  tags = {
    project   = var.project
    env       = var.env
    service   = var.service
    owner     = var.owner
    managedBy = "terraform"
  }

  all_domains = merge(
    var.cert_subject_alternative_names,
    {
      "${var.cert_domain_name}" = var.aws_route53_zone_id
    }
  )
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.cert_domain_name
  subject_alternative_names = var.subject_alternative_names_order == null ? keys(var.cert_subject_alternative_names) : var.subject_alternative_names_order
  validation_method         = "DNS"
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  domain_validation_options = {
    for v in aws_acm_certificate.cert.domain_validation_options: v["domain_name"] => {
      resource_record_name  = v["resource_record_name"]
      resource_record_type  = v["resource_record_type"]
      resource_record_value = v["resource_record_value"]
    }
  }
}

# https://www.terraform.io/docs/providers/aws/r/acm_certificate_validation.html
resource "aws_route53_record" "cert_validation" {
  for_each = local.all_domains

  name    = local.domain_validation_options[each.key]["resource_record_name"]
  type    = local.domain_validation_options[each.key]["resource_record_type"]
  zone_id = each.value
  records = [local.domain_validation_options[each.key]["resource_record_value"]]
  ttl     = var.validation_record_ttl

  allow_overwrite = var.allow_validation_record_overwrite
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation.*.fqdn
}
