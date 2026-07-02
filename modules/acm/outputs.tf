output "certificate_arn" {
  description = "ARN of the issued ACM certificate."
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "domain_validation_options" {
  description = "DNS records required to validate the certificate. Create these in your DNS provider."
  value       = aws_acm_certificate.main.domain_validation_options
}
