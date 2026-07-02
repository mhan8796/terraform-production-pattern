output "alb_controller_role_arn" {
  description = "ARN of the IAM role for the AWS Load Balancer Controller."
  value       = aws_iam_role.alb_controller.arn
}

output "alb_security_group_id" {
  description = "Security group ID for the application load balancer."
  value       = aws_security_group.alb.id
}
