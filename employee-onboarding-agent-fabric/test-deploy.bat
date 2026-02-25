@echo off
REM ========================================
REM TEST DEPLOYMENT SCRIPT
REM Validates the deploy.bat functionality
REM ========================================

echo ========================================
echo TESTING DEPLOYMENT SCRIPT
echo ========================================
echo.

REM Test 1: Check if .env file exists
echo 🧪 Test 1: Environment file validation
if exist ".env" (
    echo ✅ .env file found
) else (
    echo ❌ .env file missing
    goto :error
)

REM Test 2: Check if mcp-servers directory exists
echo 🧪 Test 2: MCP servers directory validation
if exist "mcp-servers" (
    echo ✅ mcp-servers directory found
) else (
    echo ❌ mcp-servers directory missing
    goto :error
)

REM Test 3: Count MCP services
echo 🧪 Test 3: MCP services discovery
set SERVER_COUNT=0
for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        echo ✅ Found MCP service: %%~nxd
    )
)

if %SERVER_COUNT% EQU 0 (
    echo ❌ No MCP services found
    goto :error
) else (
    echo ✅ Found %SERVER_COUNT% MCP services
)

REM Test 4: Check Maven availability
echo 🧪 Test 4: Maven availability check
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Maven not available in PATH
    echo Please ensure Maven is installed and in PATH
    goto :error
) else (
    echo ✅ Maven is available
)

REM Test 5: Check environment variables loading
echo 🧪 Test 5: Environment variables validation
setlocal enabledelayedexpansion

for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" set "!key!=!val!"
)

if not defined ANYPOINT_CLIENT_ID (
    echo ❌ ANYPOINT_CLIENT_ID missing from .env
    goto :error
) else (
    echo ✅ ANYPOINT_CLIENT_ID loaded: %ANYPOINT_CLIENT_ID:~0,8%...
)

if not defined ANYPOINT_CLIENT_SECRET (
    echo ❌ ANYPOINT_CLIENT_SECRET missing from .env
    goto :error
) else (
    echo ✅ ANYPOINT_CLIENT_SECRET loaded: %ANYPOINT_CLIENT_SECRET:~0,8%...
)

if not defined ANYPOINT_ORG_ID (
    echo ❌ ANYPOINT_ORG_ID missing from .env
    goto :error
) else (
    echo ✅ ANYPOINT_ORG_ID loaded: %ANYPOINT_ORG_ID:~0,8%...
)

endlocal

echo.
echo ========================================
echo ✅ ALL TESTS PASSED
echo ========================================
echo.
echo The deployment script should work correctly.
echo You can now run deploy.bat to:
echo   - Load environment variables
echo   - Clean target folders
echo   - Compile all MCP services
echo   - Publish assets to Exchange
echo   - Deploy to CloudHub
echo   - Perform health checks
echo.
echo Run the deployment script with:
echo   deploy.bat
echo.
goto :end

:error
echo.
echo ========================================
echo ❌ TESTS FAILED
echo ========================================
echo.
echo Please fix the issues above before running deploy.bat
echo.

:end
pause
