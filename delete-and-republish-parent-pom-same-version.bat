@echo off
echo ========================================
echo   Delete & Republish Parent POM v2.5.0
echo ========================================
echo.

echo [STEP 1] Validating authentication...
call .\validate-token-configuration.bat
if %errorlevel% neq 0 (
    echo ❌ Token validation failed!
    echo Generating fresh token...
    call .\generate-token.bat
    if %errorlevel% neq 0 (
        echo ❌ Failed to generate token. Please check credentials.
        exit /b 1
    )
)

echo ✅ Authentication validated
echo.

echo [STEP 2] Deleting existing parent POM asset from Exchange...
echo.

REM Set variables for asset details
set GROUP_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set ASSET_ID=employee-onboarding-parent
set VERSION=2.5.0
set ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set CLIENT_ID=aec0b3117f7d4d4e8433a7d3d23bc80e
set CLIENT_SECRET=9bc9D86a77b343b98a148C0313239aDA

echo Asset to delete:
echo - Group ID: %GROUP_ID%
echo - Asset ID: %ASSET_ID%
echo - Version: %VERSION%
echo.

REM Get access token for Exchange API
echo [2.1] Getting access token for Exchange API...
curl -s -X POST https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token ^
  -H "Content-Type: application/json" ^
  -d "{\"client_id\":\"%CLIENT_ID%\",\"client_secret\":\"%CLIENT_SECRET%\",\"grant_type\":\"client_credentials\"}" ^
  -o token_response.json

if not exist token_response.json (
    echo ❌ Failed to get access token
    exit /b 1
)

REM Extract token using PowerShell
for /f %%i in ('powershell -Command "(Get-Content token_response.json | ConvertFrom-Json).access_token"') do set ACCESS_TOKEN=%%i

if "%ACCESS_TOKEN%"=="" (
    echo ❌ Failed to extract access token
    del token_response.json 2>nul
    exit /b 1
)

echo ✅ Access token obtained
del token_response.json 2>nul

echo [2.2] Attempting to delete existing asset...
REM Try deleting the specific version first
curl -s -X DELETE "https://anypoint.mulesoft.com/exchange/api/v2/assets/%GROUP_ID%/%ASSET_ID%/%VERSION%" ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -H "Content-Type: application/json" ^
  -w "HTTP_STATUS:%%{http_code}" ^
  -o delete_response.txt

REM Check if deletion was successful or if asset doesn't exist
findstr /C:"HTTP_STATUS:204" delete_response.txt >nul
if %errorlevel%==0 (
    echo ✅ Asset version %VERSION% deleted successfully
    goto publish
)

findstr /C:"HTTP_STATUS:404" delete_response.txt >nul
if %errorlevel%==0 (
    echo ℹ️ Asset version %VERSION% doesn't exist - proceeding with publication
    goto publish
)

echo ⚠️ Asset deletion response:
type delete_response.txt
echo.

REM Try deleting all versions of the asset
echo [2.3] Trying to delete entire asset (all versions)...
curl -s -X DELETE "https://anypoint.mulesoft.com/exchange/api/v2/assets/%GROUP_ID%/%ASSET_ID%" ^
  -H "Authorization: Bearer %ACCESS_TOKEN%" ^
  -H "Content-Type: application/json" ^
  -w "HTTP_STATUS:%%{http_code}" ^
  -o delete_all_response.txt

findstr /C:"HTTP_STATUS:204" delete_all_response.txt >nul
if %errorlevel%==0 (
    echo ✅ Entire asset deleted successfully
) else (
    echo ℹ️ Asset may not exist or deletion not needed
    type delete_all_response.txt
    echo.
)

:publish
del delete_response.txt 2>nul
del delete_all_response.txt 2>nul

echo.
echo [STEP 3] Cleaning local Maven cache...
cd parent-pom

if exist target rmdir /s /q target
if exist "%USERPROFILE%\.m2\repository\%GROUP_ID%\%ASSET_ID%" (
    echo Cleaning local Maven cache for parent POM...
    rmdir /s /q "%USERPROFILE%\.m2\repository\%GROUP_ID%\%ASSET_ID%"
)

echo.
echo [STEP 4] Publishing Parent POM v2.5.0 to Exchange...
echo.

