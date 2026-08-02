variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "rentacar"
}

variable "environment" {
  description = "Bootstrap environment label."
  type        = string
  default     = "bootstrap"
}

variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile. Leave null for environment variables or identity federation."
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner tag value."
  type        = string
}

variable "repository" {
  description = "Repository tag value."
  type        = string
  default     = "utku9012/rentacar-backend-api"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state."
  type        = string
}

variable "state_retention_days" {
  description = "Number of days before noncurrent state object versions expire."
  type        = number
  default     = 90

  validation {
    condition     = var.state_retention_days >= 30
    error_message = "State retention should be at least 30 days."
  }
}
