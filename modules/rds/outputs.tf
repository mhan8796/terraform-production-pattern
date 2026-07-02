output "db_instance_endpoint" {
  description = "RDS instance connection endpoint."
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.main.identifier
}

output "db_instance_address" {
  description = "RDS instance hostname."
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS instance port."
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.main.db_name
}

output "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "db_security_group_id" {
  description = "Security group ID attached to the RDS instance."
  value       = aws_security_group.rds.id
}
