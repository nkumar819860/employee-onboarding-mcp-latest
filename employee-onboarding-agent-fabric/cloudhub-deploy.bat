@echo off
echo.
echo ======================================
echo Employee Onboarding MCP - CloudHub Deploy
echo ======================================
echo.

REM Check if connected app credentials are set
if "%ANYPOINT_CLIENT_ID%"=="" (
    echo ERROR: ANYPOINT_CLIENT_ID environment variable is not set
    echo Please set your connected app credentials before running this script
    echo.
    echo Example:
    echo set ANYPOINT_CLIENT_ID=your-client-id-here
    echo set ANYPOINT_CLIENT_SECRET=your-client-secret-here
    echo set ANYPOINT_ORG_ID=your-org-id-here
    echo.
    pause
    exit /b 1
)

if "%ANYPOINT_CLIENT_SECRET%"=="" (
    echo ERROR: ANYPOINT_CLIENT_SECRET environment variable is not set
    echo Please set your connected app credentials before running this script
    pause
    exit /b 1
)

if "%ANYPOINT_ORG_ID%"=="" (
    echo ERROR: ANYPOINT_ORG_ID environment variable is not set
    echo Please set your connected app credentials before running this script
    pause
    exit /b 1
)

echo Using Connected App Credentials:
echo Client ID: %ANYPOINT_CLIENT_ID%
echo Org ID: %ANYPOINT_ORG_ID%
echo.

echo Deploying Employee Onboarding MCP Server...
cd mcp-servers\employee-onboarding-mcp
call mvn clean deploy -DmuleDeploy -Dmule.maven.plugin.version=4.1.0 ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=Sandbox ^
    -Danypoint.region=us-east-1 ^
    -Danypoint.workers=1 ^
    -Danypoint.workerType=MICRO

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
call mvn clean deploy -DmuleDeploy -Dmule.maven.plugin.version=4.1.0 ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=Sandbox ^
    -Danypoint.region=us-east-1 ^
    -Danypoint.workers=1 ^
    -Danypoint.workerType=MICRO

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
call mvn clean deploy -DmuleDeploy -Dmule.maven.plugin.version=4.1.0 ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=Sandbox ^
    -Danypoint.region=us-east-1 ^
    -Danypoint.workers=1 ^
    -Danypoint.workerType=MICRO

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
call mvn clean deploy -DmuleDeploy -Dmule.maven.plugin.version=4.1.0 ^
    -Danypoint.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.organization_id=%ANYPOINT_ORG_ID% ^
    -Danypoint.environment=Sandbox ^
    -Danypoint.region=us-east-1 ^
    -Danypoint.workers=1 ^
    -Danypoint.workerType=MICRO

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
