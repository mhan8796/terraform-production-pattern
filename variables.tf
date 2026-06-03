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
