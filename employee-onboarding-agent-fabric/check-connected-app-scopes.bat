@echo off
echo ========================================
echo 🔍 CHECK CONNECTED APP SCOPES
echo ========================================

REM Get token response
curl -s ^
  -X POST ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "grant_type=client_credentials&client_id=25bb2da884004ff6af264101e535c5f9&client_secret=758185C9B0964D2b961f066F582379a2" ^
  https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token ^
  > token.json

REM Extract scopes
for /f "tokens=2 delims=:," %%a in ('findstr "scope" token.json') do (
  set SCOPE=%%a
  set SCOPE=%SCOPE:~1,-1%
)

if "%SCOPE%"=="" (
  echo ❌ NO SCOPES DETECTED
  echo   👉 Add: Organization Administrator + API
