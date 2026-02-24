@echo off
echo ============================================
echo    DEBUG .ENV FILE LOADING
echo    Checking if environment variables are loaded correctly
echo ============================================
echo.

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [INFO] Current directory: %CD%
echo [INFO] Checking for .env file...

if not exist ".env" (
    echo [ERROR] .env file not found!
    pause
    exit /b 1
)

echo [SUCCESS] .env file exists
echo.

echo [INFO] Loading .env file...
echo [DEBUG] Processing .env line by line:
echo.

REM Load from .env with debugging
for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
    if not "%%a"=="" if not "%%a:~0,1%"=="#" (
        echo [DEBUG] Setting %%a=%%b
        set "%%a=%%b"
    )
)

echo.
echo [INFO] Environment variables after loading:
echo.

echo ANYPOINT_CLIENT_ID=%ANYPOINT_CLIENT_ID%
echo ANYPOINT_CLIENT_SECRET=%ANYPOINT_CLIENT_SECRET%
echo ANYPOINT_ORG_ID=%ANYPOINT_ORG_ID%
echo ANYPOINT_BUSINESS_GROUP_ID=%ANYPOINT_BUSINESS_GROUP_ID%
echo.

echo [INFO] Checking if variables are empty:
if "%ANYPOINT_CLIENT_ID%"=="" echo [WARNING] ANYPOINT_CLIENT_ID is empty!
if "%ANYPOINT_CLIENT_SECRET%"=="" echo [WARNING] ANYPOINT_CLIENT_SECRET is empty!
if "%ANYPOINT_ORG_ID%"=="" echo [WARNING] ANYPOINT_ORG_ID is empty!

echo.
echo [INFO] Testing substring operation (masking):
echo Client ID masked: %ANYPOINT_CLIENT_ID:~0,12%...
echo Client Secret masked: %ANYPOINT_CLIENT_SECRET:~0,6%...

echo.
echo [INFO] .env file contents (first 20 lines):
echo.
for /l %%i in (1,1,20) do (
    for /f "skip=%%i tokens=*" %%a in (.env) do (
        echo %%a
        goto :next
    )
    :next
)

echo.
echo ============================================
echo    DEBUG COMPLETE
echo ============================================
pause
