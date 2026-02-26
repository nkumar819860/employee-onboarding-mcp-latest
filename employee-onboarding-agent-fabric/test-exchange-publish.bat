@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Testing Exchange Publication with Fixed Credentials
echo ========================================

:: Load environment variables
if exist .env (
    echo Loading environment variables from .env...
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
) else (
    echo ERROR: .env file not found
    exit /b 1
)

echo.
echo Testing Exchange publish with asset-allocation-mcp...
echo =====================================================

cd mcp-servers\asset-allocation-mcp

echo Step 1: Clean and package...
call mvn clean package -DskipTests -q
if !ERRORLEVEL! neq 0 (
    echo FAILED: Could not build asset-allocation-mcp
    cd ..\..
    exit /b 1
)

echo Step 2: Publishing to Exchange (TESTING FIXED CREDENTIALS)...
echo Server ID: anypoint-exchange
echo Bearer Token: 0ac15409-3918-46f3-86c6-e34d5183d47c
echo Organization: 47562e5d-bf49-440a-a0f5-a9cea0a89aa9
echo.
call mvn deploy -DskipMuleApplicationDeployment -DskipTests -X
set DEPLOY_RESULT=!ERRORLEVEL!

cd ..\..

echo.
echo ========================================
if !DEPLOY_RESULT! equ 0 (
    echo SUCCESS: Exchange publication worked!
    echo The 401 error has been resolved.
    echo All credentials are properly configured.
) else (
    echo FAILED: Exchange publication failed
    echo Check the detailed Maven output above for specific errors
    echo Error code: !DEPLOY_RESULT!
)
echo ========================================

exit /b !DEPLOY_RESULT!
