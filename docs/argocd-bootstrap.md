# Argo CD Bootstrap

Argo CD is installed separately from the application Helm chart.

Pinned version used by the Makefile:

```text
v2.13.3
```

Validate context first:

```bash
kubectl config current-context
kubectl cluster-info
```

Install:

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.13.3/manifests/install.yaml
```

Bootstrap AppProject and root Application:

```bash
kubectl apply -f gitops/bootstrap/app-project.yaml
kubectl apply -f gitops/bootstrap/observability-project.yaml
kubectl apply -f gitops/bootstrap/root-application.yaml
```

For initial access, prefer port-forwarding:

```bash
kubectl port-forward service/argocd-server -n argocd 8081:443
```

Do not expose the Argo CD API server publicly without authentication and TLS.

Repository credentials should be configured through Argo CD CLI, External Secrets, Sealed Secrets or a Secret created outside Git. `gitops/bootstrap/repositories.example.yaml` contains placeholders only.
