terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
}
