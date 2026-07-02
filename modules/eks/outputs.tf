output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID created by AWS."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.main.arn
}

output "node_group_name" {
  description = "Managed node group name when enabled."
  value       = var.enable_managed_node_group ? aws_eks_node_group.default[0].node_group_name : null
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider used for IRSA."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "EKS OIDC provider URL without the https:// prefix."
  value       = trimprefix(aws_iam_openid_connect_provider.eks.url, "https://")
}

output "gpu_node_group_name" {
  description = "GPU node group name when enabled."
  value       = var.enable_gpu_node_group ? aws_eks_node_group.gpu[0].node_group_name : null
}
