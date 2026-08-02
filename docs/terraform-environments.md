# Terraform Environments

Environment roots live under:

- `terraform/environments/dev`
- `terraform/environments/staging`
- `terraform/environments/production`

Each root calls the reusable modules under `terraform/modules`. Resource implementations are not copied into environment folders.

## Development

Development defaults favor cost:

- Single NAT Gateway
- One Spot worker node initially
- Small single-AZ RDS instance
- Short backup retention
- Deletion protection disabled

## Staging

Staging stays production-like while keeping capacity smaller:

- At least two workers
- Production-like networking
- Smaller RDS and EKS capacity than production
- GitHub OIDC subject can target the `staging` GitHub environment

## Production

Production defaults favor resilience:

- NAT Gateway per AZ
- On-demand worker nodes
- Multiple workers
- Multi-AZ RDS
- Longer backup retention
- Deletion protection enabled
- Final snapshot required
- EKS public endpoint disabled by default

## Commands

```bash
cd terraform/environments/dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars

terraform init -backend-config=backend.hcl
terraform fmt -check
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform show tfplan
```

Do not commit `backend.hcl`, `terraform.tfvars`, `tfplan`, `.terraform/`, `.terraform.lock.hcl`, `terraform.tfstate` or `terraform.tfstate.*`.
