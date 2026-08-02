variable "name_prefix" {
  description = "Prefix used for IAM resource names."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/name format."
  type        = string
  default     = "utku9012/rentacar-backend-api"
}

variable "allowed_subjects" {
  description = "Allowed GitHub OIDC subject claims."
  type        = list(string)
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN that GitHub Actions may push to."
  type        = string
}

variable "create_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider. Set false if the AWS account already has one."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub OIDC provider ARN when create_oidc_provider is false."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
