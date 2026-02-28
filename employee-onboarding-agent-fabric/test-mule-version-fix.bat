@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo TESTING MULE VERSION FIX - Notification MCP Server
echo ====================================================
echo.

:: Load environment variables
if exist .env (
    echo Loading .env file...
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
) else (
    echo .env file not found! Creating basic .env...
    echo ANYPOINT_USERNAME=your-username> .env
    echo ANYPOINT_PASSWORD=your-password>> .env
    echo ANYPOINT_ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9>> .env
    echo ANYPOINT_ENV=Sandbox>> .env
)

cd mcp-servers\notification-mcp

echo.
echo Testing Maven validate to check Mule version compatibility...
echo Running: mvn validate -X
echo.

mvn validate -X 2>&1 | findstr /I "muleVersion\|error\|exception\|BUILD"

echo.
echo ====================================================
echo If you see BUILD SUCCESS above, the version fix worked!
echo If you see errors about muleVersion, please check the logs.
echo ====================================================

cd ..\..

pause
