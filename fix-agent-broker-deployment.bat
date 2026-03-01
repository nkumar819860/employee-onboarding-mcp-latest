@echo off
echo ======================================
echo Agent Broker MCP Server Deployment Fix
echo ======================================
echo.
echo This script will redeploy the agent-broker-mcp-server with the following fixes:
echo 1. Updated mule-artifact.json to use APIKit router configuration only
echo 2. Updated OpenAPI specification with correct /api prefix URLs
echo.
echo Fixed configuration will resolve:
echo - Deployment error: Config not found employee-onboarding-agent-broker.xml
echo - Method Not Allowed errors due to URL path mismatch
echo.

set /p CONTINUE="Continue with deployment? (y/n): "
if /i "%CONTINUE%" neq "y" (
    echo Deployment cancelled.
    pause
    exit /b 0
)

echo.
echo Deploying agent-broker-mcp-server with fixes...
echo.

cd employee-onboarding-agent-fabric\mcp-servers\agent-broker-mcp

rem Deploy to CloudHub
echo Deploying to CloudHub...
call mvn clean deploy -DmuleDeploy ^
    -Dmule.version=4.4.0 ^
    -Danypoint.username=%ANYPOINT_USERNAME% ^
    -Danypoint.password=%ANYPOINT_PASSWORD% ^
    -DapplicationName=agent-broker-mcp-server ^
    -Denvironment=Sandbox ^
    -DworkerType=MICRO ^
    -Dworkers=1 ^
    -DobjectStoreV2=true ^
    -DpersistentQueues=false ^
    -Dregion=us-east-1

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo DEPLOYMENT SUCCESSFUL!
    echo ========================================
    echo.
    echo The agent-broker-mcp-server has been deployed with fixes.
    echo.
    echo Correct endpoint URLs are now:
    echo - Health Check: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health
    echo - MCP Info: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info
    echo - Orchestrate Onboarding: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding
    echo - Get Status: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/get-onboarding-status
    echo - Retry Step: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/retry-failed-step
    echo.
    echo Test the fix with:
    echo curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
    echo.
) else (
    echo.
    echo ========================================
    echo DEPLOYMENT FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above and ensure:
    echo 1. ANYPOINT_USERNAME and ANYPOINT_PASSWORD environment variables are set
    echo 2. You have the necessary permissions to deploy to CloudHub
    echo 3. The Sandbox environment is accessible
    echo.
    echo For debugging, you can also try:
    echo mvn clean package
    echo.
)

cd ..\..\..
pause
