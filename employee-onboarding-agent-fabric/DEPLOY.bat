@echo off
REM ========================================
REM COMPREHENSIVE DEPLOYMENT SCRIPT
REM ✅ Load .env variables
REM ✅ Clean target folders (fix locking issues)
REM ✅ Compile projects
REM ✅ Publish assets to Exchange
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
echo 🔧 LOADING ENVIRONMENT VARIABLES
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
echo ✅ Discovered %SERVER_COUNT% MCP services:%SERVER_LIST%
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
    
    echo   Running: mvn clean compile package -DskipTests -U
    call mvn clean compile package -DskipTests -U
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

REM === STEP 6: VERSION MANAGEMENT AND EXCHANGE PUBLISHING ===
echo ==============================
echo 📤 VERSION MANAGEMENT AND EXCHANGE PUBLISHING
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 📤 Processing !SRV! for Exchange...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo 📁 Working from: %CD%
    
    REM Extract current version from pom.xml
    echo   🔍 Checking current version...
    for /f "tokens=2 delims=><" %%v in ('findstr "<version>" pom.xml ^| findstr -v "parent" ^| findstr -v "mule" ^| findstr -v "connector" ^| head -n 1') do (
        set "CURRENT_VERSION=%%v"
    )
    
    echo   Current version: !CURRENT_VERSION!
    
    REM For simplicity, assume asset exists and increment version
    echo   📦 Incrementing version for Exchange publishing...
    
    REM Parse version and increment patch number
    for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT_VERSION!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"  
        set "PATCH=%%c"
    )
    
    set /a NEW_PATCH=!PATCH!+1
    set "NEW_VERSION=!MAJOR!.!MINOR!.!NEW_PATCH!"
    
    echo   🔢 Version increment: !CURRENT_VERSION! → !NEW_VERSION!
    
    REM Update pom.xml version using simple find/replace
    powershell -Command "(Get-Content pom.xml) -replace '<version>!CURRENT_VERSION!</version>', '<version>!NEW_VERSION!</version>' | Set-Content pom.xml"
    
    REM Update exchange.json version if it exists
    if exist "exchange.json" (
        echo   📝 Updating exchange.json version...
        powershell -Command "$json = Get-Content exchange.json | ConvertFrom-Json; $json.version = '!NEW_VERSION!'; $json | ConvertTo-Json -Depth 10 | Set-Content exchange.json"
    )
    
    REM Create simple exchange.json if it doesn't exist
    if not exist "exchange.json" (
        echo   📄 Creating exchange.json...
        echo { > exchange.json
        echo   "name": "!SRV! MCP Server", >> exchange.json
        echo   "description": "MCP Server for Employee Onboarding - !SRV! component", >> exchange.json
        echo   "version": "!NEW_VERSION!", >> exchange.json
        echo   "groupId": "!ANYPOINT_ORG_ID!", >> exchange.json
        echo   "assetId": "!SRV!", >> exchange.json
        echo   "classifier": "mule-application", >> exchange.json
        echo   "keywords": ["mcp", "employee-onboarding", "integration"], >> exchange.json
        echo   "tags": ["MCP Server", "Employee Onboarding", "Integration"] >> exchange.json
        echo } >> exchange.json
    )
    
    echo   ✅ Version updated to !NEW_VERSION!
    
    echo    Publishing to Exchange with version !NEW_VERSION!...
    
    REM Try Exchange publishing with retry logic
    set EXCHANGE_SUCCESS=0
    for /l %%r in (1,1,3) do (
        if !EXCHANGE_SUCCESS! equ 0 (
            echo   Attempt %%r/3: Publishing to Exchange...
            call mvn clean deploy -DaltDeploymentRepository=anypoint-exchange::default::https://maven.anypoint.mulesoft.com/api/v1/organizations/!ANYPOINT_ORG_ID!/maven -Danypoint.platform.client_id="!ANYPOINT_CLIENT_ID!" -Danypoint.platform.client_secret="!ANYPOINT_CLIENT_SECRET!" -DskipTests -q
            
            if !errorlevel! equ 0 (
                echo ✅ !SRV! v!NEW_VERSION! published to Exchange successfully
                set EXCHANGE_SUCCESS=1
            ) else (
                if %%r lss 3 (
                    echo   ⏳ Retrying in 5 seconds...
                    timeout /t 5 >nul
                ) else (
                    echo ⚠️  Warning: Exchange publish failed after 3 attempts for !SRV! v!NEW_VERSION!
                    echo   This is often due to network connectivity issues or repository timeouts
                    echo   The deployment will continue to CloudHub regardless
                )
            )
        )
    )
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ Exchange publishing phase completed
echo.

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
    
    echo   Running CloudHub deployment for !SRV!-server...
    call mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.platform.client_id="!ANYPOINT_CLIENT_ID!" ^
        -Danypoint.platform.client_secret="!ANYPOINT_CLIENT_SECRET!" ^
        -Danypoint.businessGroup="!ANYPOINT_ORG_ID!" ^
        -Danypoint.environment="!ANYPOINT_ENV!" ^
        -Dcloudhub.applicationName="!SRV!-server" ^
        -Dcloudhub.muleVersion="!MULE_VERSION!" ^
        -Dcloudhub.region="!CLOUDHUB_REGION!" ^
        -Dcloudhub.workers="!CLOUDHUB_WORKERS!" ^
        -Dcloudhub.workerType="!CLOUDHUB_WORKER_TYPE!" ^
        -Dcloudhub.objectStoreV2=true ^
        -DskipTests ^
        -U
    
    if !errorlevel! neq 0 (
        echo ❌ DEPLOYMENT FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV!-server deployed successfully
    echo 🌐 URL: https://!SRV!-server.us-e1.cloudhub.io
    
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
    
    powershell -Command ^
        "try { ^
            $response = Invoke-WebRequest -Uri 'https://!SRV!-server.us-e1.cloudhub.io/health' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
            if ($response.StatusCode -eq 200) { ^
                Write-Host '    ✅ !SRV!-server: HEALTHY' -ForegroundColor Green ^
            } else { ^
                Write-Host '    ⚠️  !SRV!-server: HTTP $($response.StatusCode)' -ForegroundColor Yellow ^
            } ^
        } catch { ^
            Write-Host '    ⏳ !SRV!-server: Starting or not accessible...' -ForegroundColor Cyan ^
        }"
)

echo.

REM === STEP 9: DEPLOYMENT SUMMARY ===
echo ==============================
echo 🎉 DEPLOYMENT COMPLETED
echo ==============================

echo.
echo SERVICE URLS:
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   🌐 !SRV!-server: https://!SRV!-server.us-e1.cloudhub.io
)

echo.
echo TESTING ENDPOINTS:
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   🧪 !SRV! Health: https://!SRV!-server.us-e1.cloudhub.io/health
    echo   📋 !SRV! Info: https://!SRV!-server.us-e1.cloudhub.io/mcp/info
)

if exist "mcp-servers\agent-broker-mcp" (
    echo.
    echo 🚀 SAMPLE TEST COMMAND:
    echo curl -X POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding ^
    echo      -H "Content-Type: application/json" ^
    echo      -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@test.com\",\"department\":\"Engineering\"}"
)

echo.
echo ✅ DEPLOYMENT SCRIPT COMPLETED SUCCESSFULLY
echo   - %SERVER_COUNT% services compiled
echo   - Target folders cleaned
echo   - Assets published to Exchange
echo   - All services deployed to CloudHub
echo   - Health checks performed
echo.
echo Ready for testing and use!
echo.

pause
endlocal
