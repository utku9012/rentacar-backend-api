# Argo CD Troubleshooting

Commands:

```bash
argocd app get rentacar-api-dev
argocd app diff rentacar-api-dev
argocd app manifests rentacar-api-dev
argocd app resources rentacar-api-dev
argocd app history rentacar-api-dev

kubectl get applications -n argocd
kubectl describe application rentacar-api-dev -n argocd
kubectl logs deployment/argocd-application-controller -n argocd
kubectl logs deployment/argocd-repo-server -n argocd
kubectl logs deployment/argocd-server -n argocd
```

Common causes:

- Repository authentication failure: repo Secret or Argo CD credential is wrong.
- Invalid Helm values: render locally with the same GitOps values file.
- Missing chart path: verify `helm/rentacar-api` exists at the selected source revision.
- Missing namespace: enable `CreateNamespace=true` or apply namespace manifests.
- PreSync migration failure: inspect the migration Job and database connectivity.
- PostSync smoke failure: check service readiness and `/api/vehicles`.
- ImagePullBackOff: ECR auth, image repository or immutable tag is wrong.
- ExternalSecret not ready: External Secrets Operator or AWS secret reference is missing.
- Application OutOfSync: compare Git and cluster with `argocd app diff`.
- Production sync blocked: check approval process and sync policy.

Expected Argo CD states:

- Migration Job fails: application remains `OutOfSync` or `Degraded`; later waves should not complete.
- Deployment cannot become healthy: application becomes `Progressing` and then `Degraded`.
- Readiness probe fails: pods stay unready and Argo CD reports degraded health for the workload.
- Image cannot be pulled: pods show `ImagePullBackOff`; Argo CD reports the application as not healthy.
- ExternalSecret is unavailable: Secret is missing or stale; migration and Deployment fail to start or become ready.
- PostSync smoke test fails: sync is visible as failed and the hook Job logs contain the failing request.
- Ingress cannot be created: Ingress or controller events explain the failure; application may remain `Progressing` or `Degraded`.

Do not hide failures with broad health customizations.
