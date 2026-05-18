#!/usr/bin/env bash
set -euo pipefail

BUCKET="${1:-kk-payments-receipts-staging}"
RECEIPT_ID="manual-verification-$(date +%Y%m%d%H%M%S)"
TMP_FILE="/tmp/${RECEIPT_ID}.json"

cat > "${TMP_FILE}" <<JSON
{
  "receiptId": "${RECEIPT_ID}",
  "source": "capstone-verification",
  "environment": "staging",
  "amount": 1250,
  "currency": "KES",
  "customerPhone": "+254700000000",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

echo "Uploading verification receipt to s3://${BUCKET}/${RECEIPT_ID}.json"

aws s3 cp "${TMP_FILE}" "s3://${BUCKET}/${RECEIPT_ID}.json"

echo "Receipt uploaded. Check serverless function logs to confirm the receipt chain fired."
