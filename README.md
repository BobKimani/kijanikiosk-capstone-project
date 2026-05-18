# KijaniKiosk Capstone

Production-approaching DevOps capstone for KijaniKiosk, built for Moringa School using the Track A: Infrastructure-First option.

## 1. Project Overview

KijaniKiosk is a DevOps capstone repository that demonstrates a staging-first delivery workflow for the `kk-payments` service. The project brings together a small Node.js/Express payments API, a Docker image definition, reusable k8s manifests, environment-specific runtime configuration, Terraform namespace configuration, Ansible environment configuration, a root-level Jenkins CI/CD pipeline, staging smoke testing, manual production approval, Prometheus alert rules, and a serverless receipt-chain configuration.

This repository is intended as a final handover guide for a new engineer who needs to understand, validate, and operate the capstone safely.

## 2. Selected Track

Selected track: **Track A: Infrastructure-First**

The capstone focuses on infrastructure automation, runtime environment separation, deployment flow, validation, and operational handover. It does not attempt to rebuild the full KijaniKiosk application or claim a fully production-grade platform.

## 3. Problem Being Solved

The project addresses the gap between having separate DevOps artifacts and having a coherent delivery workflow. Before this capstone, the project components existed as individual pieces: k8s manifests, Terraform, Ansible, Jenkins pipeline work, monitoring, and serverless receipt processing.

This capstone connects those pieces into a production-approaching workflow where:

- Staging and production are isolated at the k8s namespace level.
- Shared manifests are reused through Kustomize overlays.
- Staging is deployed and smoke-tested before production is considered.
- Production deployment requires a manual approval reason.
- Runtime health signals are represented through committed Prometheus alert rules.
- Receipt-chain configuration is connected through environment-specific receipt bucket values.

## 4. Architecture

The architecture is organized around a staging-first deployment path:

1. A Jenkins pipeline checks out the repository.
2. Jenkins renders the staging and production k8s overlays with `kubectl kustomize`.
3. Jenkins deploys to staging using `scripts/deploy-staging.sh`.
4. Jenkins runs `scripts/smoke-test-staging.sh` against the in-cluster staging service health endpoint.
5. If the smoke test passes, Jenkins pauses for a manual production approval reason.
6. After approval, Jenkins deploys production using `scripts/deploy-production.sh`.
7. Prometheus alert rules define restart and unavailable-replica signals for `kk-payments`.
8. The receipt-chain configuration uses Serverless Framework configuration under `serverless/receipt-chain/`.

Architecture reference:

- `docs/architecture.png`
- `docs/scope.md`

## 5. Repository Structure

```text
.
├── Jenkinsfile
├── README.md
├── .env.example
├── app/
│   └── kk-payments/
│       ├── Dockerfile
│       ├── package.json
│       ├── package-lock.json
│       └── src/
│           └── index.js
├── docs/
│   ├── scope.md
│   ├── architecture.png
│   ├── test-plan.md
│   ├── AI-governance-log.md
│   ├── peer-feedback-log.md
│   ├── demo-script.md
│   ├── reflection.md
│   └── demo-evidence/
├── infra/
│   ├── terraform/
│   │   ├── staging/
│   │   └── production/
│   └── ansible/
│       ├── inventories/
│       └── playbooks/
├── k8s/
│   ├── base/
│   ├── staging/
│   └── production/
├── monitoring/
│   └── prometheus/
├── scripts/
└── serverless/
    └── receipt-chain/
```

Project abbreviations and naming used:

- The Jenkins pipeline file is `Jenkinsfile` at the repository root.
- `k8s` is the abbreviation used for Kubernetes in this project.
- `infra` is the abbreviation used for infrastructure in this project.
- The current AI governance file is `docs/AI-governance-log.md`.

## 6. Prerequisites

Install and configure the following before running validation or deployment commands:

- `kubectl`
- Access to a k8s cluster through a valid kubeconfig
- Docker for building and running the `kk-payments` image
- Terraform `>= 1.6.0`
- Ansible
- Bash
- Node.js and npm for the `kk-payments` service
- `npx` for Serverless Framework validation
- AWS CLI for manual receipt-chain verification
- Jenkins with repository access and cluster credentials for pipeline execution

