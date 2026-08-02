variable "project_name" {
  type    = string
  default = "rentacar"
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type    = string
  default = null
}

variable "owner" {
  type = string
}

variable "repository" {
  type    = string
  default = "utku9012/rentacar-backend-api"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.0.0/20", "10.50.16.0/20"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.32.0/20", "10.50.48.0/20"]
}

variable "private_db_subnet_cidrs" {
  type    = list(string)
  default = ["10.50.64.0/20", "10.50.80.0/20"]
}

variable "nat_gateway_mode" {
  type    = string
  default = "single"
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["203.0.113.0/24"]
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_disk_size" {
  type    = number
  default = 40
}

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "rds_allocated_storage" {
  type    = number
  default = 30
}

variable "rds_max_allocated_storage" {
  type    = number
  default = 100
}

variable "rds_multi_az" {
  type    = bool
  default = false
}

variable "rds_backup_retention_period" {
  type    = number
  default = 7
}

variable "rds_deletion_protection" {
  type    = bool
  default = false
}

variable "rds_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "rds_final_snapshot_identifier" {
  type    = string
  default = null
}

variable "budget_enabled" {
  type    = bool
  default = false
}

variable "budget_monthly_limit_usd" {
  type    = number
  default = 100
}

variable "budget_notification_email" {
  type    = string
  default = null
}

variable "github_allowed_subjects" {
  type    = list(string)
  default = ["repo:utku9012/rentacar-backend-api:environment:staging"]
}
