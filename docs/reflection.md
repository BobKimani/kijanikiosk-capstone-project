# Capstone Reflection

## 1. What did I get wrong?

One thing I got wrong early in the capstone was underestimating how important the order of execution would be. At first, I wanted to create many files at once: documentation files, Kubernetes manifests, Jenkins configuration, infrastructure files, and evidence folders. That approach looked fast, but it was not clean from a version control and review perspective.

I later realized that a production-approaching DevOps project should be built in clear, reviewable stages. I changed the workflow to use functional branches such as `feature/capstone-scope`, `feature/k8s-runtime-env`, `feature/infra-automation`, `feature/cicd-receipts`, and `feature/demo-evidence-docs`. This made the work easier to review and helped me connect each branch to a specific part of the rubric.

Another mistake was assuming that Jenkins would behave the same way as a multibranch pipeline. I originally used branch-based conditions in the Jenkinsfile, but my Jenkins setup was a standard Pipeline job. This caused deployment stages to be skipped even when the correct branch was checked out. I fixed this by removing the branch condition and relying on the Jenkins job configuration to control which branch runs the deployment pipeline.

I also learned that Jenkins running inside Docker does not automatically have access to my local Kubernetes cluster. Installing `kubectl` was only one part of the solution. I also had to provide Jenkins with a usable kubeconfig and handle the local Minikube certificate issue. This was a good reminder that CI/CD pipelines do not just run commands; they need the correct runtime environment, credentials, tools, and network access.

## 2. What is the most important thing I learned?

The most important thing I learned is that staging-first deployment is not just a nice pipeline pattern; it is a production safety control.

Before this capstone, I mostly thought of a pipeline as a sequence of steps: build, deploy, test, and finish. Through this project, especially from the Week 9 Kubernetes work and the final capstone pipeline, I understood that each stage should protect the next one. The staging deployment proves that the manifests can apply successfully. The smoke test proves that the service is reachable and healthy. The approval gate ensures that production deployment is intentional and reviewed.

The approval gate became more meaningful when the pipeline failed after I approved without entering a reason. At first, it looked like an error, but it actually proved that the governance control was working. Production deployment should not happen silently. Someone should approve it and explain why it is safe to continue.

This changed how I think about DevOps. A good pipeline is not just automation. It is automation with controls, evidence, and recovery points.

## 3. What would I change in a second pass?

In a second pass, I would improve four areas.

First, I would replace the local Minikube/Jenkins kubeconfig workaround with a cleaner service-account-based access model. For this demo, I used a flattened kubeconfig and adjusted TLS verification because Jenkins was running inside Docker and accessing Minikube through `host.docker.internal`. That was acceptable for a local capstone demo, but in a real production environment I would use a scoped Kubernetes service account, proper RBAC permissions, and a valid certificate setup.

Second, I would improve secrets management. The project currently uses ConfigMaps for non-sensitive environment-specific values such as `DB_HOST` and receipt bucket names. In a stronger production version, sensitive values such as database credentials, cloud credentials, and tokens should be stored in a proper secrets manager such as Kubernetes Secrets, AWS Secrets Manager, or HashiCorp Vault.

Third, I would make monitoring more complete. The Prometheus alert rules are committed and meaningful, but I would add Alertmanager routing so that alerts can notify the right person or team. I would also add a dashboard showing pod health, restart counts, deployment availability, and smoke test results.

Finally, I would improve the receipt-chain integration by deploying the serverless stack to a real cloud staging environment and capturing function logs as part of the demo evidence. The current validation proves that the Serverless configuration resolves correctly for the staging bucket, but a second pass would include full cloud execution evidence from the receipt event through the serverless functions.
