@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM Clay Platform — Deploy Everything to AKS
REM Run from: D:\zicofarry\GitHub\clay-app\backend
REM ─────────────────────────────────────────────────────────────────────────────

echo ============================================
echo   Clay Platform — AKS Deploy Script
echo ============================================
echo.

echo [1/5] Connecting to AKS cluster...
call az aks get-credentials --resource-group clay-cluster-rg --name clay-k8s-cluster --overwrite-existing
echo.

echo [2/5] Deleting old deployments (clean slate)...
kubectl delete deployments --all -n clay 2>nul
kubectl delete services --all -n clay 2>nul
kubectl delete endpoints --all -n clay 2>nul
echo   Old resources cleaned.
echo.

echo [3/5] Applying base configs (namespace + secrets)...
kubectl apply -f infra\k8s\base\namespace.yaml
kubectl apply -f infra\k8s\base\secrets.yaml
echo.

echo [4/5] Deploying databases (Postgres, Redis, MongoDB, Kafka, ES)...
kubectl apply -f infra\k8s\infra\databases.yaml
echo   Waiting 30s for databases to start...
timeout /t 30 /nobreak >nul
echo.

echo [5/5] Deploying all services...
kubectl apply -f infra\k8s\services\gateway.yaml
kubectl apply -f infra\k8s\services\services.yaml
echo.

echo ============================================
echo   Deployment complete! Checking status...
echo ============================================
echo.
kubectl get pods -n clay
echo.
echo Run 'kubectl get svc clay-gateway -n clay' to get your public IP.
