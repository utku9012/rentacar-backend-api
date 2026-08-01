variable "project_name" {
  description = "Name prefix used for AWS resources."
  type        = string
  default     = "rentacar"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used for public and private subnets."
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "db_name" {
  description = "RDS PostgreSQL database name."
  type        = string
  default     = "rentacardb"
}

variable "db_username" {
  description = "RDS PostgreSQL master username."
  type        = string
  default     = "rentacar"
}

variable "db_password" {
  description = "RDS PostgreSQL master password. Pass this with TF_VAR_db_password or a tfvars file outside git."
  type        = string
  sensitive   = true
}

variable "node_instance_types" {
  description = "EKS managed node group instance types."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.36"
}
