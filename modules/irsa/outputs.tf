output "ai_workload_role_arn" {
  description = "ARN of the IAM role assumed by AI workload pods via IRSA."
  value       = aws_iam_role.ai_workload.arn
}

output "ai_workload_role_name" {
  description = "Name of the IAM role assumed by AI workload pods via IRSA."
  value       = aws_iam_role.ai_workload.name
}
