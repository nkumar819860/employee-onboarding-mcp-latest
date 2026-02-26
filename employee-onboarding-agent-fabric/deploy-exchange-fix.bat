@echo off
REM ========================================
REM EXCHANGE PUBLICATION FIX SCRIPT
REM Fix for 403 Forbidden error
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo EXCHANGE PUBLICATION FIX
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: LOAD ENVIRONMENT VARIABLES ===
echo ==============================
echo 🔧 LOADING ENVIRONMENT VARIABLES
echo ==============================

if not exist ".env" (
    echo ❌ ERROR: .env file not found in %CD%
    pause
    exit /b 1
)

REM Load environment variables from .env file
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim whitespace from key and value
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
    )
)

echo ✅ Environment variables loaded

REM === STEP 2: VALIDATE CONFIGURATION ===
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

echo ✅ Configuration validated
echo   Client ID: %ANYPOINT_CLIENT_ID:~0,8%...
echo   Organization: %ANYPOINT_ORG_ID:~0,8%...
echo.

REM === STEP 3: DISCOVER MCP SERVICES ===
echo ==============================
echo 🔍 DISCOVERING MCP SERVICES
echo ==============================

set SERVER_COUNT=0
set SERVER_LIST=

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
    echo ❌ ERROR: No MCP services found
    pause
    exit /b 1
)

echo ✅ Discovered %SERVER_COUNT% MCP services:%SERVER_LIST%
echo.

REM === STEP 4: PUBLISH TO EXCHANGE (FIXED APPROACH) ===
echo ==============================
echo 📤 PUBLISHING TO EXCHANGE (FIXED)
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 📤 Publishing !SRV! to Exchange...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo 📁 Publishing from: %CD%
    
    echo   Using the exchange-mule-maven-plugin for Exchange publication...
    
    REM Use the correct Exchange publication approach
    call mvn clean install deploy ^
        -DskipMuleApplicationDeployment ^
        -DskipTests ^
        -q ^
        -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" ^
        -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
        -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
        -Danypoint.platform.analytics.base.uri="https://analytics-ingest.anypoint.mulesoft.com" ^
        -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
        -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
    
    if !errorlevel! neq 0 (
        echo ❌ ERROR: Failed to publish !SRV! to Exchange
        echo ℹ️  Trying alternative approach...
        
        REM Try alternative approach with different parameter format
        call mvn clean install ^
            org.mule.tools.maven:exchange-mule-maven-plugin:3.4.0:exchange-deploy ^
            -DskipTests ^
            -q ^
            -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" ^
            -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
            -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%"
        
        if !errorlevel! neq 0 (
            echo ❌ ERROR: Alternative approach also failed for !SRV!
            echo ℹ️  Continuing with next service...
        ) else (
            echo ✅ !SRV! published to Exchange successfully (alternative approach)
        )
    ) else (
        echo ✅ !SRV! published to Exchange successfully
    )
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ Exchange publishing process completed
echo.
echo NEXT STEPS:
echo 1. Check Exchange portal: https://anypoint.mulesoft.com/exchange
echo 2. Verify your MCP assets are published
echo 3. If issues persist, check Connected App permissions
echo.

pause
endlocal
