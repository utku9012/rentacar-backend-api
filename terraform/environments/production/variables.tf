variable "project_name" {
  type    = string
  default = "rentacar"
}

variable "environment" {
  type    = string
  default = "production"
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
  default = "10.60.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.0.0/20", "10.60.16.0/20", "10.60.32.0/20"]
}

variable "private_app_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.48.0/20", "10.60.64.0/20", "10.60.80.0/20"]
}

variable "private_db_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.96.0/20", "10.60.112.0/20", "10.60.128.0/20"]
}

variable "nat_gateway_mode" {
  type    = string
  default = "per_az"
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
  default = "ON_DEMAND"
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
  default = 6
}

variable "node_disk_size" {
  type    = number
  default = 50
}

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "rds_allocated_storage" {
  type    = number
  default = 50
}

variable "rds_max_allocated_storage" {
  type    = number
  default = 200
}

variable "rds_multi_az" {
  type    = bool
  default = true
}

variable "rds_backup_retention_period" {
  type    = number
  default = 30
}

variable "rds_deletion_protection" {
  type    = bool
  default = true
}

variable "rds_skip_final_snapshot" {
  type    = bool
  default = false
}

variable "rds_final_snapshot_identifier" {
  type    = string
  default = "rentacar-production-postgres-final-snapshot"
}

variable "budget_enabled" {
  type    = bool
  default = false
}

variable "budget_monthly_limit_usd" {
  type    = number
  default = 300
}

variable "budget_notification_email" {
  type    = string
  default = null
}

variable "github_allowed_subjects" {
  type    = list(string)
  default = ["repo:utku9012/rentacar-backend-api:environment:production"]
}
