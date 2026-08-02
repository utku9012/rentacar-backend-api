# Kubernetes Troubleshooting

Useful commands:

```bash
kubectl describe pod <pod> -n rentacar-dev
kubectl logs <pod> -n rentacar-dev
kubectl logs <pod> -n rentacar-dev --previous
kubectl describe deployment rentacar-api -n rentacar-dev
kubectl describe job <migration-job> -n rentacar-dev
kubectl get events -n rentacar-dev --sort-by=.metadata.creationTimestamp
kubectl describe ingress rentacar-api -n rentacar-dev
helm status rentacar-api -n rentacar-dev
helm get values rentacar-api -n rentacar-dev
helm get manifest rentacar-api -n rentacar-dev
```

Common causes:

- `ImagePullBackOff`: ECR repository, image tag, node IAM permissions or imagePullSecrets are wrong.
- `CrashLoopBackOff`: app configuration, read-only filesystem issue or missing runtime dependency.
- Readiness failures: database connection, migration failure or RDS security group rules.
- Missing Secret: create temporary `rentacar-database` secret or enable ExternalSecret correctly.
- Ingress has no address: AWS Load Balancer Controller is missing or annotations are invalid.
- HPA metrics unknown: Metrics Server is missing or resource requests are absent.
- Pods pending: node capacity, affinity, taints or topology spread constraints are too strict.

Rollback:

```bash
helm history rentacar-api -n rentacar-dev
helm rollback rentacar-api <revision> -n rentacar-dev
helm uninstall rentacar-api -n rentacar-dev
```

Helm uninstall does not delete RDS. Helm rollback does not reverse database migrations.
