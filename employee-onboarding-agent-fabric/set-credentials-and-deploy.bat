@echo off
echo.
echo ======================================
echo Setting Anypoint Platform Credentials
echo ======================================
echo.

REM Read credentials from .env file
for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
    if "%%a"=="ANYPOINT_CLIENT_ID" set ANYPOINT_CLIENT_ID=%%b
    if "%%a"=="ANYPOINT_CLIENT_SECRET" set ANYPOINT_CLIENT_SECRET=%%b
    if "%%a"=="ANYPOINT_ORG_ID" set ANYPOINT_ORG_ID=%%b
    if "%%a"=="BUSINESS_GROUP_ID" set BUSINESS_GROUP_ID=%%b
)

REM Check if credentials are set (not placeholder values)
if "%ANYPOINT_CLIENT_ID%"=="your-client-id-here" (
    echo ERROR: Please update ANYPOINT_CLIENT_ID in .env file with your actual Connected App credentials
    echo.
    echo You need to:
    echo 1. Go to Anypoint Platform - Access Management - Connected Apps
    echo 2. Create a new Connected App with required scopes
    echo 3. Update the .env file with your actual credentials
    echo.
    pause
    exit /b 1
)

if "%ANYPOINT_CLIENT_SECRET%"=="your-client-secret-here" (
    echo ERROR: Please update ANYPOINT_CLIENT_SECRET in .env file with your actual Connected App credentials
    pause
    exit /b 1
)

if "%ANYPOINT_ORG_ID%"=="your-org-id-here" (
    echo ERROR: Please update ANYPOINT_ORG_ID in .env file with your actual Organization ID
    pause
    exit /b 1
)

echo Credentials loaded from .env file:
echo Client ID: %ANYPOINT_CLIENT_ID%
echo Org ID: %ANYPOINT_ORG_ID%
echo.

echo Proceeding with CloudHub deployment...
call .\cloudhub-deploy.bat
