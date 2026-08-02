# Database Migrations

The API must not run EF Core migrations from every application pod. The chart creates a dedicated Kubernetes Job that runs:

```bash
dotnet RentACarApi.dll --migrate
```

The Job uses the same image tag and database secret as the API. It has a retry limit, timeout, non-root security context and completed-job cleanup.

By default the Job uses Helm hooks:

```yaml
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-weight: "-5"
helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
```

Helm hooks are simple for manual deployment, but they are harder to observe and reconcile in GitOps flows. Phase 5 should replace this with an Argo CD PreSync migration Job.

Helm rollback does not reverse database migrations. Migrations must remain backward compatible with the previously deployed application version.
