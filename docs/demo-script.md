# KijaniKiosk Capstone Demo Script

## Demo Goal

Show that the KijaniKiosk Track A system supports staging-first deployment, smoke-tested validation, approval-based production promotion, runtime observability, and receipt-chain integration.

## Demo Flow

1. Show repository structure.
   - Highlight `k8s/`, `infra/`, `scripts/`, `monitoring/`, `serverless/`, and root-level `Jenkinsfile`.

2. Show scope and architecture.
   - Open `docs/scope.md`.
   - Open `docs/architecture.png`.

3. Show k8s environment separation.
   - Show `k8s/staging/configmap.yaml`.
   - Show `k8s/production/configmap.yaml`.
   - Point out different `DB_HOST` and receipt bucket values.

4. Validate manifests.
   - Run `kubectl kustomize k8s/staging`.
   - Run `kubectl kustomize k8s/production`.

5. Show infrastructure automation.
   - Show Terraform staging namespace config.
   - Show Ansible staging playbook.
   - Explain Terraform provisions namespaces and Ansible applies configuration.

6. Show Jenkins pipeline.
   - Open root-level `Jenkinsfile`.
   - Explain stages: validate, deploy staging, smoke test, approval, deploy production.

7. Demonstrate staging deployment.
   - Run or show Jenkins deploying staging.
   - Show staging pods with `kubectl get pods -n kijani-staging`.

8. Demonstrate smoke test.
   - Run or show `./scripts/smoke-test-staging.sh`.
   - Confirm the smoke test passes.

9. Demonstrate approval gate.
   - Show Jenkins approval gate.
   - Enter or show approval reason.

10. Demonstrate production deployment.
   - Show production deployment after approval.
   - Show `kubectl get pods -n kijani-production`.

11. Demonstrate fault handling.
   - Show screenshot fallback where a deliberate staging fault causes smoke test failure.
   - Explain that production promotion is blocked when staging validation fails.

12. Show monitoring.
   - Open `monitoring/prometheus/kk-payments-alerts.yaml`.
   - Explain pod restart and unavailable replica alerts.

13. Show receipt-chain validation.
   - Run or show `npx serverless@3 print --stage staging`.
   - Point out `RECEIPT_BUCKET=kk-payments-receipts-staging`.

14. Close with handover.
   - Show README instructions.
   - Explain how a new engineer can reproduce the system.
