# RentACar GitOps

This directory models the future `rentacar-gitops` repository. Git is the source of truth for deployment state: image tags, Helm values, replica counts, resources, ingress settings and environment promotion.

No Kubernetes Secret values belong in this repository.

## Flow

```text
Application commit
-> GitHub Actions tests and scans
-> Docker image pushed to ECR with full Git SHA tag
-> GitOps values updated
-> Argo CD reconciles EKS
```

## Environments

- `dev`: automated sync, prune and self-heal enabled.
- `staging`: automated sync after promotion PR is merged.
- `production`: manual sync after approved production promotion.
- `observability-*`: platform metrics, logs and tracing applications.

## Bootstrap

Apply `bootstrap/app-project.yaml` and `bootstrap/observability-project.yaml` first, then `bootstrap/root-application.yaml`.
