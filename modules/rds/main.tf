resource "aws_db_parameter_group" "main" {
  name        = "${var.name}-postgres"
  family      = var.db_parameter_group_family
  description = "Parameter group for ${var.name} PostgreSQL with pgvector support."

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pgvector"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.name}-postgres"
  }
}

resource "aws_kms_key" "rds" {
  description             = "KMS key for ${var.name} RDS encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "${var.name}-rds"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.name}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds"
  description = "PostgreSQL RDS access from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-rds"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.eks_cluster_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.name}-rds"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name}-rds"
  }
}

resource "aws_cloudwatch_log_group" "rds_postgresql" {
  name              = "/aws/rds/instance/${var.name}/postgresql"
  retention_in_days = var.log_retention_days
}

resource "aws_db_instance" "main" {
  identifier = "${var.name}-postgres"

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage > 0 ? var.db_max_allocated_storage : null
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  # Password managed via AWS Secrets Manager — use manage_master_user_password
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name
  publicly_accessible    = false

  multi_az = var.db_multi_az

  backup_retention_period = var.db_backup_retention_days
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window
  copy_tags_to_snapshot   = true

  deletion_protection      = var.db_deletion_protection
  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.name}-postgres-final"
  delete_automated_backups = false

  enabled_cloudwatch_logs_exports = ["postgresql"]

  depends_on = [aws_cloudwatch_log_group.rds_postgresql]

  tags = {
    Name = "${var.name}-postgres"
  }
}
