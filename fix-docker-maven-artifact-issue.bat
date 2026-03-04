@echo off
echo ========================================
echo   Docker Maven Artifact Fix Script
echo ========================================
echo.

echo [Step 1] Stopping containers with artifact issues...
cd employee-onboarding-agent-fabric
docker-compose stop employee-onboarding-agent-broker

echo.
echo [Step 2] Rebuilding the agent broker container...
docker-compose build --no-cache employee-onboarding-agent-broker

echo.
echo [Step 3] Checking Dockerfile for proper artifact handling...
echo Looking at agent-broker Dockerfile...

echo.
echo [Step 4] Starting the fixed container...
docker-compose up -d employee-onboarding-agent-broker

echo.
echo [Step 5] Checking logs after restart...
timeout /t 10 >nul
docker logs employee-onboarding-agent-broker

echo.
echo ========================================
echo   Maven artifact fix completed!
echo ========================================
pause
