# Helm Chart

The canonical chart is `helm/rentacar-api`. The older `deploy/helm` chart was removed to avoid duplicate deployment definitions.

The chart includes:

- Deployment
- Service
- Ingress
- ConfigMap
- ExternalSecret
- ServiceAccount
- EF Core migration Job
- HPA
- PodDisruptionBudget
- NetworkPolicy
- optional ServiceMonitor
- Helm test pod

```mermaid
flowchart TD
    User --> ALB["Future AWS Application Load Balancer"]

    ALB --> Service["Kubernetes Service"]

    Service --> Pod1["Rent-a-Car API Pod"]
    Service --> Pod2["Rent-a-Car API Pod"]

    Pod1 --> RDS[("Amazon RDS PostgreSQL")]
    Pod2 --> RDS

    Secrets["AWS Secrets Manager"] --> ESO["External Secrets Operator"]
    ESO --> K8sSecret["Kubernetes Secret"]
    K8sSecret --> Pod1
    K8sSecret --> Pod2

    Migration["EF Core Migration Job"] --> RDS
```

The ALB, External Secrets Operator, Metrics Server and Prometheus Operator are prerequisites or future components. They are not installed by this chart.

## Values Hierarchy

- `values.yaml`: secure base defaults.
- `values-dev.yaml`: 1 replica, lower resources, Swagger enabled, HPA/PDB/NetworkPolicy disabled by default.
- `values-staging.yaml`: 2 replicas, HPA, PDB and NetworkPolicy enabled.
- `values-production.yaml`: 2+ replicas, HPA, PDB, NetworkPolicy, TLS-ready ingress and ExternalSecret enabled.

## Image Tagging

Set image values during install:

```bash
--set image.repository=<ecr-url> \
--set image.tag=<commit-sha>
```

The chart fails if image repository or tag is empty, and it rejects `latest`.
