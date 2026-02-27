@echo off
REM ========================================
REM COMPREHENSIVE DEPLOYMENT SCRIPT
REM ✅ Load .env variables
REM ✅ Clean target folders (fix locking issues)
REM ✅ Compile projects
REM ✅ Publish assets to Exchange (OPTIONAL)
REM ✅ Deploy to CloudHub
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo EMPLOYEE ONBOARDING DEPLOYMENT SCRIPT
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: LOAD ENVIRONMENT VARIABLES ===
echo ==============================
echo [LOADING] ENVIRONMENT VARIABLES
echo ==============================

if not exist ".env" (
    echo ❌ ERROR: .env file not found in %CD%
    echo Please ensure .env file exists in the project root
    pause
    exit /b 1
)

echo ✅ Found .env file, loading variables...

REM Load environment variables from .env file
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim whitespace from key and value
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
        echo   !key!=!val!
    )
)

echo.
echo ✅ Environment variables loaded successfully

REM === STEP 2: VALIDATE REQUIRED VARIABLES ===
echo ==============================
echo 🔍 VALIDATING CONFIGURATION
echo ==============================

if not defined ANYPOINT_CLIENT_ID (
    echo ❌ ERROR: ANYPOINT_CLIENT_ID not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_CLIENT_SECRET (
    echo ❌ ERROR: ANYPOINT_CLIENT_SECRET not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_ORG_ID (
    echo ❌ ERROR: ANYPOINT_ORG_ID not found in .env
    pause
    exit /b 1
)

REM Set defaults for missing variables
if not defined ANYPOINT_ENV set "ANYPOINT_ENV=Sandbox"
if not defined MULE_VERSION set "MULE_VERSION=4.9.4:2e-java17"
if not defined CLOUDHUB_REGION set "CLOUDHUB_REGION=us-east-1"
if not defined CLOUDHUB_WORKER_TYPE set "CLOUDHUB_WORKER_TYPE=MICRO"
if not defined CLOUDHUB_WORKERS set "CLOUDHUB_WORKERS=1"

echo ✅ Configuration validated:
echo   Client ID: %ANYPOINT_CLIENT_ID:~0,8%...
echo   Environment: %ANYPOINT_ENV%
echo   Organization: %ANYPOINT_ORG_ID:~0,8%...
echo   Mule Version: %MULE_VERSION%
echo   CloudHub Region: %CLOUDHUB_REGION%
echo   Worker Type: %CLOUDHUB_WORKER_TYPE%
echo.

REM === STEP 3: DISCOVER MCP SERVICES ===
echo ==============================
echo 🔍 DISCOVERING MCP SERVICES
echo ==============================

if not exist "mcp-servers" (
    echo ❌ ERROR: mcp-servers directory not found
    pause
    exit /b 1
)

set SERVER_COUNT=0
set SERVER_LIST=

echo Scanning mcp-servers directory for services...

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        for %%n in (%%d) do (
            call set "SERVER!SERVER_COUNT!=%%~nxn"
            set "SERVER_LIST=!SERVER_LIST! %%~nxn"
            echo [!SERVER_COUNT!] ✅ Found: %%~nxn
        )
    )
)

if %SERVER_COUNT% EQU 0 (
    echo ❌ ERROR: No MCP services with pom.xml found in mcp-servers directory
    pause
    exit /b 1
)

echo.
echo ✅ Discovered %SERVER_COUNT% MCP services: !SERVER_LIST!
echo.

REM === STEP 4: CLEAN TARGET FOLDERS (FIX LOCKING ISSUES) ===
echo ==============================
echo 🧹 CLEANING TARGET FOLDERS
echo ==============================

