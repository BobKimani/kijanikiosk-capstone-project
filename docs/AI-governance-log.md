# AI Governance Log

This document records AI-assisted work used during the KijaniKiosk Track A capstone project. Each entry documents what AI was used for, what it produced, what it got wrong, how the output was reviewed, and what manual changes were made before use in the project.

---

## Entry 1: Track Selection and Capstone Direction

1. **Date:** 2026-05-17
2. **Tool used:** ChatGPT
3. **Prompt/task:** Requested help understanding both capstone tracks and choosing the best one based on my previous KijaniKiosk work and the grading rubric.
4. **AI output produced:** AI compared Track A and Track B, explained their differences, and recommended Track A because it aligned better with my earlier work in Terraform, Ansible, Jenkins, Kubernetes, and observability.
5. **What it got wrong:** The recommendation itself was useful, but the initial planning approach was too broad and suggested creating too many files too early instead of following a more staged execution process.
6. **Human review performed:** I reviewed the rubric and compared both tracks against the work I had already completed in previous weeks. I confirmed that Track A was the stronger choice and better matched my experience and project direction.
7. **Manual change made:** I chose Track A, but I restructured the implementation plan into fewer, more functional feature branches instead of many small branches.
8. **Governance checklist reference:** Human review and accountability for AI-assisted planning.

---

## Entry 2: Track A Execution Planning

1. **Date:** 2026-05-17
2. **Tool used:** ChatGPT
3. **Prompt/task:** Requested a staged execution plan for Track A so that the capstone could be implemented systematically, branch by branch, while staying aligned with the rubric.
4. **AI output produced:** AI proposed a branch-based implementation plan covering scope and architecture, k8s runtime environments, infrastructure automation, CI/CD and receipt integration, and final documentation/evidence.
5. **What it got wrong:** The first planning approach suggested creating too many files at once and also spread the work across too many feature branches, which did not match the desired Git workflow.
6. **Human review performed:** I reviewed the suggested structure against the rubric requirements for version control hygiene and decided to simplify the workflow into fewer feature branches with more meaningful grouped commits.
7. **Manual change made:** I changed the project execution approach to five functional feature branches: `feature/capstone-scope`, `feature/k8s-runtime-env`, `feature/infra-automation`, `feature/cicd-receipts`, and `feature/demo-evidence-docs`.
8. **Governance checklist reference:** Human-in-the-loop planning and review of AI-generated project structure.

---

## Entry 3: CI/CD and Receipt-Chain Debugging

1. **Date:** 2026-05-17
2. **Tool used:** ChatGPT
3. **Prompt/task:** Requested help creating the CI/CD, monitoring for Track A, and later used AI to debug issues with the serverless receipt-chain configuration.
4. **AI output produced:** AI proposed a CI/CD script, a smoke test script, a Jenkins pipeline, Prometheus alert rules, and validation commands for the receipt chain. It also helped debug the Serverless configuration when the receipt-chain validation failed.
5. **What it got wrong:** The initial CI/CD guidance placed the `Jenkinsfile` inside a folder instead of at the repository root, which was incorrect for this project.
6. **Human review performed:** I checked the project convention and confirmed that the Jenkinsfile had to be at the repository root. I also used terminal feedback to verify the Serverless issue and tested the corrected configuration with `npx serverless@3 print --stage staging`.
7. **Manual change made:** I moved/kept the `Jenkinsfile` at the root of the repository and corrected the Serverless receipt-chain configuration so it could validate successfully.
8. **Governance checklist reference:** Verification of AI output using real tool execution and correction of deployment-related mistakes before adoption.
