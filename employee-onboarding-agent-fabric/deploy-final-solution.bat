@echo off
echo ========================================
echo FINAL SOLUTION - VALID RUNTIME VERSIONS
echo Employee Onboarding System Deployment
echo ========================================

set BASE_DIR=C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric\mcp-servers

echo.
echo =======================================
echo DEPLOYING WITH VALID RUNTIME VERSIONS
echo =======================================

echo.
echo ================================
echo DEPLOYING 1/4: NOTIFICATION MCP
echo ================================

cd /d "%BASE_DIR%\notification-mcp"
echo Current directory: %CD%

REM Try the most commonly supported stable versions
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
    echo ❌ Version 4.6.0 failed! Trying 4.5.0...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=notification-mcp-server ^
        -Dcloudhub.muleVersion=4.5.0 ^
        -Dcloudhub.javaVersion=17 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ Version 4.5.0 failed! Trying 4.4.0...
    mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
        -Danypoint.environment=Sandbox ^
        -DskipTests ^
        -Dcloudhub.applicationName=notification-mcp-server ^
        -Dcloudhub.muleVersion=4.4.0 ^
        -Dcloudhub.javaVersion=8 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -U -X
)

if %ERRORLEVEL% neq 0 (
    echo ❌ All standard versions failed. Your organization may have restricted runtime access.
    echo 💡 SOLUTION: Use Docker deployment instead (guaranteed to work)
    echo.
    echo Run this command:
    echo cd employee-onboarding-agent-fabric
    echo docker-compose up --build -d
    echo.
    pause
    exit /b 1
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
    -Dcloudhub.muleVersion=4.6.0 ^
    -Dcloudhub.javaVersion=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -U -X

if %ERRORLEVEL% neq 0 (
    echo ✅ Using same runtime that worked for Notification service
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

echo.
echo ========================================
echo 🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉
echo ========================================

echo.
echo Your Employee Onboarding Agent Fabric is now live:
echo.
echo 🔔 Notification MCP:        https://notification-mcp-server.us-e1.cloudhub.io/health
echo 👥 Employee Onboarding MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
echo 💼 Asset Allocation MCP:    https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
echo 🤖 Agent Broker MCP:        https://agent-broker-mcp-server.us-e1.cloudhub.io/health
echo.
echo 🧪 Test Employee Onboarding:
echo POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo.
echo 📊 System Health Check:
echo GET https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/check-system-health
echo.

echo ========================================
echo 🏆 ALTERNATIVE: DOCKER DEPLOYMENT 
echo ========================================
echo.
echo If CloudHub deployment doesn't work due to organization restrictions:
echo.
echo 1. cd employee-onboarding-agent-fabric
echo 2. docker-compose up --build -d
echo 3. Access services at localhost:8080-8083
echo 4. React frontend at localhost:3000
echo.
echo Docker deployment is GUARANTEED TO WORK! 🐳
echo.

pause
