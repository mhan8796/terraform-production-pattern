variable "name" {
  description = "Name prefix used for EKS resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by EKS."
  type        = list(string)
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "kms_deletion_window_days" {
  description = "Deletion window for the EKS KMS key."
  type        = number
}

variable "kubernetes_version" {
  description = "EKS Kubernetes control plane version."
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to send to CloudWatch."
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Enable private EKS API endpoint access."
  type        = bool
}

variable "cluster_endpoint_public_access" {
  description = "Enable public EKS API endpoint access."
  type        = bool
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
}

variable "cluster_addons" {
  description = "AWS-managed EKS add-ons to install into the empty cluster."
  type = map(object({
    addon_version               = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
  }))
}

variable "enable_managed_node_group" {
  description = "Create a default EKS managed node group."
  type        = bool
}

variable "node_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)
}

variable "node_ami_type" {
  description = "AMI type for the default managed node group."
  type        = string
}

variable "node_capacity_type" {
  description = "Capacity type for the default managed node group."
  type        = string
}

variable "node_disk_size" {
  description = "Node root volume size in GiB."
  type        = number
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
}

variable "node_update_max_unavailable" {
  description = "Maximum unavailable nodes during managed node group updates."
  type        = number
}

variable "enable_gpu_node_group" {
  description = "Create a GPU node group with nvidia taint."
  type        = bool
}

variable "gpu_node_instance_types" {
  description = "EC2 instance types for the GPU node group (e.g. g4dn.xlarge)."
  type        = list(string)
}

variable "gpu_node_ami_type" {
  description = "AMI type for the GPU node group."
  type        = string
}

variable "gpu_node_min_size" {
  description = "Minimum node count for the GPU node group."
  type        = number
}

variable "gpu_node_desired_size" {
  description = "Desired node count for the GPU node group."
  type        = number
}

variable "gpu_node_max_size" {
  description = "Maximum node count for the GPU node group."
  type        = number
}
