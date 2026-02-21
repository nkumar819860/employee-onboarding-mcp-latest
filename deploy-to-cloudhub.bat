@echo off
REM Employee Onboarding System - CloudHub Deployment Script (Windows)
REM This script deploys all MCP servers including the agent broker to CloudHub using Anypoint CLI v4
REM Version: 2.0.0
REM Updated: 2026-02-21

setlocal enabledelayedexpansion

echo.
echo ========================================
echo 🚀 Employee Onboarding System Deployer
echo    CloudHub Deployment with CLI v4
echo ========================================
echo.
echo 📅 Deployment started at: %date% %time%
echo.

REM Check if .env file exists
if not exist ".env" (
    echo ❌ .env file not found in current directory
    echo Please ensure .env file exists with required credentials
    pause
    exit /b 1
)

REM Load environment variables from .env file
echo 📝 Loading configuration from .env file...
for /f "delims=" %%x in (.env) do (
    set "line=%%x"
    if not "!line:~0,1!"=="#" if not "!line!"=="" (
        for /f "tokens=1,2 delims==" %%a in ("!line!") do (
            set "%%a=%%b"
        )
    )
)
echo ✅ Environment configuration loaded

REM Validate required environment variables
echo 🔍 Validating required environment variables...
set VALIDATION_FAILED=false

if "%ANYPOINT_CLIENT_ID%"=="" (
    echo ❌ ANYPOINT_CLIENT_ID not found in .env file
    set VALIDATION_FAILED=true
)

if "%ANYPOINT_CLIENT_SECRET%"=="" (
    echo ❌ ANYPOINT_CLIENT_SECRET not found in .env file
    set VALIDATION_FAILED=true
)

if "%ANYPOINT_ORG_ID%"=="" (
    echo ❌ ANYPOINT_ORG_ID not found in .env file
    set VALIDATION_FAILED=true
)

if "%ANYPOINT_ENV%"=="" (
    echo ❌ ANYPOINT_ENV not found in .env file
    set VALIDATION_FAILED=true
)

if "%MULE_VERSION%"=="" (
    echo ❌ MULE_VERSION not found in .env file
    set VALIDATION_FAILED=true
)

if "%VALIDATION_FAILED%"=="true" (
    echo.
    echo ❌ Environment validation failed. Please check your .env file.
    pause
    exit /b 1
)

echo ✅ All required environment variables found

echo.
echo 🔐 Setting up Anypoint Platform credentials...
echo    Organization: %ANYPOINT_ORG_ID%
echo    Environment: %ANYPOINT_ENV%
echo    Client ID: %ANYPOINT_CLIENT_ID%

REM Set environment variables for CLI v4 authentication
set ANYPOINT_CLIENT_ID=%ANYPOINT_CLIENT_ID%
set ANYPOINT_CLIENT_SECRET=%ANYPOINT_CLIENT_SECRET%
set ANYPOINT_ORG=%ANYPOINT_ORG_ID%
set ANYPOINT_ENV=%ANYPOINT_ENV%

echo ✅ Credentials configured!

REM Set deployment parameters from .env
set ENVIRONMENT=%ANYPOINT_ENV%
set REGION=%CLOUDHUB_REGION%
set WORKER_SIZE=0.1
set WORKERS=%CLOUDHUB_WORKERS%
set RUNTIME_VERSION=%MULE_VERSION%

REM Convert MICRO worker type to numeric value
if "%CLOUDHUB_WORKER_TYPE%"=="MICRO" set WORKER_SIZE=0.1
if "%CLOUDHUB_WORKER_TYPE%"=="SMALL" set WORKER_SIZE=0.2
if "%CLOUDHUB_WORKER_TYPE%"=="MEDIUM" set WORKER_SIZE=1
if "%CLOUDHUB_WORKER_TYPE%"=="LARGE" set WORKER_SIZE=2
if "%CLOUDHUB_WORKER_TYPE%"=="XLARGE" set WORKER_SIZE=4

echo.
echo 🔧 Building all applications...
echo ========================================

REM Build Employee Onboarding MCP Server (Main)
echo 📦 Building Employee Onboarding MCP Server...
call mvn clean package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Employee Onboarding MCP Server
    exit /b 1
)

REM Build Asset Allocation MCP Server
echo 📦 Building Asset Allocation MCP Server...
cd asset-allocation-mcp
call mvn clean package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Asset Allocation MCP Server
    cd ..
    exit /b 1
)
cd ..

REM Build Notification MCP Server
echo 📦 Building Notification MCP Server...
cd notification-mcp
call mvn clean package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Notification MCP Server
    cd ..
    exit /b 1
)
cd ..

