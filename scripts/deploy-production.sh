#!/usr/bin/env bash
set -euo pipefail

echo "Deploying kk-payments to production..."

kubectl apply -k k8s/production

echo "Waiting for production deployment rollout..."
kubectl rollout status deployment/kk-payments -n kijani-production --timeout=120s

echo "Production deployment completed successfully."
