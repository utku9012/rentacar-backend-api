#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <dev|staging|production> <image-repository> <image-tag> [image-digest]" >&2
}

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  usage
  exit 2
fi

environment="$1"
image_repository="$2"
image_tag="$3"
image_digest="${4:-}"

export image_repository
export image_tag
export image_digest

case "$environment" in
  dev|staging)
    ;;
  production)
    if [ "${ALLOW_PRODUCTION_UPDATE:-false}" != "true" ]; then
      echo "Refusing to update production without ALLOW_PRODUCTION_UPDATE=true." >&2
      exit 3
    fi
    ;;
  *)
    echo "Invalid environment: $environment" >&2
    usage
    exit 2
    ;;
esac

if [ -z "$image_repository" ]; then
  echo "image repository is required" >&2
  exit 2
fi

if [ -z "$image_tag" ] || [ "$image_tag" = "latest" ] || [ "$image_tag" = "main" ] || [ "$image_tag" = "stable" ]; then
  echo "image tag must be an immutable tag, usually the full Git SHA" >&2
  exit 2
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "yq is required. Install mikefarah/yq v4 or run this script in CI with yq installed." >&2
  exit 127
fi

gitops_root="${GITOPS_ROOT:-gitops}"
relative_values_file="environments/${environment}/values.yaml"
values_file="${gitops_root}/${relative_values_file}"

if [ ! -f "$values_file" ]; then
  echo "Expected values file not found: $values_file" >&2
  exit 4
fi

if [ "$(yq '.image.repository // ""' "$values_file")" = "" ]; then
  echo "Missing .image.repository in $values_file" >&2
  exit 5
fi

if [ "$(yq '.image.tag // ""' "$values_file")" = "" ]; then
  echo "Missing .image.tag in $values_file" >&2
  exit 5
fi

yq -i '.image.repository = strenv(image_repository)' "$values_file"
yq -i '.image.tag = strenv(image_tag)' "$values_file"
yq -i '.gitops.commitSha = strenv(image_tag)' "$values_file"

if [ -n "$image_digest" ]; then
  yq -i '.image.digest = strenv(image_digest)' "$values_file"
fi

if git -C "$gitops_root" diff --quiet -- "$relative_values_file"; then
  echo "No GitOps image change required for $environment."
  exit 0
fi

echo "Updated $values_file:"
git -C "$gitops_root" diff -- "$relative_values_file"
