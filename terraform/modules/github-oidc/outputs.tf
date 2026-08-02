output "oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = local.github_oidc_provider_arn
}

output "github_ecr_publisher_role_arn" {
  description = "IAM role ARN for GitHub Actions ECR publishing."
  value       = aws_iam_role.github_ecr_publisher.arn
}

output "github_ecr_publisher_role_name" {
  description = "IAM role name for GitHub Actions ECR publishing."
  value       = aws_iam_role.github_ecr_publisher.name
}
