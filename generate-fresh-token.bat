@echo off
echo =====================================
echo   Anypoint Token Generator
echo =====================================
echo.

echo Using your Connected App credentials to generate a fresh bearer token...
echo Client ID: 867ff64da92f4dd89c428f27c3f7c7f1
echo.

echo Making API request to get token...
curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
  -H "Content-Type: application/json" ^
  -d "{\"client_id\": \"867ff64da92f4dd89c428f27c3f7c7f1\", \"client_secret\": \"09f4C0a99F494785be2918F6e0Cd6e9B\", \"grant_type\": \"client_credentials\"}" ^
  -s -o employee-onboarding-agent-fabric/token.json

if %errorlevel% neq 0 (
    echo ❌ Failed to get token. Check your internet connection and credentials.
    pause
    exit /b 1
)

echo.
echo ✅ Token response saved to token.json:
echo.
type employee-onboarding-agent-fabric\token.json

echo.
echo.
echo =====================================
echo   Extract Token for Settings.xml
echo =====================================
echo.
echo To update your settings.xml with the new token:
echo 1. Copy the "access_token" value from the JSON above
echo 2. Replace the password in your settings.xml:
echo.
echo   ^<server^>
echo     ^<id^>anypoint-exchange^</id^>
echo     ^<username^>~~~Token~~~^</username^>
echo     ^<password^>PASTE_YOUR_TOKEN_HERE^</password^>
echo   ^</server^>
echo.
echo =====================================

pause
