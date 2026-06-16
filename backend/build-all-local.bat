@echo off
REM ─────────────────────────────────────────────────────────────────────────────
REM Clay Platform — Build locally using Docker Desktop and Push to ACR
REM Run from: D:\zicofarry\GitHub\clay-app\backend
REM NOTE: Docker Desktop MUST be running!
REM ─────────────────────────────────────────────────────────────────────────────

echo ===================================================
echo   Clay Platform — Local Docker Build and Push
echo   Building 24 images (23 services + gateway)
echo   Docker Desktop MUST be running!
echo ===================================================
echo.

REM Login to ACR via Docker
echo [0/24] Logging in to Azure Container Registry...
echo (Ini terkadang membutuhkan waktu 1-2 menit untuk berkomunikasi dengan Docker)
call az acr login --name clayregistry
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo FAILED to login to ACR. Please make sure Docker Desktop is RUNNING and try again.
    exit /b 1
)
echo.

REM Build & Push each service
call :build_and_push "gateway"               "clay-gateway"               1
call :build_and_push "auth-service"           "clay-auth-service"          2
call :build_and_push "user-service"           "clay-user-service"          3
call :build_and_push "payment-service"        "clay-payment-service"       4
call :build_and_push "food-order-service"     "clay-food-order-service"    5
call :build_and_push "delivery-order-service" "clay-delivery-order-service" 6
call :build_and_push "ride-order-service"     "clay-ride-order-service"    7
call :build_and_push "merchant-service"       "clay-merchant-service"      8
call :build_and_push "geo-service"            "clay-geo-service"           9
call :build_and_push "matching-service"       "clay-matching-service"      10
call :build_and_push "chat-service"           "clay-chat-service"          11
call :build_and_push "notification-service"   "clay-notification-service"  12
call :build_and_push "push-service"           "clay-push-service"          13
call :build_and_push "sms-service"            "clay-sms-service"           14
call :build_and_push "email-service"          "clay-email-service"         15
call :build_and_push "search-service"         "clay-search-service"        16
call :build_and_push "rating-service"         "clay-rating-service"        17
call :build_and_push "promotion-service"      "clay-promotion-service"     18
call :build_and_push "pricing-service"        "clay-pricing-service"       19
call :build_and_push "wallet-service"         "clay-wallet-service"        20
call :build_and_push "history-service"        "clay-history-service"       21
call :build_and_push "tracking-service"       "clay-tracking-service"      22
call :build_and_push "audit-log-service"      "clay-audit-log-service"     23
call :build_and_push "security-service"       "clay-security-service"      24

echo.
echo ===================================================
echo   ALL 24 IMAGES BUILT AND PUSHED TO ACR!
echo ===================================================
exit /b 0

:build_and_push
set SERVICE_DIR=%~1
set IMAGE_NAME=%~2
set NUM=%~3
echo.
echo [%NUM%/24] Building %IMAGE_NAME% locally...
docker build -t clayregistry.azurecr.io/%IMAGE_NAME%:latest -f services/%SERVICE_DIR%/Dockerfile .
if %ERRORLEVEL% NEQ 0 (
    echo   WARNING: %IMAGE_NAME% build failed! Skipping push.
    exit /b 0
)

echo [%NUM%/24] Pushing %IMAGE_NAME% to ACR...
docker push clayregistry.azurecr.io/%IMAGE_NAME%:latest
if %ERRORLEVEL% NEQ 0 (
    echo   WARNING: %IMAGE_NAME% push failed!
) else (
    echo   OK: %IMAGE_NAME% done.
)
exit /b 0
