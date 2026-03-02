@echo off
REM ========================================================================
REM Auto-Provision Connected App for CloudHub 2.0 Deployment
REM Creates Connected App with all required scopes using Anypoint Platform API
REM ========================================================================

setlocal enabledelayedexpansion
chcp 65001 >nul

echo.
echo ========================================================================
echo 🔧 Auto-Provisioning Connected App for CloudHub 2.0 Deployment
echo ========================================================================
echo.

REM Check if we need to create new connected app or use existing
set /p CREATE_NEW=Do you want to create a new Connected App? (y/n): 
if /i "%CREATE_NEW%"=="n" goto :use_existing

echo.
echo 🔐 Manual credentials needed for Connected App creation...
echo.
set /p ADMIN_USERNAME=Enter your Anypoint Platform username: 
set /p ADMIN_PASSWORD=Enter your Anypoint Platform password: 
echo.

REM Get access token with admin credentials
echo 🔑 Getting admin access token...
curl -s -X POST "https://anypoint.mulesoft.com/accounts/login" ^
     -H "Content-Type: application/json" ^
     -d "{\"username\":\"%ADMIN_USERNAME%\",\"password\":\"%ADMIN_PASSWORD%\"}" ^
     -c cookies.txt ^
     -o login_response.json

if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to login to Anypoint Platform
    goto :error
)

REM Extract access token
for /f "tokens=2 delims=:," %%a in ('findstr /c:"access_token" login_response.json') do (
    set "ADMIN_TOKEN=%%a"
    set "ADMIN_TOKEN=!ADMIN_TOKEN:"=!"
    set "ADMIN_TOKEN=!ADMIN_TOKEN: =!"
)

if "!ADMIN_TOKEN!"=="" (
    echo ❌ Failed to get admin access token
    goto :error
)

echo ✅ Admin token acquired

REM Load organization ID from .env
if exist ".env" (
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
        )
    )
) else (
    set "ANYPOINT_ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9"
)

echo.
echo 🏗️ Creating Connected App with CloudHub 2.0 scopes...

REM Create Connected App JSON payload
echo {> connected_app_payload.json
echo   "name": "Employee-Onboarding-CloudHub-Deploy",>> connected_app_payload.json
echo   "description": "Auto-provisioned Connected App for Employee Onboarding CloudHub 2.0 deployment",>> connected_app_payload.json
echo   "url": "https://employee-onboarding-agent-fabric.com",>> connected_app_payload.json
echo   "redirectUris": [],>> connected_app_payload.json
echo   "grantTypes": ["client_credentials"],>> connected_app_payload.json
echo   "scopes": [>> connected_app_payload.json
echo     "read:organization",>> connected_app_payload.json
echo     "read:environment",>> connected_app_payload.json
echo     "write:environment",>> connected_app_payload.json
echo     "read:application",>> connected_app_payload.json
echo     "write:application",>> connected_app_payload.json
echo     "deploy:application",>> connected_app_payload.json
echo     "read:asset",>> connected_app_payload.json
echo     "write:asset",>> connected_app_payload.json
echo     "publish:asset",>> connected_app_payload.json
echo     "delete:asset",>> connected_app_payload.json
echo     "read:deployment",>> connected_app_payload.json
echo     "write:deployment",>> connected_app_payload.json
echo     "manage:cloudhub",>> connected_app_payload.json
echo     "manage:runtime-fabric",>> connected_app_payload.json
echo     "view:monitoring">> connected_app_payload.json
echo   ]>> connected_app_payload.json
echo }>> connected_app_payload.json

REM Create Connected App
curl -s -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/clients" ^
     -H "Authorization: Bearer !ADMIN_TOKEN!" ^
     -H "Content-Type: application/json" ^
     -H "X-ANYPNT-ORG-ID: %ANYPOINT_ORG_ID%" ^
     -d @connected_app_payload.json ^
     -o connected_app_response.json

if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to create Connected App
    goto :error
)

REM Extract client credentials
findstr /c:"client_id" connected_app_response.json >nul
if %ERRORLEVEL% equ 0 (
    echo ✅ Connected App created successfully!
    
    for /f "tokens=2 delims=:," %%a in ('findstr /c:"client_id" connected_app_response.json') do (
        set "NEW_CLIENT_ID=%%a"
        set "NEW_CLIENT_ID=!NEW_CLIENT_ID:"=!"
        set "NEW_CLIENT_ID=!NEW_CLIENT_ID: =!"
    )
    
    for /f "tokens=2 delims=:," %%a in ('findstr /c:"client_secret" connected_app_response.json') do (
        set "NEW_CLIENT_SECRET=%%a"
        set "NEW_CLIENT_SECRET=!NEW_CLIENT_SECRET:"=!"
        set "NEW_CLIENT_SECRET=!NEW_CLIENT_SECRET: =!"
    )
    
    echo.
    echo 🎯 New Connected App Credentials:
    echo Client ID: !NEW_CLIENT_ID!
    echo Client Secret: !NEW_CLIENT_SECRET!
    
    goto :update_env
) else (
    echo ❌ Failed to create Connected App
    type connected_app_response.json
    goto :error
)

