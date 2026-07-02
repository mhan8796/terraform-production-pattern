variable "domain_name" {
  description = "Primary domain name for the ACM certificate, e.g. api.example.com."
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names for the certificate, e.g. [\"*.example.com\"]."
  type        = list(string)
}

variable "validation_method" {
  description = "Certificate validation method: DNS or EMAIL."
  type        = string
}