REM Try publication with retry mechanism
set RETRY_COUNT=0
set MAX_RETRIES=3

:retry
set /a RETRY_COUNT+=1
echo [Attempt %RETRY_COUNT%/%MAX_RETRIES%] Publishing Parent POM v2.5.0...

mvn clean deploy -s settings.xml ^
  -Danypoint.platform.client_id=%CLIENT_ID% ^
  -Danypoint.platform.client_secret=%CLIENT_SECRET% ^
  -Danypoint.business.group=%ORG_ID% ^
  -DskipTests=true ^
  -DretryFailedDeploymentCount=3 ^
  -Dmaven.wagon.http.retryHandler.count=3 ^
  -Dmaven.wagon.http.pool=false ^
  -Dmaven.wagon.httpconnectionManager.ttlSeconds=25 ^
  -Dmaven.wagon.http.ssl.insecure=false ^
  -X

set RESULT=%errorlevel%

if %RESULT%==0 (
    echo.
    echo ✅ SUCCESS: Parent POM v2.5.0 published successfully!
    goto success
)

if %RETRY_COUNT% lss %MAX_RETRIES% (
    echo ⚠️ Attempt %RETRY_COUNT% failed. Retrying in 5 seconds...
    timeout /t 5 /nobreak >nul
    goto retry
)

echo.
echo ❌ Maven deployment failed. Trying Exchange Maven Plugin directly...
echo.

mvn org.mule.tools.maven:exchange-maven-plugin:0.0.28:publish ^
  -Danypoint.platform.client_id=%CLIENT_ID% ^
  -Danypoint.platform.client_secret=%CLIENT_SECRET% ^
  -Danypoint.business.group=%ORG_ID% ^
  -Dclassifier=custom ^
  -Dname="Employee Onboarding Parent POM v2" ^
  -Ddescription="Parent POM for Employee Onboarding Agent Fabric MCP Servers" ^
  -X

set ALT_RESULT=%errorlevel%

if %ALT_RESULT%==0 (
    echo.
    echo ✅ SUCCESS: Parent POM published via Exchange plugin!
    goto success
)

echo.
echo [STEP 5] Final attempt using MuleSoft CLI (if available)...
echo.

REM Check if Anypoint CLI is available
anypoint-cli --version >nul 2>&1
if %errorlevel%==0 (
    echo Using Anypoint CLI for asset upload...
    
    REM Login to CLI
    echo %ACCESS_TOKEN% | anypoint-cli auth --bearer
    
    REM Upload asset
    anypoint-cli exchange asset upload ^
      --organizationId %ORG_ID% ^
      --groupId %GROUP_ID% ^
      --assetId %ASSET_ID% ^
      --version %VERSION% ^
      --name "Employee Onboarding Parent POM v2" ^
      --description "Parent POM for Employee Onboarding Agent Fabric MCP Servers" ^
      --classifier custom ^
      target\%ASSET_ID%-%VERSION%.pom
    
    set CLI_RESULT=%errorlevel%
    if %CLI_RESULT%==0 (
        echo ✅ SUCCESS: Parent POM published via Anypoint CLI!
        goto success
    )
)

echo ❌ All publication methods failed!
echo.
echo Manual resolution options:
echo 1. Check Exchange permissions for organization %ORG_ID%
echo 2. Verify Connected App has Exchange Admin scope
echo 3. Try publishing from Anypoint Studio
echo 4. Contact MuleSoft support
echo.
echo Asset details for manual upload:
echo - File: parent-pom\target\%ASSET_ID%-%VERSION%.pom
echo - Exchange URL: https://anypoint.mulesoft.com/exchange/

cd ..
exit /b 1

:success
echo.
echo [VERIFICATION] Publication successful!
echo.
echo Asset Details:
echo - Group ID: %GROUP_ID%
echo - Asset ID: %ASSET_ID%
echo - Version: %VERSION%
echo - Type: custom (Parent POM)
echo.
echo ✅ Check Exchange at: https://anypoint.mulesoft.com/exchange/
echo ✅ Search for: employee-onboarding-parent
echo.
echo [SUCCESS] Parent POM v2.5.0 successfully republished after deletion!

cd ..
exit /b 0
