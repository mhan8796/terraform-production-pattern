output "aws_region" {
  description = "AWS region used by this stack."
  value       = var.aws_region
}

output "vpc_id" {
  description = "Created VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by EKS."
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID created by AWS."
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "node_group_name" {
  description = "Managed node group name when enabled."
  value       = module.eks.node_group_name
}

output "update_kubeconfig_command" {
  description = "Command to configure kubectl for the empty EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint address."
  value       = module.cache.redis_primary_endpoint
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint address."
  value       = module.cache.redis_reader_endpoint
}

output "redis_port" {
  description = "Redis port."
  value       = module.cache.redis_port
}

output "db_instance_endpoint" {
  description = "RDS PostgreSQL connection endpoint."
  value       = module.rds.db_instance_endpoint
}

output "db_instance_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.db_instance_port
}

output "db_name" {
  description = "Name of the initial database."
  value       = module.rds.db_instance_name
}

output "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the RDS master password."
  value       = module.rds.db_master_user_secret_arn
}

# ---------------------------------------------------------------------------
# EKS OIDC / IRSA
# ---------------------------------------------------------------------------

output "eks_oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "URL of the EKS OIDC provider (without https://)."
  value       = module.eks.oidc_provider_url
}

output "gpu_node_group_name" {
  description = "GPU node group name when enabled."
  value       = module.eks.gpu_node_group_name
}

output "ai_workload_role_arn" {
  description = "ARN of the IRSA role for AI workload pods."
  value       = module.irsa.ai_workload_role_arn
}

# ---------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------

output "s3_bucket_id" {
  description = "AI assets S3 bucket name."
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "AI assets S3 bucket ARN."
  value       = module.s3.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "AI assets S3 bucket regional domain name."
  value       = module.s3.bucket_domain_name
}

# ---------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for the AWS Load Balancer Controller."
  value       = module.alb.alb_controller_role_arn
}

output "alb_security_group_id" {
  description = "Security group ID for the application load balancer."
  value       = module.alb.alb_security_group_id
}

# ---------------------------------------------------------------------------
# ACM
# ---------------------------------------------------------------------------

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate."
  value       = module.acm.certificate_arn
}

output "acm_domain_validation_options" {
  description = "DNS records needed to validate the ACM certificate."
  value       = module.acm.domain_validation_options
}

# ---------------------------------------------------------------------------
# WAF
# ---------------------------------------------------------------------------

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL."
  value       = module.waf.web_acl_arn
}

output "waf_web_acl_id" {
  description = "ID of the WAFv2 Web ACL."
  value       = module.waf.web_acl_id
}

# ---------------------------------------------------------------------------
# Observability
# ---------------------------------------------------------------------------

output "observability_sns_topic_arn" {
  description = "ARN of the SNS topic used for alarm notifications."
  value       = module.observability.sns_topic_arn
}

output "observability_dashboard_name" {
  description = "Name of the CloudWatch overview dashboard."
  value       = module.observability.dashboard_name
}

output "application_log_group_name" {
  description = "CloudWatch log group name for application logs."
  value       = module.observability.application_log_group_name
}
