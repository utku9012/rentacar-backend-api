# Argo CD Rollback

Preferred rollback is Git rollback:

```bash
git revert <gitops-deployment-commit>
```

After merge, Argo CD reconciles the previous image tag.

Emergency operational rollback:

```bash
argocd app history rentacar-api-production
argocd app rollback rentacar-api-production <history-id>
```

After operational rollback, update Git to match the running state. Otherwise Argo CD will eventually reconcile back to the newer Git state.

Database migrations may not be reversible. EF Core migrations must remain backward compatible with old and new application versions during rolling deployment.
