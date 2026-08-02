# Kubernetes Deployment

Recommended namespaces:

- `rentacar-dev`
- `rentacar-staging`
- `rentacar-production`

## Prerequisites

- EKS cluster from Terraform
- AWS Load Balancer Controller for Ingress
- External Secrets Operator for AWS Secrets Manager integration
- Metrics Server for HPA
- EBS CSI driver from EKS add-ons
- Optional Prometheus Operator for ServiceMonitor

## Initial Workflow

Confirm ECR image:

```bash
aws ecr describe-images --repository-name rentacar-api
```

Verify Kubernetes context:

```bash
aws eks update-kubeconfig --region eu-central-1 --name <cluster-name>
kubectl config current-context
kubectl cluster-info
kubectl get nodes
```

Create namespace:

```bash
kubectl create namespace rentacar-dev
```

Temporary development database secret:

```bash
kubectl create secret generic rentacar-database \
  --namespace rentacar-dev \
  --from-literal=ConnectionStrings__DefaultConnection='<connection-string>'
```

This is only for initial manual testing. Production should use External Secrets Operator.

Dry run:

```bash
helm upgrade --install rentacar-api helm/rentacar-api \
  --namespace rentacar-dev \
  --create-namespace \
  -f helm/rentacar-api/values-dev.yaml \
  --set image.repository=<ecr-url> \
  --set image.tag=<commit-sha> \
  --dry-run
```

Deploy:

```bash
helm upgrade --install rentacar-api helm/rentacar-api \
  --namespace rentacar-dev \
  --create-namespace \
  -f helm/rentacar-api/values-dev.yaml \
  --set image.repository=<ecr-url> \
  --set image.tag=<commit-sha> \
  --atomic \
  --timeout 10m
```

Validate:

```bash
kubectl get pods -n rentacar-dev
kubectl get deployment -n rentacar-dev
kubectl get service -n rentacar-dev
kubectl get ingress -n rentacar-dev
kubectl get hpa -n rentacar-dev
kubectl get jobs -n rentacar-dev
kubectl rollout status deployment/rentacar-api -n rentacar-dev
helm test rentacar-api -n rentacar-dev
```

Port-forward test:

```bash
kubectl port-forward service/rentacar-api 8080:80 -n rentacar-dev
```

Check:

```text
http://localhost:8080/health/live
http://localhost:8080/health/ready
http://localhost:8080/swagger
http://localhost:8080/metrics
```
