variable "name" {
  description = "Name prefix used for ElastiCache resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ElastiCache cluster is created."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ElastiCache subnet group."
  type        = list(string)
}

variable "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID allowed to connect to Redis."
  type        = string
}

variable "redis_node_type" {
  description = "ElastiCache node type."
  type        = string
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group. Minimum 2 for multi-AZ."
  type        = number
}

variable "redis_automatic_failover" {
  description = "Enable automatic failover for the Redis replication group."
  type        = bool
}

variable "redis_at_rest_encryption" {
  description = "Enable at-rest encryption for the Redis replication group."
  type        = bool
}

variable "redis_in_transit_encryption" {
  description = "Enable in-transit encryption (TLS) for the Redis replication group."
  type        = bool
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}
