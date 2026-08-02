# Drift Detection

Argo CD detects differences between Git and cluster state.

Development drift test:

```bash
kubectl scale deployment rentacar-api --replicas=4 -n rentacar-dev
argocd app get rentacar-api-dev
```

With self-heal enabled, Argo CD should restore the replica count from Git.

Do not run drift experiments in production without approval.

Pruning is enabled for development and staging. It removes resources deleted from Git. Production pruning should be used carefully and must not manage RDS deletion.

Ignore rules are intentionally narrow. HPA-managed replica count is ignored for Deployment diffing; broad ignore rules should not be added because they hide real drift.