Suggested setup and configuration commands:

```bash
# Confirm kubectl is installed.
kubectl version --client

# Confirm your kubeconfig context before deploying.
kubectl config current-context
kubectl get namespaces

# Confirm Terraform is installed.
terraform version

# Initialize Terraform in each environment before validation or apply.
cd infra/terraform/staging
terraform init

cd ../production
terraform init

# Return to the repository root.
cd ../../..

# Confirm Ansible is installed.
ansible --version

# Confirm the Ansible inventories can be read.
ansible-inventory -i infra/ansible/inventories/staging.ini --list
ansible-inventory -i infra/ansible/inventories/production.ini --list

# Confirm Bash is available.
bash --version

# Confirm Node.js, npm, and npx are available.
node --version
npm --version
npx --version

# Install kk-payments dependencies.
cd app/kk-payments
npm ci

# Return to the repository root.
cd ../..

# Build the kk-payments container image.
docker build -t kk-payments:staging app/kk-payments

# Confirm Serverless Framework v3 can render the receipt-chain config.
cd serverless/receipt-chain
npx serverless@3 print --stage staging

# Return to the repository root.
cd ../..

# Confirm AWS CLI is installed and can see the active caller identity.
aws --version
aws sts get-caller-identity
```

Jenkins configuration is completed in Jenkins rather than through this repository. Configure the Jenkins job to use the root-level `Jenkinsfile`, provide cluster access through approved Jenkins credentials, and keep cloud or registry secrets out of Git.

No secrets should be committed to this repository. Use local environment variables, Jenkins credentials, kubeconfig, or cloud-provider secret storage as appropriate.

## 7. Environment Configuration

Environment-specific runtime configuration is stored in k8s ConfigMaps:

- Staging: `k8s/staging/configmap.yaml`
- Production: `k8s/production/configmap.yaml`

The staging ConfigMap sets:

- `NODE_ENV=staging`
- `PORT=3000`
- `DB_HOST=staging-db.kijanikiosk.local`
- `DB_PORT=5432`
- `DB_NAME=kijanikiosk_staging`
- `RECEIPT_BUCKET=kk-payments-receipts-staging`
- `AWS_REGION=us-east-1`

The production ConfigMap sets:

- `NODE_ENV=production`
- `PORT=3000`
- `DB_HOST=production-db.kijanikiosk.local`
- `DB_PORT=5432`
- `DB_NAME=kijanikiosk_production`
- `RECEIPT_BUCKET=kk-payments-receipts-production`
- `AWS_REGION=us-east-1`

`.env.example` documents local example values only. It must not be converted into a real secrets file in version control.

## 8. Application Service

The `kk-payments` service is located in:

```text
app/kk-payments/
```

It is a Node.js/Express API with these endpoints:

- `GET /`: basic service status
- `GET /health`: readiness and liveness health response
- `GET /config`: non-secret runtime configuration view
- `POST /payments`: demo payment processing endpoint that returns a generated receipt payload

Run it locally:

```bash
cd app/kk-payments
npm ci
npm start
```

The service listens on port `3000` by default. Validate it with:

```bash
curl http://localhost:3000/health
```

Build the container image from the repository root:

```bash
docker build -t kk-payments:staging app/kk-payments
docker build -t kk-payments:production app/kk-payments
```

The k8s overlays reference `kk-payments:staging` and `kk-payments:production`.

## 9. Validation Commands

Run these commands from the repository root unless noted otherwise.

Validate the Node.js app can install dependencies and start:

```bash
cd app/kk-payments
npm ci
npm start
```

In another terminal:

```bash
curl http://localhost:3000/health
```

After the health check, stop the service with `Ctrl-C` and return to the repository root:

```bash
cd ../..
```

Build Docker images:

```bash
docker build -t kk-payments:staging app/kk-payments
docker build -t kk-payments:production app/kk-payments
```

Render k8s overlays:

```bash
kubectl kustomize k8s/staging
kubectl kustomize k8s/production
```

Validate Terraform:

```bash
cd infra/terraform/staging
terraform init
terraform validate

cd ../production
terraform init
terraform validate
```

Validate Ansible syntax:

