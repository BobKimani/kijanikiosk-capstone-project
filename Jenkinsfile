pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        STAGING_NAMESPACE = 'kijani-staging'
        PRODUCTION_NAMESPACE = 'kijani-production'
        KUBECONFIG = '/var/jenkins_home/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Kubernetes Access') {
            steps {
                sh 'kubectl config current-context'
                sh 'kubectl get ns'
            }
        }

        stage('Validate k8s Manifests') {
            steps {
                sh 'kubectl kustomize k8s/staging > /tmp/kijani-staging-rendered.yaml'
                sh 'kubectl kustomize k8s/production > /tmp/kijani-production-rendered.yaml'
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh './scripts/deploy-staging.sh'
            }
        }

        stage('Smoke Test Staging') {
            steps {
                sh './scripts/smoke-test-staging.sh'
            }
        }

        stage('Production Approval') {
            steps {
                script {
                    def approval = input(
                        message: 'Staging smoke test passed. Approve production deployment?',
                        ok: 'Approve Production Deploy',
                        parameters: [
                            string(
                                name: 'APPROVAL_REASON',
                                defaultValue: '',
                                description: 'Required reason for approving production deployment'
                            )
                        ]
                    )

                    if (!approval?.trim()) {
                        error('Production approval reason is required.')
                    }

                    env.APPROVAL_REASON = approval
                    echo "Production deployment approved. Reason: ${env.APPROVAL_REASON}"
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                sh './scripts/deploy-production.sh'
            }
        }
    }

    post {
        success {
            echo 'KijaniKiosk deployment pipeline completed successfully.'
        }

        failure {
            echo 'KijaniKiosk deployment pipeline failed. Production promotion should not proceed unless staging validation passes.'
        }

        always {
            echo 'Pipeline finished.'
        }
    }
}
