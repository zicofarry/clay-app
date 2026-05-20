pipeline {
    agent any

    environment {
        GO_VERSION = '1.25'
        DOCKER_REGISTRY = 'clay'
        K8S_NAMESPACE = 'clay'
        K8S_MANIFESTS = 'backend/infra/k8s'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        // ── Auth Service ──
        stage('Auth Service: Build & Deploy') {
            when { changeset "backend/services/auth-service/**" }
            steps {
                buildAndDeploy('auth-service', 'clay-auth-service')
            }
        }

        // ── User Service ──
        stage('User Service: Build & Deploy') {
            when { changeset "backend/services/user-service/**" }
            steps {
                buildAndDeploy('user-service', 'clay-user-service')
            }
        }

        // ── Payment Service ──
        stage('Payment Service: Build & Deploy') {
            when { changeset "backend/services/payment-service/**" }
            steps {
                buildAndDeploy('payment-service', 'clay-payment-service')
            }
        }

        // ── Food Order Service ──
        stage('Food Order Service: Build & Deploy') {
            when { changeset "backend/services/food-order-service/**" }
            steps {
                buildAndDeploy('food-order-service', 'clay-food-order-service')
            }
        }

        // ── Delivery Order Service ──
        stage('Delivery Order Service: Build & Deploy') {
            when { changeset "backend/services/delivery-order-service/**" }
            steps {
                buildAndDeploy('delivery-order-service', 'clay-delivery-order-service')
            }
        }

        // ── Ride Order Service ──
        stage('Ride Order Service: Build & Deploy') {
            when { changeset "backend/services/ride-order-service/**" }
            steps {
                buildAndDeploy('ride-order-service', 'clay-ride-order-service')
            }
        }

        // ── Gateway ──
        stage('Gateway: Build & Deploy') {
            when { changeset "backend/services/gateway/**" }
            steps {
                buildAndDeploy('gateway', 'clay-gateway')
            }
        }

        // ── Chat Service ──
        stage('Chat Service: Build & Deploy') {
            when { changeset "backend/services/chat-service/**" }
            steps {
                buildAndDeploy('chat-service', 'clay-chat-service')
            }
        }

        // ── Notification Service ──
        stage('Notification Service: Build & Deploy') {
            when { changeset "backend/services/notification-service/**" }
            steps {
                buildAndDeploy('notification-service', 'clay-notification-service')
            }
        }

        // ── Push Service ──
        stage('Push Service: Build & Deploy') {
            when { changeset "backend/services/push-service/**" }
            steps {
                buildAndDeploy('push-service', 'clay-push-service')
            }
        }

        // ── SMS Service ──
        stage('SMS Service: Build & Deploy') {
            when { changeset "backend/services/sms-service/**" }
            steps {
                buildAndDeploy('sms-service', 'clay-sms-service')
            }
        }

        // ── Email Service ──
        stage('Email Service: Build & Deploy') {
            when { changeset "backend/services/email-service/**" }
            steps {
                buildAndDeploy('email-service', 'clay-email-service')
            }
        }

        // ── Search Service ──
        stage('Search Service: Build & Deploy') {
            when { changeset "backend/services/search-service/**" }
            steps {
                buildAndDeploy('search-service', 'clay-search-service')
            }
        }

        // ── Geo Service ──
        stage('Geo Service: Build & Deploy') {
            when { changeset "backend/services/geo-service/**" }
            steps {
                buildAndDeploy('geo-service', 'clay-geo-service')
            }
        }

        // ── Matching Service ──
        stage('Matching Service: Build & Deploy') {
            when { changeset "backend/services/matching-service/**" }
            steps {
                buildAndDeploy('matching-service', 'clay-matching-service')
            }
        }

        // ── Merchant Service ──
        stage('Merchant Service: Build & Deploy') {
            when { changeset "backend/services/merchant-service/**" }
            steps {
                buildAndDeploy('merchant-service', 'clay-merchant-service')
            }
        }

        // ── Rating Service ──
        stage('Rating Service: Build & Deploy') {
            when { changeset "backend/services/rating-service/**" }
            steps {
                buildAndDeploy('rating-service', 'clay-rating-service')
            }
        }

        // ── Promotion Service ──
        stage('Promotion Service: Build & Deploy') {
            when { changeset "backend/services/promotion-service/**" }
            steps {
                buildAndDeploy('promotion-service', 'clay-promotion-service')
            }
        }

        // ── Pricing Service ──
        stage('Pricing Service: Build & Deploy') {
            when { changeset "backend/services/pricing-service/**" }
            steps {
                buildAndDeploy('pricing-service', 'clay-pricing-service')
            }
        }

        // ── Wallet Service ──
        stage('Wallet Service: Build & Deploy') {
            when { changeset "backend/services/wallet-service/**" }
            steps {
                buildAndDeploy('wallet-service', 'clay-wallet-service')
            }
        }

        // ── History Service ──
        stage('History Service: Build & Deploy') {
            when { changeset "backend/services/history-service/**" }
            steps {
                buildAndDeploy('history-service', 'clay-history-service')
            }
        }

        // ── Tracking Service ──
        stage('Tracking Service: Build & Deploy') {
            when { changeset "backend/services/tracking-service/**" }
            steps {
                buildAndDeploy('tracking-service', 'clay-tracking-service')
            }
        }

        // ── Audit Log Service ──
        stage('Audit Log Service: Build & Deploy') {
            when { changeset "backend/services/audit-log-service/**" }
            steps {
                buildAndDeploy('audit-log-service', 'clay-audit-log-service')
            }
        }

        // ── Security Service ──
        stage('Security Service: Build & Deploy') {
            when { changeset "backend/services/security-service/**" }
            steps {
                buildAndDeploy('security-service', 'clay-security-service')
            }
        }

        // ── Shared Library ──
        stage('Shared Library Changed') {
            when { changeset "backend/pkg/**" }
            steps {
                echo "WARNING: Shared library (backend/pkg/) has changed."
                echo "Rebuild all dependent services manually or via downstream trigger."
            }
        }

        // ── Infra ──
        stage('Deploy Infrastructure') {
            when { changeset "backend/infra/**" }
            steps {
                echo "=============================="
                echo " Deploying Infrastructure"
                echo "=============================="
                echo "[1/1] Applying Kubernetes manifests..."
                dir('backend/infra/k8s') {
                    bat 'kubectl apply -f base/ -f infra/ -f services/'
                }
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
        echo "  Building: ${appName}"
        echo "========================================"

        echo "[2/8] Downloading dependencies..."
        bat 'go mod download'

        echo "[3/8] Running unit tests..."
        bat "go test -tags=unit -v ./..."

        echo "[4/8] Running linter (go vet)..."
        bat 'go vet ./...'

        echo "[5/8] Building Docker image..."
        def imageTag = "${DOCKER_REGISTRY}/${appName}:${env.BUILD_ID}"
        bat "docker build -t ${imageTag} -f Dockerfile ."

        echo "[6/8] Running functional tests..."
        bat "go test -tags=functional -v ./test/functional/..."

        echo "[7/8] Pushing image to registry..."
        bat "docker push ${imageTag}"
        bat "docker tag ${imageTag} ${DOCKER_REGISTRY}/${appName}:latest"
        bat "docker push ${DOCKER_REGISTRY}/${appName}:latest"

        echo "[8/8] Deploying to Kubernetes..."
        bat "kubectl set image deployment/${appName} ${appName}=${DOCKER_REGISTRY}/${appName}:latest -n ${K8S_NAMESPACE} --record"
        bat "kubectl rollout status deployment/${appName} -n ${K8S_NAMESPACE}"

        echo "========================================"
        echo "  Done: ${appName}"
        echo "========================================"
    }
}
