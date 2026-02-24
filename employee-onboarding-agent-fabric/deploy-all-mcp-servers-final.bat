@echo off
echo ================================
echo DEPLOYING ALL MCP SERVERS - FINAL FIX
echo ================================

set BASE_DIR=C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric\mcp-servers

echo.
echo ================================
echo DEPLOYING 1/4: NOTIFICATION MCP
echo ================================

cd /d "%BASE_DIR%\notification-mcp"
echo Current directory: %CD%

mvn clean deploy ^
    -DmuleDeploy ^
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.environment=Sandbox ^
    -DskipTests ^
    -Dcloudhub.applicationName=notification-mcp-server ^
    -Dcloudhub.muleVersion=4.6.0 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ NOTIFICATION MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ NOTIFICATION MCP DEPLOYED SUCCESSFULLY!
    echo Available at: https://notification-mcp-server.us-e1.cloudhub.io/health
)

echo.
echo ================================
echo DEPLOYING 2/4: EMPLOYEE ONBOARDING MCP
echo ================================

cd /d "%BASE_DIR%\employee-onboarding-mcp"
echo Current directory: %CD%

mvn clean deploy ^
    -DmuleDeploy ^
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.environment=Sandbox ^
    -DskipTests ^
    -Dcloudhub.applicationName=employee-onboarding-mcp-server ^
    -Dcloudhub.muleVersion=4.6.0 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ EMPLOYEE ONBOARDING MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ EMPLOYEE ONBOARDING MCP DEPLOYED SUCCESSFULLY!
    echo Available at: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
)

echo.
echo ================================
echo DEPLOYING 3/4: ASSET ALLOCATION MCP
echo ================================

cd /d "%BASE_DIR%\asset-allocation-mcp"
echo Current directory: %CD%

mvn clean deploy ^
    -DmuleDeploy ^
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.environment=Sandbox ^
    -DskipTests ^
    -Dcloudhub.applicationName=asset-allocation-mcp-server ^
    -Dcloudhub.muleVersion=4.6.0 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ ASSET ALLOCATION MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ ASSET ALLOCATION MCP DEPLOYED SUCCESSFULLY!
    echo Available at: https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
)

echo.
echo ================================
echo DEPLOYING 4/4: AGENT BROKER MCP
echo ================================

cd /d "%BASE_DIR%\agent-broker-mcp"
echo Current directory: %CD%

mvn clean deploy ^
    -DmuleDeploy ^
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.environment=Sandbox ^
    -DskipTests ^
    -Dcloudhub.applicationName=agent-broker-mcp-server ^
    -Dcloudhub.muleVersion=4.6.0 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ AGENT BROKER MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ AGENT BROKER MCP DEPLOYED SUCCESSFULLY!
    echo Available at: https://agent-broker-mcp-server.us-e1.cloudhub.io/health
)

echo.
echo ================================
echo 🎉 ALL MCP SERVERS DEPLOYMENT COMPLETE!
echo ================================

echo.
echo Your Agent Fabric is now fully deployed:
echo.
echo 🔔 Notification MCP:        https://notification-mcp-server.us-e1.cloudhub.io/mcp/info
echo 👥 Employee Onboarding MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info
echo 💼 Asset Allocation MCP:    https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info
echo 🤖 Agent Broker MCP:        https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info
echo.
echo To test the complete orchestration:
echo POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo.

pause
