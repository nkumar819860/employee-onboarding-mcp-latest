@echo off
REM Quick Deploy Script for Employee Onboarding MCP Servers
REM Sets environment variables and runs deployment

echo ========================================
echo 🚀 Quick Deploy - Employee Onboarding MCP
echo ========================================
echo.

REM Set required environment variables
set ANYPOINT_ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set ANYPOINT_ENV=Sandbox
set CLOUDHUB_REGION=us-east-1

echo 📋 Configuration:
echo   Organization ID: %ANYPOINT_ORG_ID%
echo   Environment: %ANYPOINT_ENV%
echo   Region: %CLOUDHUB_REGION%
echo.

echo 🔧 This script will:
echo   1. Build all 4 MCP servers (Employee, Asset, Notification, Broker)
echo   2. Login to Anypoint Platform (username/password)
echo   3. Publish to Exchange
echo   4. Deploy to CloudHub 2.0
echo   5. Test health endpoints
echo.

set /p continue=Continue with deployment? (y/n): 
if /i not "%continue%"=="y" (
    echo Deployment cancelled.
    pause
    exit /b 0
)

echo.
echo 🚀 Starting deployment...
echo.

REM Run the main deployment script
call deploy-all-mcp-servers.bat

echo.
echo ========================================
echo 🎉 Quick Deploy Complete!
echo ========================================
echo.
echo 📱 Ready to deploy React Frontend?
echo    Run: cd react-client && npm install && npm start
echo.
pause
