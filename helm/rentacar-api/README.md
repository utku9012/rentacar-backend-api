# RentACar API Helm Chart

This chart packages the Rent-a-Car ASP.NET Core API for Kubernetes and Amazon EKS.

## Versioning

- Chart version: version of this Helm package.
- Application version: logical API application version in `Chart.yaml`.
- Docker image tag: immutable image identifier, usually a commit SHA pushed to ECR.

The Docker image tag must never be `latest`.

## Install Example

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

## Secrets

The API expects `ConnectionStrings__DefaultConnection` from a Kubernetes Secret. For production, use External Secrets Operator with AWS Secrets Manager. For manual development testing, a pre-created Kubernetes Secret can be used.

## Migrations

The EF Core migration Job runs `dotnet RentACarApi.dll --migrate` through a Helm hook by default. A later GitOps phase should replace this with an Argo CD PreSync Job.
