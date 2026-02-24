@echo off
echo ================================
echo DEPLOYING NOTIFICATION MCP - FINAL FIX
echo ================================

cd /d "C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric\mcp-servers\notification-mcp"

echo Current directory: %CD%

echo.
echo ================================
echo BUILDING AND DEPLOYING...
echo ================================

REM Use single command with deploy goal that includes both build and deploy
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

echo.
echo ================================
echo Deployment completed with exit code: %ERRORLEVEL%
echo ================================

if %ERRORLEVEL% equ 0 (
    echo ✅ DEPLOYMENT SUCCESSFUL!
    echo.
    echo Your application should now be available at:
    echo https://notification-mcp-server.us-e1.cloudhub.io/health
    echo.
    echo To test the MCP server info:
    echo https://notification-mcp-server.us-e1.cloudhub.io/mcp/info
    echo.
    echo To test a notification tool:
    echo POST https://notification-mcp-server.us-e1.cloudhub.io/mcp/tools/test-email-config
) else (
    echo ❌ DEPLOYMENT FAILED with error code: %ERRORLEVEL%
    echo Check the Maven output above for error details.
)

pause
