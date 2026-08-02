# Kubernetes Security

## Pod Security

The chart defaults to:

- `runAsNonRoot: true`
- UID/GID `1654`, matching the non-root Docker runtime user
- `readOnlyRootFilesystem: true`
- `allowPrivilegeEscalation: false`
- drop all Linux capabilities
- writable `emptyDir` only for `/tmp`

## Service Account

The chart creates a dedicated service account and disables token automounting by default. The API does not need Kubernetes API access.

Service account annotations are supported for future EKS Pod Identity usage.

## Secrets

The database connection string must come from a Secret. It is not stored in ConfigMap or plain values. Production should use AWS Secrets Manager through External Secrets Operator.

## NetworkPolicy

Staging and production values enable NetworkPolicy. The policy allows ingress from the ingress controller path and optional monitoring namespace. Egress allows DNS and optional CIDR-based RDS access.

Kubernetes NetworkPolicy cannot target an RDS security group by identity, so RDS egress is CIDR-based when enabled. Keep the CIDR narrow and update it from Terraform subnet outputs.
