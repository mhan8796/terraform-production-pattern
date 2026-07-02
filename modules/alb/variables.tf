variable "name" {
  description = "Name prefix used for ALB controller resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB security group is created."
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

variable "ingress_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the ALB on ports 80 and 443."
  type        = list(string)
}
