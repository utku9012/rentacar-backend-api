#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${API_BASE_URL:-${1:-http://localhost:8080}}"
TIMEOUT_SECONDS="${SMOKE_TEST_TIMEOUT_SECONDS:-60}"
SECONDS=0

log() {
  printf '[smoke-test] %s\n' "$1"
}

fail() {
  printf '[smoke-test] ERROR: %s\n' "$1" >&2
  exit 1
}

require_status() {
  local path="$1"
  local expected_status="${2:-200}"
  local status

  status="$(curl --silent --show-error --output /tmp/rentacar-smoke-response.txt --write-out '%{http_code}' "${BASE_URL}${path}")"

  if [[ "$status" != "$expected_status" ]]; then
    log "Response body for ${path}:"
    cat /tmp/rentacar-smoke-response.txt >&2 || true
    fail "Expected ${expected_status} from ${path}, got ${status}."
  fi

  log "${path} returned ${status}."
}

log "Using API base URL: ${BASE_URL}"
log "Waiting for readiness for up to ${TIMEOUT_SECONDS}s..."

while true; do
  if curl --silent --fail "${BASE_URL}/health/ready" >/dev/null; then
    log "API is ready."
    break
  fi

  if (( SECONDS >= TIMEOUT_SECONDS )); then
    fail "API did not become ready within ${TIMEOUT_SECONDS}s."
  fi

  sleep 2
done

require_status "/health/live"
require_status "/health/ready"
require_status "/api/vehicles"

log "Smoke test completed successfully."
