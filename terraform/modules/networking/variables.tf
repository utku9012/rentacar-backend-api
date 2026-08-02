variable "name_prefix" {
  description = "Prefix used for networking resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used by public, application and database subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private EKS application subnets."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)
}

variable "nat_gateway_mode" {
  description = "NAT Gateway mode: single for lower cost, per_az for higher availability, disabled only for special test networks."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "per_az", "disabled"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be single, per_az or disabled."
  }
}

variable "cluster_name" {
  description = "Optional EKS cluster name used for Kubernetes subnet discovery tags."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
