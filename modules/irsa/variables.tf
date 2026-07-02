variable "name" {
  description = "Name prefix used for IRSA resources."
  type        = string
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  type        = string
}

variable "oidc_provider_url" {
  description = "EKS OIDC provider URL without https://."
  type        = string
}

variable "cluster_namespace" {
  description = "Kubernetes namespace for the AI workload service account."
  type        = string
}

variable "bedrock_enabled" {
  description = "Create and attach an IAM policy allowing Amazon Bedrock access."
  type        = bool
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs the AI workload role is allowed to access."
  type        = list(string)
}
