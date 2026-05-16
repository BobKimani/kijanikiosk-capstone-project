# KijaniKiosk Capstone Scope Document

## Project Track

Track A: Infrastructure-First

## Problem Statement

KijaniKiosk currently has individual DevOps components built across previous weeks, including infrastructure scripts, Kubernetes deployment work, CI/CD pipeline foundations, and serverless receipt processing. However, the system does not yet operate as a production-approaching delivery workflow because staging is not fully isolated, deployments are not automatically validated before production promotion, runtime health signals are not tied to committed alert rules, and the Kubernetes-to-serverless receipt integration is not clearly demonstrated.

This capstone addresses that operational gap by creating a staging-first delivery system where infrastructure, deployment, runtime configuration, monitoring, and receipt-chain integration can be reproduced, demonstrated, and handed over to another engineer.

## In-Scope Components

1. Create an isolated `kijani-staging` Kubernetes namespace for staging deployments.
2. Configure `kk-payments` to run in staging and production using shared Kubernetes deployment manifests with environment-specific ConfigMaps.
3. Build a Jenkins pipeline that deploys to staging, runs a smoke test, and only allows production deployment after manual approval.
4. Commit a Prometheus alert rule for a meaningful `kk-payments` health signal.
5. Integrate the Week 10 serverless receipt chain so staging `kk-payments` writes to the `kk-payments-receipts-staging` bucket.

## Out-of-Scope Items

1. Rebuilding the entire KijaniKiosk application UI is out of scope because this capstone focuses on delivery infrastructure, runtime operations, and deployment automation.
2. Implementing a full production-grade database cluster is out of scope because the project requirement focuses on environment-specific configuration through ConfigMaps rather than database administration.
3. Building a new serverless analytics function is out of scope because that belongs to Track B, while this submission follows Track A.
4. Implementing multi-region production failover is out of scope because the capstone target is a production-approaching system, not a fully enterprise-grade disaster recovery platform.

## Success Criteria

1. A merge to `main` triggers a Jenkins pipeline that deploys `kk-payments` to the staging environment.
2. The staging deployment passes a smoke test before the production approval gate is shown.
3. The production deployment only runs after a manual approval reason is recorded in Jenkins.
4. `kk-payments` runs in staging with a staging-specific ConfigMap, including a different `DB_HOST` value from production.
5. A Prometheus alert rule for `kk-payments` health is committed under the monitoring configuration.
6. The staging `kk-payments` deployment writes receipt events to the `kk-payments-receipts-staging` bucket and triggers the receipt chain successfully.
7. A deliberate staging fault causes the smoke test to fail and prevents production promotion.

## Architecture Diagram

The architecture diagram will be added in this branch as:

- `docs/architecture.mmd`
- `docs/architecture.png`
