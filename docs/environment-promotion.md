# Environment Promotion

Promotion uses the same ECR image artifact through all environments.

```text
Development
-> Staging
-> Production
```

Recommended flow:

1. Merge application source.
2. CI builds and scans the image.
3. CI pushes `ECR_REPOSITORY:GITHUB_SHA`.
4. CI updates development GitOps values.
5. Argo CD syncs development automatically.
6. A staging promotion PR copies the same image tag from development.
7. A production promotion PR copies the same image tag from staging.
8. Production sync is manual or protected by an approved environment.

Production is not updated directly by ordinary source pushes.

Branch protection recommendations:

- Source repo `main`: require CI, tests, scans and review.
- GitOps repo `main`: require YAML validation, Helm rendering, policy checks and review.
- Production paths: require code owner approval.

Deployment evidence to attach after a real cluster test:

- Successful source CI run.
- ECR image pushed with the immutable Git SHA tag.
- GitOps commit updating the development image tag and digest.
- Argo CD application status showing `Synced` and `Healthy`.
- Kubernetes pod using the expected image digest.
- Successful PreSync migration Job.
- Successful PostSync smoke-test Job.
- Drift correction demonstration in development.
- Staging promotion pull request.
- Production promotion approval record.

Do not fabricate screenshots or command output; add real evidence after the first EKS validation.
