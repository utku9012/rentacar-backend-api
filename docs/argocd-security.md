# Argo CD Security

The RentACar AppProject restricts destinations to:

- `rentacar-dev`
- `rentacar-staging`
- `rentacar-production`

It allows only required Kubernetes resource kinds. It does not grant arbitrary cluster-wide administration.

RBAC examples:

- Developer: view dev/staging, sync dev only.
- Operator: view all, sync staging.
- Admin: full administration.

Do not commit repository tokens or passwords. Use Argo CD CLI, External Secrets, Sealed Secrets, SOPS or manually created Kubernetes Secrets.

Production sync should require explicit approval. The Makefile refuses production sync and rollback unless `ALLOW_PRODUCTION_SYNC=true`.

Notifications are prepared with placeholder webhook config in `gitops/bootstrap/notifications.example.yaml`; real webhook URLs must come from secret management.
