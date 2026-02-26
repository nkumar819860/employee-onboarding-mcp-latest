@echo off
setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo EXCHANGE PUBLICATION FIX - CLEAN VERSION
echo ========================================
echo Working directory: %CD%
echo.

REM Load environment variables from .env file
if not exist ".env" (
    echo ERROR: .env file not found
    pause
    exit /b 1
)

echo Loading environment variables...
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Remove spaces
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
    )
)

echo Environment variables loaded successfully
echo Client ID: %ANYPOINT_CLIENT_ID:~0,8%...
echo Organization: %ANYPOINT_ORG_ID:~0,8%...
echo.

REM Validate required variables
if not defined ANYPOINT_CLIENT_ID (
    echo ERROR: ANYPOINT_CLIENT_ID not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_CLIENT_SECRET (
    echo ERROR: ANYPOINT_CLIENT_SECRET not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_ORG_ID (
    echo ERROR: ANYPOINT_ORG_ID not found in .env
    pause
    exit /b 1
)

echo Configuration validated successfully
echo.

REM Discover MCP services
echo Discovering MCP services...
set SERVER_COUNT=0
set SERVER_LIST=

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        for %%n in (%%d) do (
            call set "SERVER!SERVER_COUNT!=%%~nxn"
            set "SERVER_LIST=!SERVER_LIST! %%~nxn"
            echo [!SERVER_COUNT!] Found: %%~nxn
        )
    )
)

if %SERVER_COUNT% EQU 0 (
    echo ERROR: No MCP services found
    pause
    exit /b 1
)

echo Discovered %SERVER_COUNT% MCP services:%SERVER_LIST%
echo.

REM Publish to Exchange
echo ========================================
echo PUBLISHING TO EXCHANGE
echo ========================================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] Publishing !SRV! to Exchange...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo Publishing from: %CD%
    
    REM Primary deployment approach
    echo Running Maven deployment...
    call mvn clean install deploy -DskipMuleApplicationDeployment -DskipTests -q -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
    
    if errorlevel 1 (
        echo ERROR: Failed to publish !SRV! to Exchange
        echo Trying alternative approach...
        
        REM Alternative approach
        call mvn clean install org.mule.tools.maven:exchange-mule-maven-plugin:3.4.0:exchange-deploy -DskipTests -q -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%"
        
        if errorlevel 1 (
            echo ERROR: Alternative approach also failed for !SRV!
            echo Continuing with next service...
        ) else (
            echo SUCCESS: !SRV! published to Exchange (alternative method)
        )
    ) else (
        echo SUCCESS: !SRV! published to Exchange successfully
    )
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ========================================
echo EXCHANGE PUBLISHING COMPLETED
echo ========================================
echo.
echo NEXT STEPS:
echo 1. Check Exchange portal: https://anypoint.mulesoft.com/exchange
echo 2. Verify your MCP assets are published
echo 3. If issues persist, check Connected App permissions
echo.

pause
endlocal
