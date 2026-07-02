variable "name" {
  description = "Name prefix used for S3 resources."
  type        = string
}

variable "force_destroy" {
  description = "Allow destroying the bucket even when it contains objects. Set to false for production."
  type        = bool
}

variable "versioning_enabled" {
  description = "Enable versioning on the main bucket."
  type        = bool
}

variable "lifecycle_glacier_transition_days" {
  description = "Days before transitioning objects to GLACIER_IR. Set to 0 to disable."
  type        = number
}

variable "lifecycle_expiration_days" {
  description = "Days before expiring objects. Set to 0 to disable."
  type        = number
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days (unused here; kept for interface consistency)."
  type        = number
}