echo Cleaning target folders to resolve locking issues...

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo [%%i/%SERVER_COUNT%] Cleaning !SRV!/target...
    
    if exist "mcp-servers\!SRV!\target" (
        echo   Removing target directory for !SRV!...
        rmdir /s /q "mcp-servers\!SRV!\target" 2>nul
        if exist "mcp-servers\!SRV!\target" (
            echo   ⚠️  Warning: Could not completely remove target directory
        ) else (
            echo   ✅ Target directory cleaned for !SRV!
        )
    ) else (
        echo   ✅ No target directory found for !SRV!
    )
)

echo.
echo ✅ Target folder cleanup completed
echo.

REM === STEP 5: COMPILE ALL SERVICES ===
echo ==============================
echo 🛠️  COMPILING MCP SERVICES
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 🛠️  Compiling !SRV!...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    
    if not exist "mcp-servers\!SRV!\pom.xml" (
        echo ❌ ERROR: pom.xml not found for !SRV!
        pause
        exit /b 1
    )
    
    cd "mcp-servers\!SRV!"
    echo 📁 Compiling from: %CD%
    
    echo   Running: mvn clean compile package -DskipTests -T 4 -q -DskipMuleApplicationDeployment
    call mvn clean compile package -DskipTests -T 4 -q -DskipMuleApplicationDeployment
    if !errorlevel! neq 0 (
        echo ❌ COMPILATION FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    REM Verify JAR was created
    dir target\*.jar >nul 2>&1
    if !errorlevel! neq 0 (
        echo ❌ ERROR: No JAR file found in target directory for !SRV!
        dir target
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV! compiled successfully
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ All MCP services compiled successfully
echo.

REM === STEP 6: PUBLISH TO EXCHANGE (OPTIONAL) ===
echo ==============================
echo 📤 EXCHANGE PUBLICATION OPTIONS
echo ==============================
echo Do you want to publish assets to Anypoint Exchange?
echo [Y] Yes - Publish to Exchange (requires proper Exchange permissions)
echo [N] No  - Skip to CloudHub deployment
echo.
set /p PUBLISH_CHOICE=Enter your choice (Y/N): 
if "%PUBLISH_CHOICE%"=="" set "PUBLISH_CHOICE=N"

if /i "%PUBLISH_CHOICE%"=="Y" (
    echo ✅ Exchange publication ENABLED
    goto :PUBLISH_EXCHANGE
) else (
    echo [INFO] Exchange publication SKIPPED - Going directly to CloudHub deployment
    goto :CLOUDHUB_DEPLOYMENT
)

:PUBLISH_EXCHANGE
REM Exchange publishing logic (runs only if Y chosen)
echo.
echo ==============================
echo 📤 PUBLISHING TO EXCHANGE
echo ==============================
echo 📤 Publishing MCP assets to Anypoint Exchange...

REM Interactive credentials
echo ==============================
echo 👤 ENTER CREDENTIALS
echo ==============================
set /p EXCHANGE_USERNAME=Username: 
set /p EXCHANGE_PASSWORD=Password: 
set /p EXCHANGE_MFA=MFA ^(Enter if none^): 

REM Parent POM publication
if exist "exchange.json" (
    echo 📦 Publishing parent POM...
    call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
        -Danypoint.username="!EXCHANGE_USERNAME!" ^
        -Danypoint.password="!EXCHANGE_PASSWORD!" ^
        -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
        -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
        -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
)

REM Child modules
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo 📤 Publishing !SRV! to Exchange...
    cd "mcp-servers\!SRV!"
    call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
        -Danypoint.username="!EXCHANGE_USERNAME!" ^
        -Danypoint.password="!EXCHANGE_PASSWORD!" ^
        -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
        -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
        -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
    cd /d "%SCRIPT_DIR%"
)

echo ✅ Exchange publishing completed
goto :CLOUDHUB_DEPLOYMENT

:CLOUDHUB_DEPLOYMENT
REM === STEP 7: DEPLOY TO CLOUDHUB ===
echo ==============================
echo ☁️  DEPLOYING TO CLOUDHUB
echo ==============================

echo Deploying %SERVER_COUNT% services to CloudHub...
echo Configuration:
echo   Mule Version: %MULE_VERSION%
echo   Region: %CLOUDHUB_REGION%
echo   Worker Type: %CLOUDHUB_WORKER_TYPE%
echo   Workers: %CLOUDHUB_WORKERS%
echo.

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] ☁️  Deploying !SRV!-server...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo 📁 Deploying from: %CD%
    
    call mvn clean package mule:deploy ^
        -DmuleDeploy ^
        -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" ^
        -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
        -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
        -Danypoint.environment="%ANYPOINT_ENV%" ^
        -Dcloudhub.applicationName="!SRV!-server" ^
        -Dcloudhub.muleVersion="%MULE_VERSION%" ^
        -Dcloudhub.region="%CLOUDHUB_REGION%" ^
        -Dcloudhub.workers="%CLOUDHUB_WORKERS%" ^
        -Dcloudhub.workerType="%CLOUDHUB_WORKER_TYPE%" ^
        -Dcloudhub.objectStoreV2=true ^
        -Danypoint.platform.client_id="%ANYPOINT_CLIENT_ID%" ^
        -Danypoint.platform.client_secret="%ANYPOINT_CLIENT_SECRET%" ^
        -DskipTests ^
        -DskipMuleApplicationDeployment=false ^
        -U
    
    if !errorlevel! neq 0 (
        echo ❌ DEPLOYMENT FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV!-server deployed successfully
    echo 🌐 URL: https://!SRV!-server.%CLOUDHUB_REGION%.cloudhub.io
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ All services deployed to CloudHub successfully
echo.

REM === STEP 8: HEALTH CHECKS ===
echo ==============================
echo 🧪 PERFORMING HEALTH CHECKS
echo ==============================

echo Waiting 15 seconds for applications to start...
timeout /t 15 /nobreak >nul

echo Testing deployed services:

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   Testing !SRV!-server...
    
    powershell -Command "& { try { $response = Invoke-WebRequest -Uri 'https://!SRV!-server.%CLOUDHUB_REGION%.cloudhub.io/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '    ✅ !SRV!-server: HEALTHY' -ForegroundColor Green } else { Write-Host '    ⚠️  !SRV!-server: HTTP $($response.StatusCode)' -ForegroundColor Yellow } } catch { Write-Host '    ⏳ !SRV!-server: Starting or not accessible...' -ForegroundColor Cyan } }"
)

