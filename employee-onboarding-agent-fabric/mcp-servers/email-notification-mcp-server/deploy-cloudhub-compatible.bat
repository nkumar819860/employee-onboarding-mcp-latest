@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ================================================================
echo  DEPLOYING NOTIFICATION MCP WITH CLOUDHUB JAVA 11 COMPATIBILITY
echo ================================================================

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo 🔧 Switching to CloudHub-compatible configuration...

REM Load .env file from project root (go up 2 levels)
set ENV_FILE=..\..\.env
if exist "%ENV_FILE%" (
    echo 📋 Loading environment variables from .env...
    for /f "tokens=1,2 delims==" %%a in (%ENV_FILE%) do (
        if not "%%a"=="" if not "%%b"=="" set %%a=%%b
    )
    echo ✅ Environment loaded successfully
) else (
    echo ❌ .env file not found at %ENV_FILE%
    echo 💡 Please ensure .env file exists in project root with:
    echo    ANYPOINT_CLIENT_ID=your_client_id
    echo    ANYPOINT_CLIENT_SECRET=your_client_secret
    pause
    exit /b 1
)

REM Backup original files
if not exist "pom.xml.backup" (
    echo 📋 Backing up original pom.xml...
    copy pom.xml pom.xml.backup >nul
)

if not exist "mule-artifact.json.backup" (
    echo 📋 Backing up original mule-artifact.json...
    copy mule-artifact.json mule-artifact.json.backup >nul
)

REM Switch to CloudHub-compatible files
echo 🔄 Switching to Java 11 compatible configuration...
copy pom-cloudhub.xml pom.xml >nul
copy mule-artifact-cloudhub.json mule-artifact.json >nul

if !ERRORLEVEL! neq 0 (
    echo ❌ Failed to switch configuration files
    pause
    exit /b 1
)

echo ✅ Configuration switched successfully
echo 📝 Current configuration:
echo    - Java Version: 11
echo    - Mule Runtime: 4.8
echo    - CloudHub Compatible: YES

echo.
echo 🚀 Starting CloudHub deployment...
echo.

REM Deploy using Maven
call mvn clean deploy -DmuleDeploy -Danypoint.platform.client_id=%ANYPOINT_CLIENT_ID% -Danypoint.platform.client_secret=%ANYPOINT_CLIENT_SECRET%

set DEPLOY_RESULT=!ERRORLEVEL!

REM Restore original files after deployment
echo.
echo 🔄 Restoring original configuration...
copy pom.xml.backup pom.xml >nul
copy mule-artifact.json.backup mule-artifact.json >nul

if !DEPLOY_RESULT! equ 0 (
    echo.
    echo ================================================================
    echo ✅ CLOUDHUB DEPLOYMENT SUCCESSFUL
    echo ================================================================
    echo 🎉 Notification MCP deployed with Java 11 compatibility
    echo 🔗 Application should be running at:
    echo    http://notification-mcp-server.us-e1.cloudhub.io
    echo.
    echo 🧪 Test the deployment with:
    echo    curl -X GET http://notification-mcp-server.us-e1.cloudhub.io/health
    echo    curl -X GET http://notification-mcp-server.us-e1.cloudhub.io/mcp/info
    echo.
) else (
    echo.
    echo ================================================================
    echo ❌ CLOUDHUB DEPLOYMENT FAILED
    echo ================================================================
    echo 🔍 Check the error logs above for details
    echo 💡 Common issues:
    echo    - Verify ANYPOINT_CLIENT_ID and ANYPOINT_CLIENT_SECRET
    echo    - Check if application name is already in use
    echo    - Verify CloudHub region availability
    echo.
)

echo 📋 Original configuration files restored
echo.
pause
exit /b !DEPLOY_RESULT!
