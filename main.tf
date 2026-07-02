terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "platform-prod-terraform-state"
    key            = "platform/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "platform-prod-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

locals {
  name = "${var.project_name}-${var.environment}"

  tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

module "vpc" {
  source = "./modules/vpc"

  name                    = local.name
  aws_region              = var.aws_region
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  az_count                = var.az_count
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  enable_vpc_flow_logs    = var.enable_vpc_flow_logs
  enable_vpc_endpoints    = var.enable_vpc_endpoints
  interface_vpc_endpoints = var.interface_vpc_endpoints
  log_retention_days      = var.log_retention_days
}

module "eks" {
  source = "./modules/eks"

  name                                 = local.name
  vpc_id                               = module.vpc.vpc_id
  private_subnet_ids                   = module.vpc.private_subnet_ids
  log_retention_days                   = var.log_retention_days
  kms_deletion_window_days             = var.kms_deletion_window_days
  kubernetes_version                   = var.kubernetes_version
  enabled_cluster_log_types            = var.enabled_cluster_log_types
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_addons                       = var.cluster_addons
  enable_managed_node_group            = var.enable_managed_node_group
  node_instance_types                  = var.node_instance_types
  node_ami_type                        = var.node_ami_type
  node_capacity_type                   = var.node_capacity_type
  node_disk_size                       = var.node_disk_size
  node_min_size                        = var.node_min_size
  node_desired_size                    = var.node_desired_size
  node_max_size                        = var.node_max_size
  node_update_max_unavailable          = var.node_update_max_unavailable
  enable_gpu_node_group                = var.enable_gpu_node_group
  gpu_node_instance_types              = var.gpu_node_instance_types
  gpu_node_ami_type                    = var.gpu_node_ami_type
  gpu_node_min_size                    = var.gpu_node_min_size
  gpu_node_desired_size                = var.gpu_node_desired_size
  gpu_node_max_size                    = var.gpu_node_max_size
}

module "cache" {
  source = "./modules/cache"

  name                          = local.name
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  redis_node_type               = var.redis_node_type
  redis_engine_version          = var.redis_engine_version
  redis_num_cache_clusters      = var.redis_num_cache_clusters
  redis_automatic_failover      = var.redis_automatic_failover
  redis_at_rest_encryption      = var.redis_at_rest_encryption
  redis_in_transit_encryption   = var.redis_in_transit_encryption
  log_retention_days            = var.log_retention_days
}

module "rds" {
  source = "./modules/rds"

  name                          = local.name
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnet_ids
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  db_engine_version             = var.db_engine_version
  db_instance_class             = var.db_instance_class
  db_allocated_storage          = var.db_allocated_storage
  db_max_allocated_storage      = var.db_max_allocated_storage
  db_name                       = var.db_name
  db_username                   = var.db_username
  db_multi_az                   = var.db_multi_az
  db_deletion_protection        = var.db_deletion_protection
  db_backup_retention_days      = var.db_backup_retention_days
  db_backup_window              = var.db_backup_window
  db_maintenance_window         = var.db_maintenance_window
  db_parameter_group_family     = var.db_parameter_group_family
  log_retention_days            = var.log_retention_days
}

module "s3" {
  source = "./modules/s3"

  name                              = local.name
  force_destroy                     = var.s3_force_destroy
  versioning_enabled                = var.s3_versioning_enabled
  lifecycle_glacier_transition_days = var.s3_lifecycle_glacier_transition_days
  lifecycle_expiration_days         = var.s3_lifecycle_expiration_days
  log_retention_days                = var.log_retention_days
}

module "irsa" {
  source = "./modules/irsa"

  name              = local.name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  cluster_namespace = var.irsa_cluster_namespace
  bedrock_enabled   = var.irsa_bedrock_enabled
  s3_bucket_arns    = [module.s3.bucket_arn]
}

module "alb" {
  source = "./modules/alb"

  name                  = local.name
  vpc_id                = module.vpc.vpc_id
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_provider_url     = module.eks.oidc_provider_url
  ingress_allowed_cidrs = var.alb_ingress_allowed_cidrs
}

module "acm" {
  source = "./modules/acm"

  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  validation_method         = var.acm_validation_method
}

module "waf" {
  source = "./modules/waf"

  name                = local.name
  rate_limit_requests = var.waf_rate_limit_requests
  blocked_countries   = var.waf_blocked_countries
  log_retention_days  = var.log_retention_days
}

module "observability" {
  source = "./modules/observability"

  name                        = local.name
  eks_cluster_name            = module.eks.cluster_name
  rds_instance_id             = module.rds.db_instance_id
  redis_replication_group_id  = module.cache.redis_replication_group_id
  alarm_sns_topic_arn         = var.observability_alarm_sns_topic_arn
  log_retention_days          = var.log_retention_days
  ai_api_error_rate_threshold = var.observability_ai_api_error_rate_threshold
  ai_api_latency_threshold_ms = var.observability_ai_api_latency_threshold_ms
}
