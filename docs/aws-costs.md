# AWS Cost Notes

This foundation can create ongoing AWS costs. The largest cost drivers are usually:

- EKS control plane
- NAT Gateway hourly and data processing charges
- RDS instance, storage and backups
- Future load balancers
- CloudWatch log ingestion and retention

Development is intentionally cost-conscious but not highly available. Production settings should not weaken security or reliability just to reduce cost.

## Budget Module

Each environment can enable an AWS Budget:

```hcl
budget_enabled            = true
budget_monthly_limit_usd  = 50
budget_notification_email = "replace-with-email@example.com"
```

No personal email address is committed. The budget is optional because some AWS accounts centralize budgets outside project Terraform.

## Teardown

For short-lived development experiments, prefer reviewing a destroy plan before removing resources:

```bash
make terraform-destroy-plan ENV=dev
```

This only creates a plan. It does not destroy anything.
