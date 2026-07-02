# ---------------------------------------------------------------------------
# Access logs bucket (created first; referenced by main bucket logging)
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.name}-ai-assets-logs"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.name}-ai-assets-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------------------------
# Main AI assets bucket
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket        = "${var.name}-ai-assets"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.name}-ai-assets"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_glacier_transition_days > 0 ? [1] : []

    content {
      id     = "glacier-transition"
      status = "Enabled"

      transition {
        days          = var.lifecycle_glacier_transition_days
        storage_class = "GLACIER_IR"
      }
    }
  }

  dynamic "rule" {
    for_each = var.lifecycle_expiration_days > 0 ? [1] : []

    content {
      id     = "expiration"
      status = "Enabled"

      expiration {
        days = var.lifecycle_expiration_days
      }
    }
  }

  # At least one rule is required by the provider; add a no-op rule when both
  # dynamic rules are disabled so the resource remains valid.
  dynamic "rule" {
    for_each = (var.lifecycle_glacier_transition_days == 0 && var.lifecycle_expiration_days == 0) ? [1] : []

    content {
      id     = "noop"
      status = "Disabled"

      expiration {
        days = 36500
      }
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyNonSSL"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]
      Condition = {
        Bool = {
          "aws:SecureTransport" = "false"
        }
      }
    }]
  })
}
