variable "repository_name" {
  description = "ECR repository name."
  type        = string
}

variable "release_image_retention_count" {
  description = "Number of tagged release images to retain."
  type        = number
  default     = 30

  validation {
    condition     = var.release_image_retention_count >= 10
    error_message = "Keep at least 10 release images to reduce accidental deletion risk."
  }
}

variable "untagged_image_expire_days" {
  description = "Number of days before untagged images expire."
  type        = number
  default     = 14

  validation {
    condition     = var.untagged_image_expire_days >= 1
    error_message = "Untagged image expiration must be at least 1 day."
  }
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
