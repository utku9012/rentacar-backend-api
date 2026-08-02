# GitOps Image Update

The script `scripts/update-gitops-image.sh` updates only the intended environment values file.

Example:

```bash
./scripts/update-gitops-image.sh \
  dev \
  "$ECR_REPOSITORY" \
  "$GITHUB_SHA" \
  "$IMAGE_DIGEST"
```

The script:

- uses strict Bash mode
- validates `dev`, `staging` or `production`
- rejects `latest`, `main` and `stable`
- uses `yq`
- updates repository, tag, digest and commit metadata
- refuses production unless `ALLOW_PRODUCTION_UPDATE=true`
- prints the resulting diff

GitHub Actions uses OIDC for AWS authentication and a fine-grained `GITOPS_REPO_TOKEN` for GitOps repository writes. For production organizations, prefer a GitHub App.
