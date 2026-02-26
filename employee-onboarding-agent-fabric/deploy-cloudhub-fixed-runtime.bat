@echo off
echo ========================================
echo CLOUDHUB DEPLOYMENT - FIXED RUNTIME
echo Using Latest Supported Mule Runtime
echo ========================================

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
    -Dcloudhub.muleVersion=4.8.0:40e-java17 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ NOTIFICATION MCP DEPLOYMENT FAILED! Trying alternative runtime...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=notification-mcp-server ^
        -Dcloudhub.muleVersion=4.7.2 ^
        -Dcloudhub.javaVersion=17 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ NOTIFICATION MCP DEPLOYMENT FAILED WITH BOTH RUNTIMES!
    echo Checking available runtimes...
    mvn mule:list-runtimes -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 -Danypoint.environment=Sandbox
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ NOTIFICATION MCP DEPLOYED SUCCESSFULLY!
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
    -Dcloudhub.muleVersion=4.8.0:40e-java17 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ EMPLOYEE ONBOARDING MCP DEPLOYMENT FAILED! Trying alternative runtime...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=employee-onboarding-mcp-server ^
        -Dcloudhub.muleVersion=4.7.2 ^
        -Dcloudhub.javaVersion=17 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ EMPLOYEE ONBOARDING MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ EMPLOYEE ONBOARDING MCP DEPLOYED SUCCESSFULLY!
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
    -Dcloudhub.muleVersion=4.8.0:40e-java17 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ ASSET ALLOCATION MCP DEPLOYMENT FAILED! Trying alternative runtime...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=asset-allocation-mcp-server ^
        -Dcloudhub.muleVersion=4.7.2 ^
        -Dcloudhub.javaVersion=17 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ ASSET ALLOCATION MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ ASSET ALLOCATION MCP DEPLOYED SUCCESSFULLY!
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
    -Dcloudhub.muleVersion=4.8.0:40e-java17 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ❌ AGENT BROKER MCP DEPLOYMENT FAILED! Trying alternative runtime...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=agent-broker-mcp-server ^
        -Dcloudhub.muleVersion=4.7.2 ^
        -Dcloudhub.javaVersion=17 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ AGENT BROKER MCP DEPLOYMENT FAILED!
    pause
    exit /b %ERRORLEVEL%
) else (
    echo ✅ AGENT BROKER MCP DEPLOYED SUCCESSFULLY!
)

echo.
echo ================================
echo 🎉 DEPLOYMENT COMPLETE!
echo ================================

echo.
echo Your Agent Fabric is now deployed with fixed runtime:
echo.
echo 🔔 Notification MCP:        https://notification-mcp-server.us-e1.cloudhub.io/health
echo 👥 Employee Onboarding MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
echo 💼 Asset Allocation MCP:    https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
echo 🤖 Agent Broker MCP:        https://agent-broker-mcp-server.us-e1.cloudhub.io/health
echo.

pause