```bash
ansible-playbook -i infra/ansible/inventories/staging.ini infra/ansible/playbooks/configure-staging.yml --syntax-check
ansible-playbook -i infra/ansible/inventories/production.ini infra/ansible/playbooks/configure-production.yml --syntax-check
```

Validate shell scripts:

```bash
bash -n scripts/deploy-staging.sh
bash -n scripts/smoke-test-staging.sh
bash -n scripts/deploy-production.sh
bash -n scripts/verify-receipt-chain.sh
```

Validate receipt-chain Serverless configuration:

```bash
cd serverless/receipt-chain
npx serverless@3 print --stage staging
```

## 10. Infrastructure Automation

Terraform configuration is located under:

- `infra/terraform/staging/`
- `infra/terraform/production/`

Terraform manages the k8s namespaces:

- `kijani-staging`
- `kijani-production`

Ansible configuration is located under:

- `infra/ansible/inventories/`
- `infra/ansible/playbooks/`

The Ansible playbooks verify the target namespace and apply the correct k8s overlay:

- `infra/ansible/playbooks/configure-staging.yml`
- `infra/ansible/playbooks/configure-production.yml`

## 11. k8s Runtime Environments

The k8s layout uses a shared base plus environment overlays:

- `k8s/base/` contains the shared `kk-payments` Deployment and Service.
- `k8s/staging/` adds the `kijani-staging` namespace, staging ConfigMap, and staging image tag.
- `k8s/production/` adds the `kijani-production` namespace, production ConfigMap, and production image tag.

The shared Deployment includes:

- Two replicas
- Container port `3000`
- Readiness probe on `/health`
- Liveness probe on `/health`
- CPU and memory requests and limits
- ConfigMap-driven environment variables

## 12. CI/CD Pipeline Flow

The root-level `Jenkinsfile` defines the delivery flow:

1. Checkout
2. Verify Kubernetes access
3. Validate k8s manifests
4. Deploy to staging
5. Smoke test staging
6. Require production approval
7. Deploy to production

Production promotion is intentionally gated. Jenkins requires an `APPROVAL_REASON` value before the production deployment stage can continue.

The current `Jenkinsfile` does not include branch-based `when` conditions. Control which branch runs the deployment flow through the Jenkins job configuration.

## 13. Deployment Flow

Deployment is handled by Jenkins through the root-level `Jenkinsfile`. The pipeline applies the staging Kustomize overlay, waits for the `kk-payments` rollout, runs the staging smoke test, pauses for production approval, and then applies the production overlay.

The deployment scripts are kept in `scripts/` so Jenkins has a clear, reviewable implementation:

- `scripts/deploy-staging.sh`
- `scripts/smoke-test-staging.sh`
- `scripts/deploy-production.sh`

Do not run the staging deployment or staging smoke test manually as the normal workflow. Trigger the Jenkins pipeline instead so validation, approval, and evidence stay in one place.

## 14. Smoke Testing

Jenkins runs the staging smoke test after staging deployment. The smoke test runs a temporary `curlimages/curl` pod in `kijani-staging` and checks:

```text
http://kk-payments.kijani-staging.svc.cluster.local:3000/health
```

If the health check fails, the Jenkins pipeline should fail before the production approval gate is reached.

## 15. Production Approval Gate

The Jenkins pipeline includes a manual `Production Approval` stage. The approval prompt asks:

```text
Staging smoke test passed. Approve production deployment?
```

The approver must provide a non-empty approval reason. If the reason is blank, the pipeline fails and production deployment does not proceed.

This is a production-approaching control, not a full change-management system.

## 16. Monitoring and Alerts

Prometheus alert rules are defined in:

```text
monitoring/prometheus/kk-payments-alerts.yaml
```

Current alerts:

- `KKPaymentsPodRestarting`: warns when a `kk-payments` pod restarts in staging or production.
- `KKPaymentsDeploymentUnavailable`: critical alert when the `kk-payments` deployment has unavailable replicas for more than three minutes.

These rules represent committed monitoring intent. They still need to be loaded into the target Prometheus setup for live alerting.

## 17. Receipt-Chain Integration

Receipt-chain configuration is located in:

```text
serverless/receipt-chain/serverless.yml
```

The Serverless service is named `kk-receipt-chain`. It configures:

