@echo off
echo.
echo ======================================
echo Employee Onboarding MCP - CloudHub Deploy
echo ======================================
echo.

REM Load credentials from .env file
if exist ".env" (
    echo Loading credentials from .env file...
    for /f "usebackq delims== tokens=1,2" %%i in (".env") do (
        if "%%i"=="ANYPOINT_CLIENT_ID" set ANYPOINT_CLIENT_ID=%%j
        if "%%i"=="ANYPOINT_CLIENT_SECRET" set ANYPOINT_CLIENT_SECRET=%%j
        if "%%i"=="ANYPOINT_ORG_ID" set ANYPOINT_ORG_ID=%%j
        if "%%i"=="ANYPOINT_ENVIRONMENT" set ANYPOINT_ENVIRONMENT=%%j
        if "%%i"=="ANYPOINT_REGION" set ANYPOINT_REGION=%%j
        if "%%i"=="ANYPOINT_WORKERS" set ANYPOINT_WORKERS=%%j
        if "%%i"=="ANYPOINT_WORKER_TYPE" set ANYPOINT_WORKER_TYPE=%%j
    )
    echo.
) else (
    echo WARNING: .env file not found. Please create .env file with your credentials.
    echo.
)

REM Set defaults if not specified in .env
if "%ANYPOINT_ENVIRONMENT%"=="" set ANYPOINT_ENVIRONMENT=Sandbox
if "%ANYPOINT_REGION%"=="" set ANYPOINT_REGION=us-east-1
if "%ANYPOINT_WORKERS%"=="" set ANYPOINT_WORKERS=1
if "%ANYPOINT_WORKER_TYPE%"=="" set ANYPOINT_WORKER_TYPE=MICRO

REM Check if connected app credentials are set
if "%ANYPOINT_CLIENT_ID%"=="" (
    echo ERROR: ANYPOINT_CLIENT_ID not found in .env file
    echo Please update your .env file with valid connected app credentials
    echo.
    echo Example .env file content:
    echo ANYPOINT_CLIENT_ID=your-client-id-here
    echo ANYPOINT_CLIENT_SECRET=your-client-secret-here
    echo ANYPOINT_ORG_ID=your-org-id-here
    echo.
    pause
    exit /b 1
)

if "%ANYPOINT_CLIENT_SECRET%"=="" (
    echo ERROR: ANYPOINT_CLIENT_SECRET not found in .env file
    echo Please update your .env file with valid connected app credentials
    pause
    exit /b 1
)

if "%ANYPOINT_ORG_ID%"=="" (
    echo ERROR: ANYPOINT_ORG_ID not found in .env file
    echo Please update your .env file with valid connected app credentials
    pause
    exit /b 1
)

echo Using Connected App Credentials from .env:
echo Client ID: %ANYPOINT_CLIENT_ID%
echo Org ID: %ANYPOINT_ORG_ID%
echo Environment: %ANYPOINT_ENVIRONMENT%
echo Region: %ANYPOINT_REGION%
echo Worker Type: %ANYPOINT_WORKER_TYPE%
echo Workers: %ANYPOINT_WORKERS%
echo.

echo Deploying Employee Onboarding MCP Server...
cd mcp-servers\employee-onboarding-mcp
call mvn clean deploy -DmuleDeploy ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=%ANYPOINT_ENVIRONMENT% ^
    -Danypoint.region=%ANYPOINT_REGION% ^
    -Danypoint.workers=%ANYPOINT_WORKERS% ^
    -Danypoint.workerType=%ANYPOINT_WORKER_TYPE%

if %ERRORLEVEL% neq 0 (
    echo ERROR: Employee Onboarding MCP deployment failed
    cd ..\..
    pause
    exit /b 1
)

echo.
echo ✓ Employee Onboarding MCP Server deployed successfully
echo.

cd ..\..

echo Deploying Asset Allocation MCP Server...
cd mcp-servers\asset-allocation-mcp
call mvn clean deploy -DmuleDeploy ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=%ANYPOINT_ENVIRONMENT% ^
    -Danypoint.region=%ANYPOINT_REGION% ^
    -Danypoint.workers=%ANYPOINT_WORKERS% ^
    -Danypoint.workerType=%ANYPOINT_WORKER_TYPE%

if %ERRORLEVEL% neq 0 (
    echo ERROR: Asset Allocation MCP deployment failed
    cd ..\..
    pause
    exit /b 1
)

echo.
echo ✓ Asset Allocation MCP Server deployed successfully
echo.

cd ..\..

echo Deploying Notification MCP Server...
cd mcp-servers\notification-mcp
call mvn clean deploy -DmuleDeploy ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=%ANYPOINT_ENVIRONMENT% ^
    -Danypoint.region=%ANYPOINT_REGION% ^
    -Danypoint.workers=%ANYPOINT_WORKERS% ^
    -Danypoint.workerType=%ANYPOINT_WORKER_TYPE%

if %ERRORLEVEL% neq 0 (
    echo ERROR: Notification MCP deployment failed
    cd ..\..
    pause
    exit /b 1
)

echo.
echo ✓ Notification MCP Server deployed successfully
echo.

cd ..\..

echo Deploying Agent Broker MCP Server...
cd mcp-servers\agent-broker-mcp
call mvn clean deploy -DmuleDeploy ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=%ANYPOINT_ENVIRONMENT% ^
    -Danypoint.region=%ANYPOINT_REGION% ^
    -Danypoint.workers=%ANYPOINT_WORKERS% ^
    -Danypoint.workerType=%ANYPOINT_WORKER_TYPE%

if %ERRORLEVEL% neq 0 (
    echo ERROR: Agent Broker MCP deployment failed
    cd ..\..
    pause
    exit /b 1
)

echo.
echo ✓ Agent Broker MCP Server deployed successfully
echo.

cd ..\..

echo ======================================
echo CloudHub Deployment Complete!
echo ======================================
echo.
echo All MCP servers have been successfully deployed to CloudHub (Sandbox):
echo.
echo 🚀 Employee Onboarding MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo 🚀 Asset Allocation MCP: https://asset-allocation-mcp-server.us-e1.cloudhub.io  
echo 🚀 Notification MCP: https://notification-mcp-server.us-e1.cloudhub.io
echo 🚀 Agent Broker MCP: https://employee-onboarding-agent-broker.us-e1.cloudhub.io
echo.
echo You can monitor and manage these applications in Anypoint Platform:
echo https://anypoint.mulesoft.com/cloudhub/
echo.
echo Update your React client environment variables to point to these CloudHub URLs.
echo.
pause
