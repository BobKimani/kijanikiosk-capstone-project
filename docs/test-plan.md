# KijaniKiosk Capstone Test Plan

## Purpose

This test plan verifies that the KijaniKiosk Track A Infrastructure-First capstone works as a production-approaching DevOps delivery system.

The tests focus on infrastructure reproducibility, k8s runtime configuration, CI/CD deployment flow, smoke testing, production approval, monitoring, and receipt-chain integration.

## Test Scope

The following areas are included:

1. k8s manifest rendering
2. Terraform validation
3. Ansible syntax validation
4. Deployment script validation
5. Serverless receipt-chain configuration validation
6. Staging deployment verification
7. Staging smoke test verification
8. Production deployment verification
9. Fault handling verification
10. Prometheus alert rule verification

## Test Cases

| ID | Test Area | Command / Action | Expected Result | Status |
|---|---|---|---|---|
| T1 | k8s staging render | `kubectl kustomize k8s/staging` | Staging manifests render without errors | Passed |
| T2 | k8s production render | `kubectl kustomize k8s/production` | Production manifests render without errors | Passed |
| T3 | Terraform staging validation | `terraform validate` in `infra/terraform/staging` | Configuration is valid | Passed |
| T4 | Terraform production validation | `terraform validate` in `infra/terraform/production` | Configuration is valid | Passed |
| T5 | Ansible staging syntax | `ansible-playbook -i infra/ansible/inventories/staging.ini infra/ansible/playbooks/configure-staging.yml --syntax-check` | Syntax check passes | Passed |
| T6 | Ansible production syntax | `ansible-playbook -i infra/ansible/inventories/production.ini infra/ansible/playbooks/configure-production.yml --syntax-check` | Syntax check passes | Passed |
| T7 | Shell script syntax | `bash -n scripts/*.sh` | No syntax errors | Passed |
| T8 | Serverless config render | `npx serverless@3 print --stage staging` | Receipt bucket resolves to `kk-payments-receipts-staging` | Passed |
| T9 | Staging deployment | `./scripts/deploy-staging.sh` | Staging rollout completes | Passed |
| T10 | Staging smoke test | `./scripts/smoke-test-staging.sh` | Smoke test passes before production approval | Passed |
| T11 | Production deployment | `./scripts/deploy-production.sh` | Production rollout completes after approval | Passed |
| T12 | Fault handling | Introduce temporary staging health-check fault | Smoke test fails and production promotion is blocked | Passed / Demo Evidence Required |
| T13 | Prometheus alert rule | Review `monitoring/prometheus/kk-payments-alerts.yaml` | Meaningful health alert rules exist | Passed |

## Evidence

Screenshots and command outputs should be saved in:

`docs/demo-evidence/`

Recommended evidence files:

- `01-k8s-staging-render.png`
- `02-k8s-production-render.png`
- `03-terraform-validate.png`
- `04-ansible-syntax-check.png`
- `05-serverless-print-staging.png`
- `06-jenkins-pipeline-success.png`
- `07-approval-gate.png`
- `08-fault-handling-smoke-test-fail.png`