- Runtime: `nodejs20.x`
- Region: `us-east-1`
- Default stage: `staging`
- Receipt bucket pattern: `kk-payments-receipts-${stage}`
- S3 object-created trigger for the validator function

The staging k8s ConfigMap points `kk-payments` at:

```text
kk-payments-receipts-staging
```

Manual receipt upload verification can be run with:

```bash
./scripts/verify-receipt-chain.sh
```

By default, the script uploads a generated verification receipt to `s3://kk-payments-receipts-staging/`. Confirm function execution through the relevant Serverless or cloud logs.

## 18. Demo Evidence

Demo evidence should be stored under:

```text
docs/demo-evidence/
```

Recommended evidence to capture:

- k8s staging overlay render
- k8s production overlay render
- Terraform validation for staging and production
- Ansible syntax checks
- Serverless print output for staging
- Jenkins pipeline success
- Jenkins production approval gate with approval reason
- Staging smoke test success
- Fault-handling example where staging smoke test failure blocks production promotion

Do not invent demo evidence. Only add screenshots, logs, or notes that were actually captured during validation or demo execution.

Current captured evidence includes:

- `docs/demo-evidence/01-docker-images.png`
- `docs/demo-evidence/02-container-health-check.png`
- `docs/demo-evidence/03-terraform-validate.png`
- `docs/demo-evidence/04-ansible-check.png`
- `docs/demo-evidence/05-serverless-print-staging.png`
- `docs/demo-evidence/06-jenkins-pipeline-success.png`
- `docs/demo-evidence/07-k8s-status.png`
- `docs/demo-evidence/08-scripts-success.png`
- `docs/demo-evidence/09-production-success.png`
- `docs/demo-evidence/10-prometheus-alerts.png`

## 19. Project Documentation

Supporting documentation is committed under `docs/`:

- `docs/scope.md`: selected track, scope, assumptions, and boundaries
- `docs/test-plan.md`: validation plan and acceptance checks
- `docs/demo-script.md`: demo walkthrough
- `docs/AI-governance-log.md`: AI usage and governance notes
- `docs/peer-feedback-log.md`: peer review feedback and resolution
- `docs/reflection.md`: final capstone reflection and second-pass improvements

## 20. Known Production Gaps

This project is production-approaching, but it is not fully production-grade. Known gaps include:

- No full secret-management implementation is committed.
- No production database cluster or backup strategy is implemented.
- No multi-region failover or disaster recovery workflow is implemented.
- Prometheus rules are committed, but live Prometheus installation and Alertmanager routing are environment-dependent.
- Jenkins credentials, agent configuration, and cluster access must be configured outside this repository.
- The receipt-chain handlers are referenced by Serverless configuration, but live cloud deployment and log evidence must be verified in the target AWS account.
- Container images can be built locally, but registry push and image promotion are not fully modeled in this repository.

## 21. New Engineer Handover Guide

Start here when taking over the repository:

1. Read `docs/scope.md` to understand the selected Track A scope and out-of-scope boundaries.
2. Review `docs/architecture.png` for the high-level delivery architecture.
3. Run the `kk-payments` service locally from `app/kk-payments/`.
4. Build the local Docker images for staging and production tags.
5. Confirm your kubeconfig points to the intended cluster.
6. Run `kubectl kustomize k8s/staging` and `kubectl kustomize k8s/production`.
7. Validate Terraform in `infra/terraform/staging/` and `infra/terraform/production/`.
8. Run Ansible syntax checks for staging and production.
9. Review root-level `Jenkinsfile` and confirm Jenkins credentials, branch selection, and cluster access are configured outside the repo.
10. Trigger the Jenkins pipeline and let it deploy staging and run the staging smoke test.
11. Only approve production deployment after Jenkins staging validation passes and the approval reason is clear.
12. Review `monitoring/prometheus/kk-payments-alerts.yaml` before loading alert rules into Prometheus.
13. Validate receipt-chain configuration from `serverless/receipt-chain/` with `npx serverless@3 print --stage staging`.
14. Review real demo evidence in `docs/demo-evidence/`.
15. Keep secrets out of Git, and keep environment-specific changes in the correct `k8s/`, `infra/`, or Jenkins configuration location.