REM Build Agent Broker
echo 📦 Building Employee Onboarding Agent Broker...
cd employee-onboarding-agent-broker
call mvn clean package -DskipTests -q
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Agent Broker
    cd ..
    exit /b 1
)
cd ..

echo.
echo 🚀 Starting CloudHub deployments...
echo ========================================
echo    Environment: %ENVIRONMENT%
echo    Region: %REGION%
echo    Worker Size: %WORKER_SIZE% vCores (%CLOUDHUB_WORKER_TYPE%)
echo    Workers: %WORKERS%
echo    Runtime: %RUNTIME_VERSION%
echo.

REM Deploy Employee Onboarding MCP Server
echo 📡 Deploying Employee Onboarding MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  employee-onboarding-mcp-server ^
  target/employee-onboarding-mcp-server-1.0.0-mule-application.jar ^
  --runtime "%RUNTIME_VERSION%" ^
  --workers %WORKERS% ^
  --workerSize %WORKER_SIZE% ^
  --region %REGION% ^
  --environment "%ENVIRONMENT%" ^
  --property "http.port:8081" ^
  --property "db.url:%DATABASE_URL%" ^
  --property "mcp.serverName:Employee Onboarding MCP Server" ^
  --property "mcp.serverVersion:1.0.0" ^
  --property "env:production" ^
  --property "logging.level:INFO" ^
  --objectStoreV2

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to deploy Employee Onboarding MCP Server
    exit /b 1
)
echo ✅ Employee Onboarding MCP Server deployed successfully!

REM Deploy Asset Allocation MCP Server
echo 📡 Deploying Asset Allocation MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  asset-allocation-mcp-server ^
  asset-allocation-mcp/target/asset-allocation-mcp-server-1.0.0-mule-application.jar ^
  --runtime "%RUNTIME_VERSION%" ^
  --workers %WORKERS% ^
  --workerSize %WORKER_SIZE% ^
  --region %REGION% ^
  --environment "%ENVIRONMENT%" ^
  --property "http.port:8082" ^
  --property "db.url:%DATABASE_URL%" ^
  --property "mcp.serverName:Asset Allocation MCP Server" ^
  --property "mcp.serverVersion:1.0.0" ^
  --property "env:production" ^
  --property "logging.level:INFO" ^
  --objectStoreV2

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to deploy Asset Allocation MCP Server
    exit /b 1
)
echo ✅ Asset Allocation MCP Server deployed successfully!

REM Deploy Notification MCP Server
echo 📡 Deploying Notification MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  notification-mcp-server ^
  notification-mcp/target/notification-mcp-server-1.0.0-mule-application.jar ^
  --runtime "%RUNTIME_VERSION%" ^
  --workers %WORKERS% ^
  --workerSize %WORKER_SIZE% ^
  --region %REGION% ^
  --environment "%ENVIRONMENT%" ^
  --property "http.port:8083" ^
  --property "gmail.username:%GMAIL_USER%" ^
  --property "gmail.password:%GMAIL_PASSWORD%" ^
  --property "mcp.serverName:Notification MCP Server" ^
  --property "mcp.serverVersion:1.0.0" ^
  --property "env:production" ^
  --property "logging.level:INFO" ^
  --objectStoreV2

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to deploy Notification MCP Server
    exit /b 1
)
echo ✅ Notification MCP Server deployed successfully!

REM Deploy Agent Broker (Essential for orchestration)
echo 📡 Deploying Employee Onboarding Agent Broker...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  employee-onboarding-agent-broker ^
  employee-onboarding-agent-broker/target/employee-onboarding-agent-broker-1.0.0-mule-application.jar ^
  --runtime "%RUNTIME_VERSION%" ^
  --workers %WORKERS% ^
  --workerSize %WORKER_SIZE% ^
  --region %REGION% ^
  --environment "%ENVIRONMENT%" ^
  --property "http.port:8084" ^
  --property "employee.onboarding.mcp.url:https://employee-onboarding-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com" ^
  --property "asset.allocation.mcp.url:https://asset-allocation-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com" ^
  --property "notification.mcp.url:https://notification-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com" ^
  --property "mcp.serverName:Employee Onboarding Agent Broker" ^
  --property "mcp.serverVersion:1.0.0" ^
  --property "agent.broker.orchestration.enabled:true" ^
  --property "groq.api.key:%GROQ_API_KEY%" ^
  --property "env:production" ^
  --property "logging.level:INFO" ^
  --objectStoreV2

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to deploy Agent Broker
    exit /b 1
)
echo ✅ Employee Onboarding Agent Broker deployed successfully!

