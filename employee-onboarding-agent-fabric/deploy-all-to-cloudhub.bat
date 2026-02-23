@echo off
echo ========================================
echo CloudHub Deployment Script for All MCP Servers
echo ========================================
echo.
echo This script deploys all MCP servers to CloudHub with correct Mule version 4.4.0
echo.

echo Setting up environment variables...
set /p USERNAME="Enter Anypoint Username: "
set /p PASSWORD="Enter Anypoint Password: "

echo.
echo ========================================
echo Deploying Agent Broker MCP
echo ========================================
cd mcp-servers\agent-broker-mcp
echo Building and deploying agent-broker-mcp...
mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ❌ Build failed for agent-broker-mcp
    goto :error
)

mvn deploy -DmuleDeploy -Danypoint.username=%USERNAME% -Danypoint.password=%PASSWORD%
if %errorlevel% neq 0 (
    echo ❌ Deployment failed for agent-broker-mcp
    goto :error
) else (
    echo ✅ agent-broker-mcp deployed successfully
)
cd ..\..

echo.
echo ========================================
echo Deploying Employee Onboarding MCP
echo ========================================
cd mcp-servers\employee-onboarding-mcp
echo Building and deploying employee-onboarding-mcp...
mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ❌ Build failed for employee-onboarding-mcp
    goto :error
)

mvn deploy -DmuleDeploy -Danypoint.username=%USERNAME% -Danypoint.password=%PASSWORD%
if %errorlevel% neq 0 (
    echo ❌ Deployment failed for employee-onboarding-mcp
    goto :error
) else (
    echo ✅ employee-onboarding-mcp deployed successfully
)
cd ..\..

echo.
echo ========================================
echo Deploying Asset Allocation MCP
echo ========================================
cd mcp-servers\asset-allocation-mcp
echo Building and deploying asset-allocation-mcp...
mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ❌ Build failed for asset-allocation-mcp
    goto :error
)

mvn deploy -DmuleDeploy -Danypoint.username=%USERNAME% -Danypoint.password=%PASSWORD%
if %errorlevel% neq 0 (
    echo ❌ Deployment failed for asset-allocation-mcp
    goto :error
) else (
    echo ✅ asset-allocation-mcp deployed successfully
)
cd ..\..

echo.
echo ========================================
echo Deploying Notification MCP
echo ========================================
cd mcp-servers\notification-mcp
echo Building and deploying notification-mcp...
mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo ❌ Build failed for notification-mcp
    goto :error
)

mvn deploy -DmuleDeploy -Danypoint.username=%USERNAME% -Danypoint.password=%PASSWORD%
if %errorlevel% neq 0 (
    echo ❌ Deployment failed for notification-mcp
    goto :error
) else (
    echo ✅ notification-mcp deployed successfully
)
cd ..\..

echo.
echo ========================================
echo ✅ ALL MCP SERVERS DEPLOYED SUCCESSFULLY!
echo ========================================
echo.
echo Deployed Applications:
echo - employee-onboarding-agent-broker
echo - employee-onboarding-mcp-server  
echo - asset-allocation-mcp-server
echo - notification-mcp-server
echo.
echo All applications are running on Mule Runtime 4.4.0 in CloudHub
echo Check your Anypoint Platform Runtime Manager for deployment status
echo.
goto :end

:error
echo.
echo ❌ DEPLOYMENT FAILED
echo Check the error messages above for details
echo.
exit /b 1

:end
echo Deployment process completed.
pause
