resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "Redis ElastiCache access from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-redis"
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_eks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = var.eks_cluster_security_group_id
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "redis_all" {
  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-redis"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-redis"
  }
}

resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/${var.name}/redis/slow-log"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name              = "/aws/elasticache/${var.name}/redis/engine-log"
  retention_in_days = var.log_retention_days
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.name}-redis"
  description          = "Redis replication group for ${var.name}"

  node_type            = var.redis_node_type
  engine_version       = var.redis_engine_version
  port                 = 6379
  parameter_group_name = "default.redis7"

  num_cache_clusters         = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_automatic_failover
  multi_az_enabled           = var.redis_automatic_failover

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled  = var.redis_at_rest_encryption
  transit_encryption_enabled  = var.redis_in_transit_encryption

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name = "${var.name}-redis"
  }
}
