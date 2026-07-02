output "redis_primary_endpoint" {
  description = "Redis primary endpoint address."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint address."
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port."
  value       = aws_elasticache_replication_group.main.port
}

output "redis_security_group_id" {
  description = "Security group ID attached to the Redis cluster."
  value       = aws_security_group.redis.id
}

output "redis_replication_group_id" {
  description = "ElastiCache replication group ID."
  value       = aws_elasticache_replication_group.main.id
}
