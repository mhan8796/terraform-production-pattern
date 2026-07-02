locals {
  # Use the provided SNS ARN when given; otherwise use the topic created below.
  effective_sns_topic_arn = var.alarm_sns_topic_arn != "" ? var.alarm_sns_topic_arn : aws_sns_topic.alarms.arn
}

# ---------------------------------------------------------------------------
# SNS topic (used when no external ARN is provided)
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "alarms" {
  name = "${var.name}-alarms"

  tags = {
    Name = "${var.name}-alarms"
  }
}

# ---------------------------------------------------------------------------
# Application log group
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/application/${var.name}"
  retention_in_days = var.log_retention_days
}

# ---------------------------------------------------------------------------
# Metric filters
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "error_rate" {
  name           = "${var.name}-error-rate"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[ERROR]"

  metric_transformation {
    name          = "${var.name}-ErrorCount"
    namespace     = "${var.name}/Application"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ai_latency" {
  name           = "${var.name}-ai-latency"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "{ $.latency > 0 }"

  metric_transformation {
    name          = "${var.name}-AILatency"
    namespace     = "${var.name}/Application"
    value         = "$.latency"
    default_value = "0"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch alarms — RDS
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.name}-rds-cpu-high"
  alarm_description   = "RDS CPU utilization exceeded 80% for 10 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-rds-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.name}-rds-storage-low"
  alarm_description   = "RDS free storage space dropped below 10 GB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10737418240 # 10 GB in bytes
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-rds-storage-low"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch alarms — Redis
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  alarm_name          = "${var.name}-redis-cpu-high"
  alarm_description   = "Redis engine CPU utilization exceeded 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.redis_replication_group_id
  }

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-redis-cpu-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  alarm_name          = "${var.name}-redis-memory-high"
  alarm_description   = "Redis database memory usage exceeded 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.redis_replication_group_id
  }

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-redis-memory-high"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch alarm — EKS node CPU (EC2 namespace)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_node_cpu" {
  alarm_name          = "${var.name}-eks-node-cpu-high"
  alarm_description   = "EKS node average CPU utilization exceeded 80%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  # No single dimension — monitors across all EC2 instances in the account/region.
  # For a tighter scope, set AutoScalingGroupName once the ASG name is known.

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-eks-node-cpu-high"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch alarms — AI API (from log metric filters)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ai_error_rate" {
  alarm_name          = "${var.name}-ai-error-rate-high"
  alarm_description   = "AI API error rate exceeded ${var.ai_api_error_rate_threshold}%."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = aws_cloudwatch_log_metric_filter.error_rate.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_rate.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = var.ai_api_error_rate_threshold
  treat_missing_data  = "notBreaching"

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-ai-error-rate-high"
  }
}

resource "aws_cloudwatch_metric_alarm" "ai_latency" {
  alarm_name          = "${var.name}-ai-latency-high"
  alarm_description   = "AI API p99 latency exceeded ${var.ai_api_latency_threshold_ms} ms."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = aws_cloudwatch_log_metric_filter.ai_latency.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.ai_latency.metric_transformation[0].namespace
  period              = 300
  extended_statistic  = "p99"
  threshold           = var.ai_api_latency_threshold_ms
  treat_missing_data  = "notBreaching"

  alarm_actions = [local.effective_sns_topic_arn]
  ok_actions    = [local.effective_sns_topic_arn]

  tags = {
    Name = "${var.name}-ai-latency-high"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch dashboard
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 6
        properties = {
          title  = "EKS Node CPU"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/EC2", "CPUUtilization",
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 6
        properties = {
          title  = "EKS Node Memory"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "CWAgent", "mem_used_percent",
            "ClusterName", var.eks_cluster_name,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 6
        properties = {
          title  = "RDS CPU"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/RDS", "CPUUtilization",
            "DBInstanceIdentifier", var.rds_instance_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 6
        properties = {
          title  = "RDS Connections"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/RDS", "DatabaseConnections",
            "DBInstanceIdentifier", var.rds_instance_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6
        properties = {
          title  = "RDS Free Storage"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/RDS", "FreeStorageSpace",
            "DBInstanceIdentifier", var.rds_instance_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6
        properties = {
          title  = "Redis CPU"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/ElastiCache", "EngineCPUUtilization",
            "ReplicationGroupId", var.redis_replication_group_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 6
        height = 6
        properties = {
          title  = "Redis Memory"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/ElastiCache", "DatabaseMemoryUsagePercentage",
            "ReplicationGroupId", var.redis_replication_group_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 6
        width  = 6
        height = 6
        properties = {
          title  = "Redis Connections"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [[
            "AWS/ElastiCache", "CurrConnections",
            "ReplicationGroupId", var.redis_replication_group_id,
          ]]
          period = 300
          stat   = "Average"
        }
      },
    ]
  })
}
