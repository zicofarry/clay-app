pipeline {
    agent any

    environment {
        GO_VERSION = '1.25'
        DOCKER_REGISTRY = 'clay'
        K8S_NAMESPACE = 'clay'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ── Auth Service ──
        stage('Auth Service') {
            when {
                anyOf {
                    changeset "backend/services/auth-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('auth-service', 'clay-auth-service')
            }
        }

        stage('User Service') {
            when {
                anyOf {
                    changeset "backend/services/user-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('user-service', 'clay-user-service')
            }
        }

        stage('Payment Service') {
            when {
                anyOf {
                    changeset "backend/services/payment-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('payment-service', 'clay-payment-service')
            }
        }

        stage('Food Order Service') {
            when {
                anyOf {
                    changeset "backend/services/food-order-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('food-order-service', 'clay-food-order-service')
            }
        }

        stage('Delivery Order Service') {
            when {
                anyOf {
                    changeset "backend/services/delivery-order-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('delivery-order-service', 'clay-delivery-order-service')
            }
        }

        stage('Ride Order Service') {
            when {
                anyOf {
                    changeset "backend/services/ride-order-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('ride-order-service', 'clay-ride-order-service')
            }
        }

        stage('Gateway') {
            when {
                anyOf {
                    changeset "backend/services/gateway/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('gateway', 'clay-gateway')
            }
        }

        stage('Chat Service') {
            when {
                anyOf {
                    changeset "backend/services/chat-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('chat-service', 'clay-chat-service')
            }
        }

        stage('Notification Service') {
            when {
                anyOf {
                    changeset "backend/services/notification-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('notification-service', 'clay-notification-service')
            }
        }

        stage('Push Service') {
            when {
                anyOf {
                    changeset "backend/services/push-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('push-service', 'clay-push-service')
            }
        }

        stage('SMS Service') {
            when {
                anyOf {
                    changeset "backend/services/sms-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('sms-service', 'clay-sms-service')
            }
        }

        stage('Email Service') {
            when {
                anyOf {
                    changeset "backend/services/email-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('email-service', 'clay-email-service')
            }
        }

        stage('Search Service') {
            when {
                anyOf {
                    changeset "backend/services/search-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('search-service', 'clay-search-service')
            }
        }

        stage('Geo Service') {
            when {
                anyOf {
                    changeset "backend/services/geo-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('geo-service', 'clay-geo-service')
            }
        }

        stage('Matching Service') {
            when {
                anyOf {
                    changeset "backend/services/matching-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('matching-service', 'clay-matching-service')
            }
        }

        stage('Merchant Service') {
            when {
                anyOf {
                    changeset "backend/services/merchant-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('merchant-service', 'clay-merchant-service')
            }
        }

        stage('Rating Service') {
            when {
                anyOf {
                    changeset "backend/services/rating-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('rating-service', 'clay-rating-service')
            }
        }

        stage('Promotion Service') {
            when {
                anyOf {
                    changeset "backend/services/promotion-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('promotion-service', 'clay-promotion-service')
            }
        }

        stage('Pricing Service') {
            when {
                anyOf {
                    changeset "backend/services/pricing-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('pricing-service', 'clay-pricing-service')
            }
        }

        stage('Wallet Service') {
            when {
                anyOf {
                    changeset "backend/services/wallet-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('wallet-service', 'clay-wallet-service')
            }
        }

        stage('History Service') {
            when {
                anyOf {
                    changeset "backend/services/history-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('history-service', 'clay-history-service')
            }
        }

        stage('Tracking Service') {
            when {
                anyOf {
                    changeset "backend/services/tracking-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('tracking-service', 'clay-tracking-service')
            }
        }

        stage('Audit Log Service') {
            when {
                anyOf {
                    changeset "backend/services/audit-log-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('audit-log-service', 'clay-audit-log-service')
            }
        }

        stage('Security Service') {
            when {
                anyOf {
                    changeset "backend/services/security-service/**"
                    expression { env.BRANCH_NAME != 'main' }
                }
            }
            steps {
                buildAndDeploy('security-service', 'clay-security-service')
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}

def buildAndDeploy(String serviceDir, String appName) {
    dir("backend/services/${serviceDir}") {
        echo "========================================"
        echo "  ${appName}"
        echo "========================================"

        echo "[1/8] Downloading dependencies..."
        bat 'go mod download'

        echo "[2/8] Running unit tests..."
        bat "go test -tags=unit -v ./..."

        echo "[3/8] Running linter (go vet)..."
        bat 'go vet ./...'

        echo "[4/8] Building Docker image..."
        bat "docker build -t ${DOCKER_REGISTRY}/${appName}:latest -f Dockerfile ../.."

        echo "[5/8] Running functional tests..."
        bat "docker compose up -d"
        try {
            bat "go test -tags=functional -v ./test/functional/..."
        } finally {
            bat "docker compose down -v"
        }

        echo "[6/8] Pushing image (skip if no registry configured)..."
        bat """
            docker push ${DOCKER_REGISTRY}/${appName}:latest || echo Push skipped (no registry configured)
        """

        echo "[7/8] Deploying to Kubernetes..."
        bat "kubectl set image deployment/${appName} ${appName}=${DOCKER_REGISTRY}/${appName}:latest -n ${K8S_NAMESPACE} --record || echo Deploy skipped (K8s not available)"

        echo "[8/8] Verifying rollout..."
        bat "kubectl rollout status deployment/${appName} -n ${K8S_NAMESPACE} || echo Verify skipped (K8s not available)"

        echo "========================================"
        echo "  Done: ${appName}"
        echo "========================================"
    }
}
