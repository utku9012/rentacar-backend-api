# AWS Cleanup

Terraform cleanup must be reviewed through a destroy plan first. This repository intentionally does not include a command that automatically destroys infrastructure.

## Development Cleanup

```bash
make terraform-destroy-plan ENV=dev
cd terraform/environments/dev
terraform show destroy-tfplan
```

Run `terraform destroy` only after manually confirming the account, region and resources.

## Production Cleanup

Production RDS has deletion protection enabled and requires a final snapshot. This is intentional. Disable protection only through a reviewed change and keep the final snapshot.

## State Cleanup

Do not delete the Terraform state bucket casually. It has versioning and `prevent_destroy` enabled. If state must be recovered, restore the required object version in S3 before running new Terraform operations.