echo.
echo ⏳ Waiting for applications to start (120 seconds)...
echo    This allows time for all services to initialize properly...
timeout /t 120 /nobreak

echo.
echo 🏥 Performing health checks...
echo ========================================

REM Health check function using curl
set HEALTH_CHECK_PASSED=true

curl -s -f -o nul "https://employee-onboarding-mcp-server.sandbox.anypoint.mulesoft.com/health"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Employee Onboarding MCP Server is healthy
) else (
    echo ❌ Employee Onboarding MCP Server health check failed
    set HEALTH_CHECK_PASSED=false
)

curl -s -f -o nul "https://asset-allocation-mcp-server.sandbox.anypoint.mulesoft.com/health"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Asset Allocation MCP Server is healthy
) else (
    echo ❌ Asset Allocation MCP Server health check failed
    set HEALTH_CHECK_PASSED=false
)

curl -s -f -o nul "https://notification-mcp-server.sandbox.anypoint.mulesoft.com/health"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Notification MCP Server is healthy
) else (
    echo ❌ Notification MCP Server health check failed
    set HEALTH_CHECK_PASSED=false
)

curl -s -f -o nul "https://employee-onboarding-agent-broker.sandbox.anypoint.mulesoft.com/health"
if %ERRORLEVEL% EQU 0 (
    echo ✅ Employee Onboarding Agent Broker is healthy
) else (
    echo ❌ Employee Onboarding Agent Broker health check failed
    set HEALTH_CHECK_PASSED=false
)

echo.
if "%HEALTH_CHECK_PASSED%"=="false" (
    echo ⚠️ Some health checks failed. Check application logs for details.
    echo.
    echo 🔍 Troubleshooting commands:
    echo    anypoint-cli-v4 cloudhub:app:log employee-onboarding-mcp-server --environment %ENVIRONMENT%
    echo    anypoint-cli-v4 cloudhub:app:log asset-allocation-mcp-server --environment %ENVIRONMENT%
    echo    anypoint-cli-v4 cloudhub:app:log notification-mcp-server --environment %ENVIRONMENT%
    echo    anypoint-cli-v4 cloudhub:app:log employee-onboarding-agent-broker --environment %ENVIRONMENT%
) else (
    echo 🎉 All applications deployed and healthy!
)

echo 🧪 Running end-to-end test...

REM Test complete orchestration workflow
echo 📝 Testing complete employee onboarding orchestration...
curl -X POST "https://employee-onboarding-agent-broker.sandbox.anypoint.mulesoft.com/mcp/tools/orchestrate-employee-onboarding" ^
  -H "Content-Type: application/json" ^
  -d "{\"firstName\":\"Test\",\"lastName\":\"Employee\",\"email\":\"test.employee@company.com\",\"department\":\"Engineering\",\"position\":\"Software Developer\",\"startDate\":\"2024-03-01\",\"manager\":\"Test Manager\",\"managerEmail\":\"test.manager@company.com\",\"companyName\":\"Test Corp\",\"assets\":[{\"category\":\"laptop\",\"specifications\":\"MacBook Pro\"},{\"category\":\"monitor\",\"specifications\":\"27-inch 4K\"}]}"

if %ERRORLEVEL% EQU 0 (
    echo ✅ End-to-end orchestration test passed!
) else (
    echo ❌ End-to-end orchestration test failed
)

echo.
echo ========================================
echo 📋 DEPLOYMENT SUMMARY
echo ========================================
echo.
echo 🌐 Application URLs:
echo • Employee Onboarding MCP Server: https://employee-onboarding-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com
echo • Asset Allocation MCP Server: https://asset-allocation-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com
echo • Notification MCP Server: https://notification-mcp-server.%ANYPOINT_ENV%.anypoint.mulesoft.com
echo • 🤖 Agent Broker (Orchestrator): https://employee-onboarding-agent-broker.%ANYPOINT_ENV%.anypoint.mulesoft.com
echo.
echo 🔧 Next Steps:
echo 1. Test individual MCP tools via their respective endpoints
echo 2. Use the Agent Broker for complete workflow orchestration
echo 3. Test with natural language requests using the Python NLP script
echo 4. Monitor applications via Anypoint Runtime Manager
echo.
echo 🎯 Main Orchestration Endpoint:
echo POST https://employee-onboarding-agent-broker.%ANYPOINT_ENV%.anypoint.mulesoft.com/mcp/tools/orchestrate-employee-onboarding
echo.
echo 📅 Deployment completed at: %date% %time%
echo ========================================

echo.
echo Press any key to exit...
pause >nul
exit /b 0
