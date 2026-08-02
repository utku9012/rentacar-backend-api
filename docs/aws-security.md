# AWS Security Decisions

## Authentication

Terraform does not hardcode AWS credentials. Use one of:

- AWS CLI profile
- AWS environment variables
- GitHub Actions OIDC
- AWS identity federation

## IAM Role Separation

- EKS node IAM role: permissions needed by EC2 worker nodes to join and operate in EKS.
- EKS Pod Identity role: future per-workload AWS permissions. Do not give every pod broad access through the node role.
- GitHub Actions OIDC role: CI/CD federation from GitHub to AWS. The current role is limited to publishing images to the RentACar ECR repository.

## Security Groups

RDS only allows PostgreSQL traffic from approved application security groups. There is no `0.0.0.0/0` ingress to port `5432`. SSH ingress is not created. Use AWS Systems Manager or Kubernetes-native administration patterns instead of direct SSH.

## Secrets

RDS uses AWS-managed master credentials stored in Secrets Manager. Terraform outputs the secret ARN as sensitive and never outputs plaintext passwords.

## CI Security

Terraform CI performs formatting, validation, TFLint, Checkov and Trivy config checks without AWS credentials. Future apply workflows should use protected GitHub environments and separate roles for plan and apply.
