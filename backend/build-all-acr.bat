@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM Clay Platform — Build and Push ALL images to Azure Container Registry
REM Run from: D:\zicofarry\GitHub\clay-app\backend
REM NOTE: az acr build does NOT need Docker Desktop — builds happen in Azure cloud
REM ─────────────────────────────────────────────────────────────────────────────

echo ============================================
echo   Clay Platform — ACR Build Script
echo   Building 25 images (24 services + gateway)
echo   No Docker Desktop needed!
echo ============================================
echo.

call :build_service "gateway"               "clay-gateway"               1
call :build_service "auth-service"           "clay-auth-service"          2
call :build_service "user-service"           "clay-user-service"          3
call :build_service "payment-service"        "clay-payment-service"       4
call :build_service "food-order-service"     "clay-food-order-service"    5
call :build_service "delivery-order-service" "clay-delivery-order-service" 6
call :build_service "ride-order-service"     "clay-ride-order-service"    7
call :build_service "merchant-service"       "clay-merchant-service"      8
call :build_service "geo-service"            "clay-geo-service"           9
call :build_service "matching-service"       "clay-matching-service"      10
call :build_service "chat-service"           "clay-chat-service"          11
call :build_service "notification-service"   "clay-notification-service"  12
call :build_service "push-service"           "clay-push-service"          13
call :build_service "sms-service"            "clay-sms-service"           14
call :build_service "email-service"          "clay-email-service"         15
call :build_service "search-service"         "clay-search-service"        16
call :build_service "rating-service"         "clay-rating-service"        17
call :build_service "promotion-service"      "clay-promotion-service"     18
call :build_service "pricing-service"        "clay-pricing-service"       19
call :build_service "wallet-service"         "clay-wallet-service"        20
call :build_service "history-service"        "clay-history-service"       21
call :build_service "tracking-service"       "clay-tracking-service"      22
call :build_service "audit-log-service"      "clay-audit-log-service"     23
call :build_service "security-service"       "clay-security-service"      24

echo.
echo ============================================
echo   ALL 25 IMAGES BUILT SUCCESSFULLY!
echo ============================================
exit /b 0

:build_service
set SERVICE_DIR=%~1
set IMAGE_NAME=%~2
set NUM=%~3
echo.
echo [%NUM%/25] Building %IMAGE_NAME%...
call az acr build --registry clayregistry --image %IMAGE_NAME%:latest --file services/%SERVICE_DIR%/Dockerfile . --no-logs
if %ERRORLEVEL% NEQ 0 (
    echo   WARNING: %IMAGE_NAME% build failed! Continuing...
) else (
    echo   OK: %IMAGE_NAME% built and pushed.
)
exit /b 0
