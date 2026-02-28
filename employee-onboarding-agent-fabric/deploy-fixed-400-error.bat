@echo off
setlocal enabledelayedexpansion

echo ================================================================
echo MULE VERSION 400 ERROR FIX - CLOUDHUB DEPLOYMENT
echo ================================================================
echo Fixed: Mule runtime version from 4.9-java17 to 4.9.0
echo All MCP servers now use CloudHub-compatible version format
echo ================================================================
echo.

:: Load environment variables
if exist .env (
    echo Loading .env file...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
        )
    )
    echo Environment variables loaded from .env
) else (
    echo WARNING: .env file not found!
    echo Please ensure you have proper credentials configured.
    pause
    exit /b 1
)

echo.
echo ================================================================
echo DEPLOYING NOTIFICATION MCP SERVER TO CLOUDHUB
echo ================================================================
echo Using Mule Runtime Version: 4.9.0 (Java 17 compatible)
echo CloudHub Target: employee-notification-service
echo Environment: %ANYPOINT_ENV%
echo Organization: %ANYPOINT_ORG_ID%
echo ================================================================
echo.

cd mcp-servers\notification-mcp

echo Starting deployment...
echo Running: mvn clean deploy -DmuleDeploy
echo.

mvn clean deploy -DmuleDeploy ^
    -Danypoint.platform.client_id=%ANYPOINT_CLIENT_ID% ^
    -Danypoint.platform.client_secret=%ANYPOINT_CLIENT_SECRET% ^
    -Danypoint.business.group=%ANYPOINT_ORG_ID% ^
    -Danypoint.platform.env=%ANYPOINT_ENV% ^
    -Dapplication.name=employee-notification-service ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.worker.type=MICRO ^
    -X

set DEPLOY_EXIT_CODE=%ERRORLEVEL%

cd ..\..

echo.
echo ================================================================
if %DEPLOY_EXIT_CODE%==0 (
    echo ✅ SUCCESS: Notification MCP Server deployed successfully!
    echo CloudHub Application: employee-notification-service
    echo Runtime Version: 4.9.0 
    echo Java Version: 17
    echo.
    echo Next Steps:
    echo 1. Check CloudHub Console for application status
    echo 2. Test the deployed endpoints
    echo 3. Deploy other MCP servers using same version fix
) else (
    echo ❌ DEPLOYMENT FAILED with exit code: %DEPLOY_EXIT_CODE%
    echo.
    echo The Mule version fix resolved the 400 error, but there may be other issues.
    echo Check the Maven output above for details.
)
echo ================================================================

pause
