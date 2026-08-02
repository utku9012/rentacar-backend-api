variable "project_name" {
  description = "Project name used for naming and tags."
  type        = string
  default     = "rentacar"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile."
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

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for this environment."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
  default     = ["10.40.0.0/20", "10.40.16.0/20"]
}

variable "private_app_subnet_cidrs" {
  description = "Private application subnet CIDRs."
  type        = list(string)
  default     = ["10.40.32.0/20", "10.40.48.0/20"]
}

variable "private_db_subnet_cidrs" {
  description = "Private database subnet CIDRs."
  type        = list(string)
  default     = ["10.40.64.0/20", "10.40.80.0/20"]
}

variable "nat_gateway_mode" {
  description = "NAT Gateway mode: single, per_az or disabled."
  type        = string
  default     = "single"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.34"
}

variable "endpoint_private_access" {
  description = "Enable private EKS API endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public EKS API endpoint."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["203.0.113.0/24"]
}

variable "node_instance_types" {
  description = "EKS managed node instance types."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_capacity_type" {
  description = "EKS node capacity type."
  type        = string
  default     = "SPOT"
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "EKS node disk size in GiB."
  type        = number
  default     = 30
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum RDS autoscaled storage in GiB."
  type        = number
  default     = 50
}

variable "rds_multi_az" {
  description = "Enable RDS Multi-AZ."
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention days."
  type        = number
  default     = 3
}

variable "rds_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip final RDS snapshot on destroy."
  type        = bool
  default     = true
}

variable "rds_final_snapshot_identifier" {
  description = "Final snapshot identifier when final snapshot is required."
  type        = string
  default     = null
}

variable "budget_enabled" {
  description = "Enable AWS Budget."
  type        = bool
  default     = false
}

variable "budget_monthly_limit_usd" {
  description = "Monthly budget limit in USD."
  type        = number
  default     = 50
}

variable "budget_notification_email" {
  description = "Budget notification email."
  type        = string
  default     = null
}

variable "github_allowed_subjects" {
  description = "Allowed GitHub OIDC subject claims."
  type        = list(string)
  default     = ["repo:utku9012/rentacar-backend-api:ref:refs/heads/main"]
}
