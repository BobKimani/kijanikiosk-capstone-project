#!/usr/bin/env bash
set -euo pipefail

echo "Deploying kk-payments to staging..."

kubectl apply -k k8s/staging

echo "Waiting for staging deployment rollout..."
kubectl rollout status deployment/kk-payments -n kijani-staging --timeout=120s

echo "Staging deployment completed successfully."
