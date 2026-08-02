output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_kms_key_arn" {
  description = "KMS key ARN used for Terraform state encryption."
  value       = aws_kms_key.terraform_state.arn
}

output "backend_example" {
  description = "Example S3 backend settings for environment root modules."
  value = {
    bucket       = aws_s3_bucket.terraform_state.bucket
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}
