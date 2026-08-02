# EKS Prerequisites

The Helm chart assumes the cluster foundation exists but does not install cluster-level controllers.

Required or expected components:

- AWS Load Balancer Controller for ALB Ingress
- External Secrets Operator for AWS Secrets Manager
- Metrics Server for HPA
- EBS CSI driver, already prepared by Terraform EKS add-ons
- Optional Prometheus Operator for ServiceMonitor

Get Terraform outputs:

```bash
cd terraform/environments/dev
terraform output eks_cluster_name
terraform output ecr_repository_url
terraform output rds_endpoint
terraform output rds_secret_arn
```

Configure kubeconfig:

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name <cluster-name>
```

Always verify context:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes
```

Never run Helm against an unverified context.
