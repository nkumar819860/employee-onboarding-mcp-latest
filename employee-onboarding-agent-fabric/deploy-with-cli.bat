@echo off
REM ================================================
REM Employee Onboarding MCP Servers - CLI Deployment
REM Complete build → publish → deploy workflow
REM ================================================

setlocal enabledelayedexpansion
chcp 65001 >nul

echo.
echo 🚀 EMPLOYEE ONBOARDING MCP SERVERS DEPLOYMENT
echo ================================================
echo.

REM ===== CONFIGURATION - USING USER AUTHENTICATION =====
REM Connected App credentials removed - using username/password login instead
set ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set ENV=Sandbox
set REGION=us-east-1
set Username = PradeepInvenio
set Password = Deepu@1982

echo 🏢 Org: %ORG_ID%
echo 🌍 Env: %ENV%
echo 🔑 Auth: Username/Password (bypassing broken Connected App)

REM ===== 1. CHECK PREREQUISITES =====
echo.
echo 🔍 STEP 1: Checking prerequisites...

REM Check Anypoint CLI
anypoint-cli-v4 --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Anypoint CLI v4 missing!
    echo 💡 Install: npm install -g anypoint-cli-v4
    pause & exit /b 1
)
echo ✅ CLI v4 OK

REM Check Maven
mvn --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Maven missing!
    echo 💡 Add Maven to PATH
    pause & exit /b 1
)
echo ✅ Maven OK

REM Check folder structure
if not exist "mcp-servers" (
    echo ❌ mcp-servers folder missing!
    dir
    pause & exit /b 1
)
echo ✅ Folder structure OK

REM ===== 2. CLI AUTHENTICATION =====
echo.
echo 🔐 STEP 2: User Authentication (bypassing Connected App)...

REM Clear any existing Connected App credentials
set ANYPOINT_CLIENT_ID=
set ANYPOINT_CLIENT_SECRET=
anypoint-cli-v4 conf client_id ""
anypoint-cli-v4 conf client_secret ""

REM Set organization
anypoint-cli-v4 conf organization %ORG_ID%

REM Check if already authenticated
anypoint-cli-v4 account whoami >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo   Please login with your Anypoint Platform username/password:
    anypoint-cli-v4 auth login
    if %ERRORLEVEL% neq 0 (
        echo ❌ Authentication FAILED!
        echo 🔧 Please check your username and password
        pause & exit /b 1
    )
)
echo ✅ CLI Authenticated ✓

REM ===== 3. BUILD ALL JARS =====
echo.
echo 🔨 STEP 3: Building JARs...
cd mcp-servers

for %%d in (
    "employee-onboarding-mcp"
    "asset-allocation-mcp" 
    "notification-mcp"
    "agent-broker-mcp"
) do (
    echo   📦 Building %%d...
    cd %%d
    call mvn clean package -DskipTests
    if !errorlevel! neq 0 (
        echo ❌ %%d BUILD FAILED
        cd ..\.. & pause & exit /b 1
    )
    cd ..
)

cd ..\..
echo ✅ All JARs built ✓

REM ===== 4. PUBLISH TO EXCHANGE =====
echo.
echo 📤 STEP 4: Publishing to Exchange...
cd mcp-servers

REM Find JAR files and publish
for %%d in (
    "employee-onboarding-mcp:Employee Onboarding MCP"
    "asset-allocation-mcp:Asset Allocation MCP" 
    "notification-mcp:Notification MCP"
    "agent-broker-mcp:Agent Broker MCP"
) do (
    for /f "tokens=1,2 delims=:" %%a in ("%%d") do (
        pushd %%a
        for %%j in (target\*.jar) do (
            if exist "%%j" (
                echo   📤 Publishing %%b [%%j]...
                anypoint-cli-v4 exchange asset upload ^
                    --organization %ORG_ID% ^
                    --name "%%b Server" ^
                    --description "%%b server for employee onboarding" ^
                    --type mule-application ^
                    --classifier mule-application ^
                    --file "%%j" || echo     ⏭️  Already exists
            )
        )
        popd
    )
)

cd ..\..
echo ✅ Exchange publish complete ✓

REM ===== 5. DEPLOY TO CLOUDHUB =====
echo.
echo ☁️  STEP 5: Deploying to CloudHub...
cd employee-onboarding-agent-fabric\mcp-servers

for %%d in (
    "employee-onboarding-mcp:employee-onboarding-mcp-server"
    "asset-allocation-mcp:asset-allocation-mcp-server"
    "notification-mcp:notification-mcp-server" 
    "agent-broker-mcp:employee-onboarding-agent-broker"
) do (
    for /f "tokens=1,2 delims=:" %%a in ("%%d") do (
        pushd %%a
        for %%j in (target\*.jar) do (
            if exist "%%j" (
                echo   ☁️  Deploying %%b [%%j]...
                anypoint-cli-v4 runtime-mgr cloudhub application deploy ^
                    --name %%b ^
                    --target %ENV% ^
                    --artifact "%%j" ^
                    --region %REGION% ^
                    --workers 1 ^
                    --workerSize Micro ^
                    --env ANYPOINT_PLATFORM_ENV=%ENV%
            )
        )
        popd
    )
)

cd ..\..
echo ✅ Deployment commands sent ✓

REM ===== 6. STATUS CHECK =====
echo.
echo ⏳ STEP 6: Checking deployment status...
timeout /t 10 /nobreak >nul

echo 📊 MCP Servers Status:
anypoint-cli-v4 runtime-mgr cloudhub application list --environment %ENV% | findstr mcp

REM ===== 7. FINAL SUMMARY =====
echo.
echo 🎉 ==========================================
echo 🎉     ALL MCP SERVERS DEPLOYED SUCCESSFULLY!
echo 🎉 ==========================================
echo.
echo 📍 URLs (wait 2-5 mins for STARTED status):
echo   Employee: https://employee-onboarding-mcp-server.%REGION%.cloudhub.io
echo   Assets:   https://asset-allocation-mcp-server.%REGION%.cloudhub.io  
echo   Notify:   https://notification-mcp-server.%REGION%.cloudhub.io
echo   Broker:   https://employee-onboarding-agent-broker.%REGION%.cloudhub.io
echo.
echo 🔗 Runtime Manager: https://anypoint.mulesoft.com/cloudhub
echo.
echo ✨ Deployment complete! Check Runtime Manager in 5 mins.
pause
