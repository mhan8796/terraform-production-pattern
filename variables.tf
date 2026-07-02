variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used in resource names."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name used in resource names and tags."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use. Keep these in the selected aws_region."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "az_count" {
  description = "Number of availability zones to use from availability_zones."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= length(var.availability_zones)
    error_message = "az_count must be at least 2 and no larger than the number of availability_zones."
  }
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway egress for private subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway instead of one per AZ. Cheaper, but less resilient."
  type        = bool
  default     = false
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "enable_vpc_endpoints" {
  description = "Create common private VPC endpoints for EKS worker traffic."
  type        = bool
  default     = true
}

variable "interface_vpc_endpoints" {
  description = "Interface endpoint service suffixes to create in private subnets."
  type        = list(string)
  default     = ["ec2", "ecr.api", "ecr.dkr", "logs", "sts"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30
}

variable "kms_deletion_window_days" {
  description = "Deletion window for the EKS KMS key."
  type        = number
  default     = 30
}

variable "kubernetes_version" {
  description = "EKS Kubernetes control plane version."
  type        = string
  default     = "1.30"
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to send to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_endpoint_private_access" {
  description = "Enable private EKS API endpoint access."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public EKS API endpoint access."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_addons" {
  description = "AWS-managed EKS add-ons to install into the empty cluster."
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
  }))
  default = {
    coredns                  = {}
    "kube-proxy"             = {}
    "vpc-cni"                = {}
    "eks-pod-identity-agent" = {}
  }
}

variable "enable_managed_node_group" {
  description = "Create a default EKS managed node group. Disable for a control-plane-only empty cluster."
  type        = bool
  default     = true
}

variable "node_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_ami_type" {
  description = "AMI type for the default managed node group."
  type        = string
  default     = "AL2_x86_64"
}

variable "node_capacity_type" {
  description = "Capacity type for the default managed node group."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Node root volume size in GiB."
  type        = number
  default     = 50
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 6
}

variable "node_update_max_unavailable" {
  description = "Maximum unavailable nodes during managed node group updates."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags applied to all AWS resources that support provider default tags."
  type        = map(string)
  default = {
    Owner      = "platform"
    CostCenter = "shared"
  }
}

# ---------------------------------------------------------------------------
# Cache (ElastiCache Redis)
# ---------------------------------------------------------------------------

variable "redis_node_type" {
  description = "ElastiCache node type for Redis."
  type        = string
  default     = "cache.t4g.medium"
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters in the replication group. Minimum 2 for multi-AZ failover."
  type        = number
  default     = 3
}

variable "redis_automatic_failover" {
  description = "Enable automatic failover for the Redis replication group."
  type        = bool
  default     = true
}

variable "redis_at_rest_encryption" {
  description = "Enable at-rest encryption for Redis."
  type        = bool
  default     = true
}

variable "redis_in_transit_encryption" {
  description = "Enable in-transit (TLS) encryption for Redis."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Database (RDS PostgreSQL)
# ---------------------------------------------------------------------------

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Maximum storage autoscaling limit in GiB. Set to 0 to disable."
  type        = number
  default     = 500
}

variable "db_name" {
  description = "Name of the initial database created on the RDS instance."
  type        = string
  default     = "app"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "dbadmin"
}

variable "db_multi_az" {
  description = "Enable multi-AZ deployment for the RDS instance."
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Enable deletion protection on the RDS instance."
  type        = bool
  default     = true
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Daily UTC time window for automated RDS backups. e.g. 03:00-04:00"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Weekly UTC time window for RDS maintenance. e.g. Mon:04:00-Mon:05:00"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

# ---------------------------------------------------------------------------
# EKS GPU node group
# ---------------------------------------------------------------------------

variable "enable_gpu_node_group" {
  description = "Create a GPU node group with nvidia.com/gpu taint."
  type        = bool
  default     = false
}

variable "gpu_node_instance_types" {
  description = "EC2 instance types for the GPU node group."
  type        = list(string)
  default     = ["g4dn.xlarge"]
}

variable "gpu_node_ami_type" {
  description = "AMI type for the GPU node group."
  type        = string
  default     = "AL2_x86_64_GPU"
}

variable "gpu_node_min_size" {
  description = "Minimum node count for the GPU node group."
  type        = number
  default     = 0
}

variable "gpu_node_desired_size" {
  description = "Desired node count for the GPU node group."
  type        = number
  default     = 0
}

variable "gpu_node_max_size" {
  description = "Maximum node count for the GPU node group."
  type        = number
  default     = 4
}

# ---------------------------------------------------------------------------
# RDS — parameter group
# ---------------------------------------------------------------------------

variable "db_parameter_group_family" {
  description = "RDS parameter group family, e.g. postgres16."
  type        = string
  default     = "postgres16"
}

# ---------------------------------------------------------------------------
# S3 (AI assets)
# ---------------------------------------------------------------------------

variable "s3_force_destroy" {
  description = "Allow destroying the AI assets bucket when it contains objects. Set to false in production."
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Enable versioning on the AI assets S3 bucket."
  type        = bool
  default     = true
}

variable "s3_lifecycle_glacier_transition_days" {
  description = "Days before transitioning AI assets to GLACIER_IR. Set to 0 to disable."
  type        = number
  default     = 90
}

variable "s3_lifecycle_expiration_days" {
  description = "Days before expiring AI assets objects. Set to 0 to disable."
  type        = number
  default     = 0
}

# ---------------------------------------------------------------------------
# IRSA
# ---------------------------------------------------------------------------

variable "irsa_cluster_namespace" {
  description = "Kubernetes namespace for the AI workload service account."
  type        = string
  default     = "ai-platform"
}

variable "irsa_bedrock_enabled" {
  description = "Create and attach an IAM policy for Amazon Bedrock access to the AI workload role."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# ALB controller
# ---------------------------------------------------------------------------

variable "alb_ingress_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the ALB on ports 80 and 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------------------------------------------------------------------------
# ACM certificate
# ---------------------------------------------------------------------------

variable "acm_domain_name" {
  description = "Primary domain name for the ACM certificate."
  type        = string
  default     = "api.example.com"
}

variable "acm_subject_alternative_names" {
  description = "Subject alternative names for the ACM certificate."
  type        = list(string)
  default     = ["*.example.com"]
}

variable "acm_validation_method" {
  description = "ACM certificate validation method: DNS or EMAIL."
  type        = string
  default     = "DNS"
}

# ---------------------------------------------------------------------------
# WAF
# ---------------------------------------------------------------------------

variable "waf_rate_limit_requests" {
  description = "Maximum requests per 5-minute window per IP before rate limiting applies."
  type        = number
  default     = 2000
}

variable "waf_blocked_countries" {
  description = "ISO 3166-1 alpha-2 country codes to geo-block. Empty list disables geo-blocking."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Observability
# ---------------------------------------------------------------------------

variable "observability_alarm_sns_topic_arn" {
  description = "Existing SNS topic ARN for alarm notifications. Leave empty to create a new topic."
  type        = string
  default     = ""
}

variable "observability_ai_api_error_rate_threshold" {
  description = "Error count threshold that triggers the AI API error rate alarm."
  type        = number
  default     = 10
}

variable "observability_ai_api_latency_threshold_ms" {
  description = "P99 latency in milliseconds threshold that triggers the AI API latency alarm."
  type        = number
  default     = 3000
}
