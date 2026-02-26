@echo off
REM ========================================
REM PUBLISH PARENT POM TO EXCHANGE
REM ========================================

setlocal enabledelayedexpansion
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo 📤 PUBLISHING PARENT POM TO EXCHANGE
echo ========================================
echo Directory: %CD%
echo Parent POM: employee-onboarding-mcp-parent
echo.

REM === STEP 1: LOAD .env (REQUIRED) ===
echo 🔧 Loading .env...
if not exist ".env" (
    echo ❌ ERROR: .env file missing in %CD%
    echo Create .env with: ANYPOINT_CLIENT_ID, ANYPOINT_CLIENT_SECRET, ANYPOINT_ORG_ID
    pause
    exit /b 1
)

for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a" & set "val=%%b"
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
        echo   !key!=***LOADED***
    )
)

REM === STEP 2: VALIDATE CRITICAL VARS ===
echo 🔍 Validating config...
if not defined ANYPOINT_CLIENT_ID (echo ❌ ANYPOINT_CLIENT_ID missing & pause & exit /b 1)
if not defined ANYPOINT_CLIENT_SECRET (echo ❌ ANYPOINT_CLIENT_SECRET missing & pause & exit /b 1)
if not defined ANYPOINT_ORG_ID (echo ❌ ANYPOINT_ORG_ID missing & pause & exit /b 1)

echo ✅ Config validated:
echo   Org: %ANYPOINT_ORG_ID:~0,8%...
echo.

REM === STEP 3: PUBLISH PARENT POM TO EXCHANGE ===
echo 📤 Publishing Parent POM to Exchange...
echo.

REM Use stable version from pom.xml
set "PARENT_VERSION=1.0.0"

echo   📦 Parent POM Version: %PARENT_VERSION%
echo   🏷️  Asset: employee-onboarding-mcp-parent
echo   🆔 GroupId: %ANYPOINT_ORG_ID%
echo.

echo 📋 Publishing to Exchange with credentials...
call mvn clean deploy ^
    -DaltDeploymentRepository=anypoint-exchange-v3::default::https://maven.anypoint.mulesoft.com/api/v3/organizations/%ANYPOINT_ORG_ID%/maven ^
    -Danypoint.platform.client_id="%ANYPOINT_CLIENT_ID%" ^
    -Danypoint.platform.client_secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.businessGroup="%ANYPOINT_ORG_ID%" ^
    -DskipTests ^
    -U

if !errorlevel! equ 0 (
    echo ✅ Parent POM successfully published to Exchange!
    echo.
    echo 📋 EXCHANGE ASSET DETAILS:
    echo   🏷️  Name: Employee Onboarding MCP Parent
    echo   🆔 Asset ID: employee-onboarding-mcp-parent
    echo   📦 Version: %PARENT_VERSION%
    echo   🏢 Group ID: %ANYPOINT_ORG_ID%
    echo   📂 Classifier: pom
    echo.
    echo 🌐 View in Exchange:
    echo   https://anypoint.mulesoft.com/exchange/assets/%ANYPOINT_ORG_ID%/employee-onboarding-mcp-parent/
    echo.
    echo ✅ PARENT POM PUBLICATION COMPLETE!
) else (
    echo ❌ Parent POM publication failed!
    echo Check the error messages above for details.
)

echo.
pause
endlocal
