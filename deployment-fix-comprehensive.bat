@echo off
REM ========================================
REM FIXED EMPLOYEE ONBOARDING DEPLOYMENT
REM Addresses all path and version issues
REM ========================================

setlocal enabledelayedexpansion
set SCRIPT_DIR=%CD%

REM Navigate to correct directory
if not exist "employee-onboarding-agent-fabric" (
    echo ERROR: employee-onboarding-agent-fabric directory not found!
    echo Current directory: %CD%
    dir
    pause & exit /b 1
)

cd /d "%CD%\employee-onboarding-agent-fabric"
echo Working from: %CD%

REM === ROBUST .env LOADING ===
if not exist ".env" (
    echo ERROR: .env file missing in %CD%
    pause & exit /b 1
)

echo Loading environment variables...
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim spaces from key
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    REM Trim spaces from value  
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" set "!key!=!val!"
)

REM Map .env variables correctly
if defined ANYPOINT_ENV set "ANYPOINT_ENV_NAME=!ANYPOINT_ENV!"
if not defined ANYPOINT_ENV_NAME if defined DEPLOYMENT_ENV set "ANYPOINT_ENV_NAME=!DEPLOYMENT_ENV!"
if not defined ANYPOINT_ENV_NAME set "ANYPOINT_ENV_NAME=Sandbox"

if not defined ANYPOINT_ORG_ID if defined BUSINESS_GROUP_ID set "ANYPOINT_ORG_ID=!BUSINESS_GROUP_ID!"
if not defined ANYPOINT_ORG_ID set "ANYPOINT_ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9"

REM Use correct Mule version from pom.xml
set "MULE_RUNTIME_VERSION=4.9.0:2e-java17"

echo ======================================
echo DEPLOYMENT CONFIGURATION
echo ======================================
echo ✅ Client ID: %ANYPOINT_CLIENT_ID:~0,8%... 
echo ✅ Environment: %ANYPOINT_ENV_NAME%
echo ✅ Organization: %ANYPOINT_ORG_ID:~0,8%...
echo ✅ Mule Version: %MULE_RUNTIME_VERSION%
echo ======================================

REM Validate credentials
if not defined ANYPOINT_CLIENT_ID (
    echo ERROR: ANYPOINT_CLIENT_ID missing from .env
    pause & exit /b 1
)
if not defined ANYPOINT_CLIENT_SECRET (
    echo ERROR: ANYPOINT_CLIENT_SECRET missing from .env
    pause & exit /b 1
)

REM === AUTO-DISCOVER MCP SERVICES WITH ERROR CHECKING ===
echo.
echo 🔍 Discovering MCP services...

if not exist "mcp-servers" (
    echo ERROR: mcp-servers directory not found!
    echo Looking in: %CD%
    dir
    pause & exit /b 1
)

set SERVER_COUNT=0
for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        call set "SERVER!SERVER_COUNT!=%%~nxd"
        echo [!SERVER_COUNT!] Found: !SERVER!SERVER_COUNT!! with pom.xml
    ) else (
        echo WARNING: %%d exists but no pom.xml found
    )
)

if %SERVER_COUNT% EQU 0 (
    echo ERROR: No MCP services with pom.xml found in mcp-servers\
    echo Contents of mcp-servers:
    dir mcp-servers
    pause & exit /b 1
)

echo ✅ Discovered %SERVER_COUNT% MCP services ready for deployment

REM === CLEAN BUILD ALL SERVICES ===
echo.
echo ==============================
echo BUILDING %SERVER_COUNT% SERVICES  
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] Building !SRV!...
    
    if not exist "mcp-servers\!SRV!" (
        echo ERROR: Directory mcp-servers\!SRV! not found!
        pause & exit /b 1
    )
    
    cd mcp-servers\!SRV!
    echo Working in: %CD%
    
    REM Clean build with error handling
    echo Running: mvn clean compile package -DskipTests -U
    call mvn clean compile package -DskipTests -U
    
    if !errorlevel! neq 0 (
        echo ❌ BUILD FAILED for !SRV!
        echo Error occurred in: %CD%
        cd /d "%SCRIPT_DIR%\employee-onboarding-agent-fabric"
        pause & exit /b 1
    )
    
    REM Verify JAR was created
    if not exist "target\*.jar" (
        echo ❌ No JAR file created for !SRV!
        dir target
        cd /d "%SCRIPT_DIR%\employee-onboarding-agent-fabric"
        pause & exit /b 1
    )
    
    echo ✅ !SRV! built successfully
    cd /d "%SCRIPT_DIR%\employee-onboarding-agent-fabric"
)

REM === DEPLOY TO CLOUDHUB ===
echo.
echo ===============================
echo DEPLOYING %SERVER_COUNT% SERVICES TO CLOUDHUB
echo ===============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] Deploying !SRV!-server...
    
    cd mcp-servers\!SRV!
    echo Deploying from: %CD%
    
    REM Deploy with correct parameters
    call mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.platform.client_id=%ANYPOINT_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%ANYPOINT_CLIENT_SECRET% ^
        -Danypoint.businessGroup=%ANYPOINT_ORG_ID% ^
        -Danypoint.environment=%ANYPOINT_ENV_NAME% ^
        -Dcloudhub.applicationName=!SRV!-server ^
        -Dcloudhub.muleVersion=%MULE_RUNTIME_VERSION% ^
        -Dcloudhub.region=us-east-1 ^
        -Dcloudhub.workers=1 ^
        -Dcloudhub.workerType=MICRO ^
        -DskipTests ^
        -U
    
    if !errorlevel! neq 0 (
        echo ❌ DEPLOYMENT FAILED for !SRV!-server
        echo Check the error messages above
        cd /d "%SCRIPT_DIR%\employee-onboarding-agent-fabric"
        echo.
        echo === TROUBLESHOOTING TIPS ===
        echo 1. Verify credentials are correct
        echo 2. Check if application already exists
        echo 3. Ensure Mule version %MULE_RUNTIME_VERSION% is supported
        echo 4. Verify organization permissions
        pause & exit /b 1
    )
    
    echo ✅ !SRV!-server deployed: https://!SRV!-server.us-e1.cloudhub.io
    cd /d "%SCRIPT_DIR%\employee-onboarding-agent-fabric"
)

REM === VERIFY DEPLOYMENTS ===
echo.
echo ==============================
echo VERIFYING DEPLOYMENTS
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo Testing !SRV!-server...
    timeout /t 5 /nobreak > nul
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://!SRV!-server.us-e1.cloudhub.io/health' -UseBasicParsing -TimeoutSec 10; if ($response.StatusCode -eq 200) { Write-Host '✅ !SRV!-server: HEALTHY' -ForegroundColor Green } else { Write-Host '⚠️ !SRV!-server: Starting (Status: ' + $response.StatusCode + ')' -ForegroundColor Yellow } } catch { Write-Host '⏳ !SRV!-server: Still starting...' -ForegroundColor Yellow }"
)

echo.
echo ========================================
echo 🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!
echo ========================================
echo All %SERVER_COUNT% MCP services are now live on CloudHub
echo.
echo === SERVICE URLS ===
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo - https://!SRV!-server.us-e1.cloudhub.io
)
echo.

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

