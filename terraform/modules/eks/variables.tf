variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region used for regional service principals."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by managed node groups."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable inside the VPC."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable publicly."
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint. Do not use 0.0.0.0/0 for production."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Managed node group capacity type."
  type        = string

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum managed node group size."
  type        = number
}

variable "node_desired_size" {
  description = "Desired managed node group size."
  type        = number
}

variable "node_max_size" {
  description = "Maximum managed node group size."
  type        = number
}

variable "node_disk_size" {
  description = "Worker node root disk size in GiB."
  type        = number
  default     = 30
}

variable "node_labels" {
  description = "Labels applied to managed node group nodes."
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Optional taints applied to managed node group nodes."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "control_plane_log_retention_days" {
  description = "CloudWatch retention for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "access_entries" {
  description = "Optional EKS access entries for human or CI principals."
  type = list(object({
    principal_arn = string
    policy_arn    = string
    access_type   = optional(string, "cluster")
    namespaces    = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