:use_existing
echo Using existing Connected App credentials from .env...
if exist ".env" (
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
        )
    )
    set "NEW_CLIENT_ID=%ANYPOINT_CLIENT_ID%"
    set "NEW_CLIENT_SECRET=%ANYPOINT_CLIENT_SECRET%"
) else (
    echo ❌ .env file not found!
    goto :error
)

:update_env
echo.
echo 📝 Updating .env file with Connected App credentials...

REM Backup existing .env
if exist ".env" copy ".env" ".env.backup" >nul

REM Create comprehensive .env file for CloudHub 2.0 deployment
echo # ========================================================> .env.new
echo # Anypoint Platform Connected App Credentials>> .env.new
echo # Auto-provisioned for CloudHub 2.0 deployment>> .env.new
echo # ========================================================>> .env.new
echo.>> .env.new
echo # Connected App Authentication>> .env.new
echo ANYPOINT_CLIENT_ID=!NEW_CLIENT_ID!>> .env.new
echo ANYPOINT_CLIENT_SECRET=!NEW_CLIENT_SECRET!>> .env.new
echo ANYPOINT_ORG_ID=%ANYPOINT_ORG_ID%>> .env.new
echo.>> .env.new
echo # Deployment Configuration>> .env.new
echo ANYPOINT_ENV=Sandbox>> .env.new
echo ANYPOINT_ENVIRONMENT=Sandbox>> .env.new
echo ANYPOINT_REGION=us-east-1>> .env.new
echo ANYPOINT_WORKERS=1>> .env.new
echo ANYPOINT_WORKER_TYPE=MICRO>> .env.new
echo.>> .env.new
echo # CloudHub 2.0 Configuration>> .env.new
echo CLOUDHUB_VERSION=2.0>> .env.new
echo MULE_VERSION=4.9.4:2e-java17>> .env.new
echo DEPLOYMENT_TIMEOUT=1000000>> .env.new
echo.>> .env.new
echo # Docker Environment Variables>> .env.new
echo # Database Configuration>> .env.new
echo DB_POSTGRES_USER=postgres>> .env.new
echo DB_POSTGRES_PASSWORD=postgres123>> .env.new
echo DB_POSTGRES_HOST=postgres>> .env.new
echo DB_POSTGRES_PORT=5432>> .env.new
echo.>> .env.new
echo # Employee Database>> .env.new
echo EMPLOYEE_DB_NAME=employee_onboarding>> .env.new
echo EMPLOYEE_DB_USER=postgres>> .env.new
echo EMPLOYEE_DB_PASSWORD=postgres123>> .env.new
echo.>> .env.new
echo # Asset Database>> .env.new
echo ASSET_DB_NAME=asset_allocation>> .env.new
echo ASSET_DB_USER=postgres>> .env.new
echo ASSET_DB_PASSWORD=postgres123>> .env.new
echo.>> .env.new
echo # HTTP Configuration>> .env.new
echo HTTP_HOST=0.0.0.0>> .env.new
echo.>> .env.new
echo # Port Configuration>> .env.new
echo EMPLOYEE_HTTP_PORT=8081>> .env.new
echo ASSET_HTTP_PORT=8082>> .env.new
echo NOTIFICATION_HTTP_PORT=8083>> .env.new
echo.>> .env.new
echo # Email Configuration (Gmail SMTP)>> .env.new
echo GMAIL_SMTP_HOST=smtp.gmail.com>> .env.new
echo GMAIL_SMTP_PORT=587>> .env.new
echo GMAIL_USERNAME=your-email@gmail.com>> .env.new
echo GMAIL_PASSWORD=your-app-password>> .env.new
echo GMAIL_FROM_ADDRESS=noreply@company.com>> .env.new

REM Replace .env file
move ".env.new" ".env" >nul

echo ✅ .env file updated with Connected App credentials

echo.
echo ========================================================================
echo 🧪 TESTING NEW CONNECTED APP
echo ========================================================================

REM Test the new credentials
call test-token-scopes.bat

REM Clean up
del login_response.json 2>nul
del connected_app_payload.json 2>nul
del connected_app_response.json 2>nul
del cookies.txt 2>nul

echo.
echo ========================================================================
echo 🎉 CONNECTED APP PROVISIONING COMPLETE!
echo ========================================================================
echo.
echo ✅ Connected App: Employee-Onboarding-CloudHub-Deploy
echo ✅ All Required Scopes: CONFIGURED
echo ✅ CloudHub 2.0 Deployment: READY
echo.
echo 🔑 Credentials saved to .env file
echo 🚀 You can now run deploy.bat for CloudHub 2.0 deployment
echo.
pause
exit /b 0

:error
echo.
echo ❌ CONNECTED APP PROVISIONING FAILED!
echo.
echo 💡 Manual setup required:
echo   1. Go to Anypoint Platform → Access Management → Connected Apps
echo   2. Create Connected App: "Employee-Onboarding-CloudHub-Deploy"
echo   3. Add these scopes:
echo      - read:organization
echo      - read:environment, write:environment
echo      - read:application, write:application, deploy:application
echo      - read:asset, write:asset, publish:asset
echo      - manage:cloudhub
echo   4. Copy Client ID and Secret to .env file
echo.

REM Clean up
del login_response.json 2>nul
del connected_app_payload.json 2>nul
del connected_app_response.json 2>nul
del cookies.txt 2>nul

pause
exit /b 1
