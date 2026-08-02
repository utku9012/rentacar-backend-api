# Terraform Bootstrap

The bootstrap stack creates the S3 bucket used for Terraform remote state. Bootstrap starts with local Terraform state because the remote state bucket does not exist yet.

## Resources

- S3 bucket for Terraform state
- Bucket versioning
- Server-side encryption
- Public access block
- Lifecycle retention for recoverable old state versions
- `prevent_destroy` on the state bucket

## Commands

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```

Run `terraform apply tfplan` only after reviewing the plan and confirming the AWS account and region. Do not commit `terraform.tfvars`, `tfplan`, `.terraform/` or state files.

## Backend Initialization

After bootstrap is applied, create `backend.hcl` in each environment from `backend.hcl.example`.

```hcl
bucket       = "replace-with-terraform-state-bucket"
key          = "rentacar/dev/terraform.tfstate"
region       = "eu-central-1"
encrypt      = true
use_lockfile = true
```

The backend uses native S3 lock files through `use_lockfile = true`; no DynamoDB locking table is created.

## State Recovery

State bucket versioning is enabled. If state is corrupted, recover a previous object version from S3 after stopping all Terraform operations. Keep recovery steps manual and deliberate.
