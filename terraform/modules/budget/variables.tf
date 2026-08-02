variable "enabled" {
  description = "Whether to create an AWS monthly cost budget."
  type        = bool
  default     = false
}

variable "name" {
  description = "Budget name."
  type        = string
}

variable "monthly_limit_usd" {
  description = "Monthly budget limit in USD."
  type        = number
}

variable "notification_email" {
  description = "Email address for budget alerts."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project tag used to scope the budget."
  type        = string
}

variable "environment" {
  description = "Environment tag used to scope the budget."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to resources."
  type        = map(string)
  default     = {}
}
