variable "name" {
  description = "Name prefix used for RDS resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID allowed to connect to RDS."
  type        = string
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum storage autoscaling limit in GiB. Set to 0 to disable autoscaling."
  type        = number
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
}

variable "db_multi_az" {
  description = "Enable multi-AZ deployment for high availability."
  type        = bool
}

variable "db_deletion_protection" {
  description = "Enable deletion protection on the RDS instance."
  type        = bool
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated backups."
  type        = number
}

variable "db_backup_window" {
  description = "Daily time range for automated backups (UTC). e.g. 03:00-04:00"
  type        = string
}

variable "db_maintenance_window" {
  description = "Weekly time range for maintenance (UTC). e.g. Mon:04:00-Mon:05:00"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "db_parameter_group_family" {
  description = "RDS parameter group family, e.g. postgres16."
  type        = string
}
