@echo off
REM ================================================
REM Employee Onboarding MCP Servers - Corrected Deployment Script
REM Fixed: Environment variable loading, proper path navigation, and error handling
REM ================================================

setlocal enabledelayedexpansion
chcp 65001 >nul

echo 🚀 Employee Onboarding MCP Servers Deployment
echo ================================================
echo.

REM ===== STEP 1: LOAD ENVIRONMENT VARIABLES =====
echo 🔍 Loading environment configuration...

REM Load environment variables from .env file
if exist ".env" (
    echo [INFO] Loading .env file...
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
        )
    )
    echo ✅ Environment variables loaded
) else (
    echo ❌ .env file NOT FOUND!
    echo 💡 Please create .env file with required credentials
    pause & exit /b 1
)

REM ===== STEP 2: VALIDATE CREDENTIALS =====
echo.
echo 🔐 Validating credentials...

if "%ANYPOINT_CLIENT_ID%"=="" (
    echo ❌ ANYPOINT_CLIENT_ID missing from .env
    pause & exit /b 1
)
if "%ANYPOINT_CLIENT_SECRET%"=="" (
    echo ❌ ANYPOINT_CLIENT_SECRET missing from .env
    pause & exit /b 1
)
if "%ANYPOINT_ORG_ID%"=="" (
    echo ❌ ANYPOINT_ORG_ID missing from .env
    pause & exit /b 1
)
if "%ANYPOINT_ENV%"=="" (
    echo [WARN] ANYPOINT_ENV not set, defaulting to Sandbox
    set "ANYPOINT_ENV=Sandbox"
)

echo ✅ Credentials validated
echo 🏢 Org ID: %ANYPOINT_ORG_ID%
echo 🌍 Environment: %ANYPOINT_ENV%
echo 🔑 Client ID: %ANYPOINT_CLIENT_ID:~0,12%...
echo.

REM ===== STEP 3: CHECK PREREQUISITES =====
echo 🔍 Checking prerequisites...

REM Check Maven
mvn --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Maven not found! Please install Maven and add to PATH
    pause & exit /b 1
)

REM Check if we're in the right directory and mcp-servers exists
if not exist "mcp-servers" (
    echo ❌ mcp-servers directory not found!
    echo 💡 Current directory: %CD%
    echo 💡 Please run this script from the employee-onboarding-agent-fabric directory
    pause & exit /b 1
)

echo ✅ Prerequisites OK
echo.

REM ===== STEP 4: NAVIGATE TO MCP-SERVERS DIRECTORY =====
echo 📁 Navigating to mcp-servers directory...
cd /d "mcp-servers"
if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to navigate to mcp-servers directory
    pause & exit /b 1
)
echo [INFO] Current directory: %CD%
echo.

REM ===== STEP 5: DEPLOY EACH MCP SERVER =====

REM Deploy 1: Employee Onboarding MCP
echo [1/4] === EMPLOYEE-ONBOARDING-MCP ===
if not exist "employee-onboarding-mcp" (
    echo ❌ employee-onboarding-mcp directory not found
    cd ..
    pause & exit /b 1
)
cd employee-onboarding-mcp
echo [INFO] Building and deploying employee-onboarding-mcp...
call mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="employee-onboarding-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if !ERRORLEVEL! neq 0 (
    echo ❌ employee-onboarding-mcp deployment failed!
    cd ..\..
    pause & exit /b 1
)
echo ✅ employee-onboarding-mcp deployed successfully!
cd ..

REM Deploy 2: Asset Allocation MCP  
echo.
echo [2/4] === ASSET-ALLOCATION-MCP ===
if not exist "asset-allocation-mcp" (
    echo ❌ asset-allocation-mcp directory not found
    cd ..
    pause & exit /b 1
)
cd asset-allocation-mcp
echo [INFO] Building and deploying asset-allocation-mcp...
call mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="asset-allocation-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if !ERRORLEVEL! neq 0 (
    echo ❌ asset-allocation-mcp deployment failed!
    cd ..\..
    pause & exit /b 1
)
echo ✅ asset-allocation-mcp deployed successfully!
cd ..

REM Deploy 3: Notification MCP
echo.
echo [3/4] === NOTIFICATION-MCP ===
if not exist "notification-mcp" (
    echo ❌ notification-mcp directory not found
    cd ..
    pause & exit /b 1
)
cd notification-mcp
echo [INFO] Building and deploying notification-mcp...
call mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="notification-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if !ERRORLEVEL! neq 0 (
    echo ❌ notification-mcp deployment failed!
    cd ..\..
    pause & exit /b 1
)
echo ✅ notification-mcp deployed successfully!
cd ..

REM Deploy 4: Agent Broker MCP
echo.
echo [4/4] === AGENT-BROKER-MCP ===
if not exist "agent-broker-mcp" (
    echo ❌ agent-broker-mcp directory not found
    cd ..
    pause & exit /b 1
)
cd agent-broker-mcp
echo [INFO] Building and deploying agent-broker-mcp...
call mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="employee-onboarding-agent-broker" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if !ERRORLEVEL! neq 0 (
    echo ❌ agent-broker-mcp deployment failed!
    cd ..\..
    pause & exit /b 1
)
echo ✅ agent-broker-mcp deployed successfully!
cd ..

REM ===== STEP 6: NAVIGATE BACK TO ROOT =====
echo.
echo 📁 Returning to root directory...
cd ..
echo [INFO] Current directory: %CD%

REM ===== DEPLOYMENT COMPLETE =====
echo.
echo ====================================
echo     🎉 ALL MCP SERVERS DEPLOYED! 🎉
echo ====================================
echo.
echo 📋 Successfully Deployed Applications:
echo   1. ✅ employee-onboarding-mcp-server
echo   2. ✅ asset-allocation-mcp-server  
echo   3. ✅ notification-mcp-server
echo   4. ✅ employee-onboarding-agent-broker
echo.
echo 🔗 Check deployment status: https://anypoint.mulesoft.com/cloudhub
echo ⏳ Wait 2-5 minutes for applications to reach STARTED status
echo.
echo 📍 Application URLs (available after deployment completes):
echo   👤 Employee Onboarding: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo   💼 Asset Allocation: https://asset-allocation-mcp-server.us-e1.cloudhub.io
echo   🔔 Notifications: https://notification-mcp-server.us-e1.cloudhub.io
echo   🤖 Agent Broker: https://employee-onboarding-agent-broker.us-e1.cloudhub.io
echo.
echo 💡 Next Steps:
echo   1. Monitor deployment status in Runtime Manager
echo   2. Test API endpoints once applications are STARTED
echo   3. Configure any additional environment-specific settings
echo.
pause
