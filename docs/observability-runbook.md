# Observability Runbook

Bootstrap order:

```bash
kubectl apply -f gitops/bootstrap/app-project.yaml
kubectl apply -f gitops/bootstrap/observability-project.yaml
kubectl apply -f gitops/bootstrap/root-application.yaml
```

Argo CD should then discover:

```bash
argocd app get observability-kube-prometheus-stack
argocd app get observability-loki
argocd app get observability-promtail
argocd app get observability-otel-collector
```

Useful checks:

```bash
kubectl get pods -n observability
kubectl get servicemonitors,prometheusrules -n rentacar-dev
kubectl get configmap -n rentacar-dev -l grafana_dashboard=1
kubectl logs deployment/opentelemetry-collector -n observability
kubectl logs daemonset/promtail -n observability
```

Local port-forward examples:

```bash
kubectl port-forward service/kube-prometheus-stack-grafana -n observability 3000:80
kubectl port-forward service/kube-prometheus-stack-prometheus -n observability 9090:9090
kubectl port-forward service/loki-gateway -n observability 3100:80
```

Expected signals:

- Prometheus target for `rentacar-api` is `UP`.
- `/metrics` exposes ASP.NET Core HTTP request counters and histograms.
- Grafana discovers `RentACar API` dashboard from ConfigMap sidecar labels.
- Loki receives container logs with namespace, pod, container and app labels.
- OpenTelemetry Collector receives traces when API tracing is enabled.

Common issues:

- `ServiceMonitor` missing: Prometheus Operator is not installed or the CRD is unavailable.
- Prometheus target down: network policy, service labels or `/metrics` path is wrong.
- Dashboard not visible: Grafana sidecar is not searching all namespaces or label does not match.
- Loki empty: Promtail has no node permissions or Loki gateway URL is wrong.
- Traces missing: tracing is disabled, endpoint is wrong or Collector is unavailable.
- Collector logs only debug output: this is expected until a trace backend is configured.

Security notes:

- Grafana admin credentials must come from a Kubernetes Secret, not Git.
- Grafana, Prometheus and Loki are ClusterIP by default.
- Public ingress for observability tools should require authentication and TLS.
- Retention and persistence settings are intentionally modest for the first EKS test.
