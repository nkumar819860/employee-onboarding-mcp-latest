@echo off
REM ========================================
REM EMPLOYEE ONBOARDING - AUTO DEPLOY ALL MCP
REM Auto-discovers + Compiles + Deploys + Tests
REM ========================================

cd /d "C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric"
echo Root: %CD%

setlocal enabledelayedexpansion
set SCRIPT_DIR=%CD%

cd /d "%CD%\\employee-onboarding-agent-fabric"
echo ✅ Working from: %CD%

REM === FIXED .env LOADING (No subroutines) ===
if not exist ".env" (
    echo ERROR: .env missing!
    pause & exit /b 1
)

REM Simple robust parsing - handles spaces
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim spaces from key
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    REM Trim spaces from value  
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" set "!key!=!val!"
)

REM Defaults
if not defined ANYPOINT_ENV_NAME set "ANYPOINT_ENV_NAME=Sandbox"
if not defined ANYPOINT_ORG_ID set "ANYPOINT_ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9"

echo ✅ Client: %ANYPOINT_CLIENT_ID:~0,8%... 
echo ✅ Env: %ANYPOINT_ENV_NAME%
echo ✅ Org: %ANYPOINT_ORG_ID:~0,8%...

REM Validate essentials
if not defined ANYPOINT_CLIENT_ID (
    echo ERROR: ANYPOINT_CLIENT_ID missing from .env
    pause & exit /b 1
)
if not defined ANYPOINT_CLIENT_SECRET (
    echo ERROR: ANYPOINT_CLIENT_SECRET missing from .env
    pause & exit /b 1
)

REM === AUTO-DISCOVER MCP SERVICES ===
echo.
echo 🔍 Finding MCP services in mcp-servers...
set SERVER_COUNT=0

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        call set "SERVER!SERVER_COUNT!=%%~nxd"
        echo [!SERVER_COUNT!] Found: !SERVER!SERVER_COUNT!! 
    )
)

if !SERVER_COUNT! == 0 (
    echo ERROR: No pom.xml found in mcp-servers\
    dir mcp-servers
    pause & exit /b 1
)

echo ✅ Found !SERVER_COUNT! MCP services

REM === COMPILE ALL ===
echo.
echo ==============================
echo COMPILING !SERVER_COUNT! SERVICES
echo ==============================

for /l %%i in (1,1,!SERVER_COUNT!) do (
    call set "SRV=%%SERVER%%i%%"
    echo [!%%i!/!SERVER_COUNT!] Compiling !SRV!...
    cd mcp-servers\!SRV!
    
    call mvn clean compile package -DskipTests -U -q
    if !errorlevel! neq 0 (
        echo ❌ !SRV! COMPILE FAILED
        cd /d "%SCRIPT_DIR%"
        pause & exit /b 1
    )
    echo ✅ !SRV! compiled OK
    cd /d "%SCRIPT_DIR%"
)

REM === REACT OPTIONAL ===
if exist "react-client" (
    echo 🌐 Building React...
    cd react-client
    call npm install --silent && call npm run build --silent
    echo ✅ React OK
    cd /d "%SCRIPT_DIR%"
) else (
    echo [INFO] No react-client folder
)

REM === DEPLOY ALL TO CLOUDHUB ===
echo.
echo ===============================
echo DEPLOYING !SERVER_COUNT! SERVICES
echo ===============================

for /l %%i in (1,1,!SERVER_COUNT!) do (
    call set "SRV=%%SERVER%%i%%"
    echo [!%%i!/!SERVER_COUNT!] Deploying !SRV!-server...
    cd mcp-servers\!SRV!
    
    call mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.platform.client_id=%ANYPOINT_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%ANYPOINT_CLIENT_SECRET% ^
        -Danypoint.businessGroup=%ANYPOINT_ORG_ID% ^
        -Danypoint.environment=%ANYPOINT_ENV_NAME% ^
        -Dcloudhub.applicationName=!SRV!-server ^
        -Dcloudhub.muleVersion=4.6.0 ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -DskipTests ^
        -U -q
    
    if !errorlevel! neq 0 (
        echo ❌ !SRV!-server FAILED
        cd /d "%SCRIPT_DIR%"
        pause & exit /b 1
    )
    echo ✅ !SRV!-server: https://!SRV!-server.us-e1.cloudhub.io
)

REM === HEALTH TESTS ===
echo.
echo 🧪 Testing services...
for /l %%i in (1,1,!SERVER_COUNT!) do (
    call set "SRV=%%SERVER%%i%%"
    echo Testing !SRV!-server...
    powershell -c "if ((Invoke-WebRequest -Uri 'https://!SRV!-server.us-e1.cloudhub.io/health' -UseBasicParsing -TimeoutSec 5 -Method Get).StatusCode -eq 200) { Write-Host '✅ !SRV!: OK' } else { Write-Host '⏳ !SRV!: Starting...' }"
)

cd /d "%SCRIPT_DIR%"
echo.
echo 🎉 ALL MCP SERVERS LIVE!
echo Run: curl -X POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding -d "{\"employeeId\":\"E123\"}"
pause
endlocal
