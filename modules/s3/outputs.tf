output "bucket_id" {
  description = "Main AI assets bucket name."
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "Main AI assets bucket ARN."
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Main AI assets bucket regional domain name."
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "logs_bucket_id" {
  description = "Access logs bucket name."
  value       = aws_s3_bucket.logs.id
}
