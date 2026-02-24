@echo off
echo ====================================
echo  TESTING ANYPOINT CREDENTIALS
echo ====================================

REM Load environment variables from .env
if exist ".env" (
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" set "%%a=%%b"
    )
    echo [SUCCESS] .env loaded
) else (
    echo [ERROR] .env NOT FOUND!
    pause & exit /b 1
)

echo [INFO] Testing credentials...
echo Client ID: %ANYPOINT_CLIENT_ID%
echo Org ID: %ANYPOINT_ORG_ID%
echo Environment: %ANYPOINT_ENV%
echo.

echo Testing authentication with curl...
curl -X POST "https://anypoint.mulesoft.com/accounts/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"client_id\":\"%ANYPOINT_CLIENT_ID%\",\"client_secret\":\"%ANYPOINT_CLIENT_SECRET%\",\"grant_type\":\"client_credentials\"}"

echo.
pause
