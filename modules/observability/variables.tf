variable "name" {
  description = "Name prefix used for observability resources."
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name for dashboard widgets and alarm dimensions."
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance identifier for alarms and dashboard widgets."
  type        = string
}

variable "redis_replication_group_id" {
  description = "ElastiCache replication group ID for alarms and dashboard widgets."
  type        = string
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications. Leave empty to create a new topic."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
}

variable "ai_api_error_rate_threshold" {
  description = "Error rate percentage threshold that triggers the AI API error rate alarm."
  type        = number
}

variable "ai_api_latency_threshold_ms" {
  description = "P99 latency in milliseconds threshold that triggers the AI API latency alarm."
  type        = number
}
