resource "aws_iam_role" "ai_workload" {
  name = "${var.name}-ai-workload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:${var.cluster_namespace}:ai-workload"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name = "${var.name}-ai-workload"
  }
}

resource "aws_iam_policy" "bedrock_access" {
  count = var.bedrock_enabled ? 1 : 0

  name        = "${var.name}-bedrock-access"
  description = "Allows AI workload pods to invoke Amazon Bedrock foundation models."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListFoundationModels",
      ]
      Resource = "*"
    }]
  })

  tags = {
    Name = "${var.name}-bedrock-access"
  }
}

resource "aws_iam_role_policy_attachment" "bedrock" {
  count = var.bedrock_enabled ? 1 : 0

  role       = aws_iam_role.ai_workload.name
  policy_arn = aws_iam_policy.bedrock_access[0].arn
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.name}-s3-access"
  description = "Allows AI workload pods to read/write designated S3 buckets."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [for arn in var.s3_bucket_arns : "${arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = var.s3_bucket_arns
      },
    ]
  })

  tags = {
    Name = "${var.name}-s3-access"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.ai_workload.name
  policy_arn = aws_iam_policy.s3_access.arn
}