echo.

REM === STEP 9: DEPLOYMENT SUMMARY ===
echo ==============================
echo 🎉 DEPLOYMENT COMPLETED
echo ==============================

echo.
echo ✅ DEPLOYED SERVICE URLS:
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   🌐 !SRV!-server: https://!SRV!-server.%CLOUDHUB_REGION%.cloudhub.io
)

echo.
echo 📋 KEY ENDPOINTS:
echo   🔗 Main API: https://agent-broker-mcp-server.%CLOUDHUB_REGION%.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo   🔗 Employee MCP: https://employee-onboarding-mcp-server.%CLOUDHUB_REGION%.cloudhub.io/mcp

if exist "mcp-servers\agent-broker-mcp" (
    echo.
    echo 🚀 SAMPLE TEST COMMAND:
    echo curl -X POST https://agent-broker-mcp-server.%CLOUDHUB_REGION%.cloudhub.io/mcp/tools/orchestrate-employee-onboarding ^
    echo      -H "Content-Type: application/json" ^
    echo      -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@test.com\",\"department\":\"Engineering\"}"
)

echo.
echo ✅ DEPLOYMENT SCRIPT COMPLETED SUCCESSFULLY
echo   - %SERVER_COUNT% services compiled
echo   - Target folders cleaned
if /i "%PUBLISH_CHOICE%"=="Y" (
    echo   - Exchange publishing completed
) else (
    echo   - Exchange publishing skipped ^(as requested^)
)
echo   - All services deployed to CloudHub
echo   - Health checks performed
echo.
echo Ready for testing and use!
echo.

pause
endlocal
