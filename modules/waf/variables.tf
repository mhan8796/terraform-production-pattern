variable "name" {
  description = "Name prefix used for WAF resources."
  type        = string
}

variable "rate_limit_requests" {
  description = "Maximum number of requests per 5-minute window per IP before rate limiting applies."
  type        = number
}

variable "blocked_countries" {
  description = "ISO 3166-1 alpha-2 country codes to geo-block. Empty list disables geo-blocking."
  type        = list(string)
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
}
