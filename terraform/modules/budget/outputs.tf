output "budget_name" {
  description = "Budget name when enabled."
  value       = var.enabled ? aws_budgets_budget.monthly[0].name : null
}

output "budget_arn" {
  description = "Budget ARN when enabled."
  value       = var.enabled ? aws_budgets_budget.monthly[0].arn : null
}
