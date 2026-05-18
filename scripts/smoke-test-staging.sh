#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="kijani-staging"
SERVICE_URL="http://kk-payments.${NAMESPACE}.svc.cluster.local:3000/health"

echo "Running staging smoke test against ${SERVICE_URL}..."

kubectl run kk-payments-smoke-test \
  --rm -i \
  --restart=Never \
  --image=curlimages/curl:8.10.1 \
  -n "${NAMESPACE}" \
  -- curl -fsS "${SERVICE_URL}"

echo "Staging smoke test passed."
