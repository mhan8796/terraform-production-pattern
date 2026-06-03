variable "name" {
  description = "Name prefix used for VPC resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region used to build VPC endpoint service names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to use."
  type        = list(string)
}

variable "az_count" {
  description = "Number of availability zones to use from availability_zones."
  type        = number
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway egress for private subnets."
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway instead of one per AZ."
  type        = bool
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs."
  type        = bool
}

variable "enable_vpc_endpoints" {
  description = "Create common private VPC endpoints for EKS worker traffic."
  type        = bool
}

variable "interface_vpc_endpoints" {
  description = "Interface endpoint service suffixes to create in private subnets."
  type        = list(string)
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}
