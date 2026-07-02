resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.domain_name
  }
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  # For DNS validation, the caller is responsible for creating the DNS records
  # surfaced in the domain_validation_options output. This resource simply waits
  # until ACM reports the certificate as issued.
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.resource_record_name
  ]

  timeouts {
    create = "5m"
  }
}
