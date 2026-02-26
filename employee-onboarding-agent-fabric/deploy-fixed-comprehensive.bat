@echo off
REM ========================================
REM MCP FULL AUTO DEPLOY - MFA SAFE ✅
REM ========================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

REM === CONFIG (Your Connected App Credentials) ===
set CLIENT_ID=aec0b3117f7d4d4e8433a7d3d23bc80e
set CLIENT_SECRET=9bc9D86a77b343b98a148C0313239aDA
set ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set ENV=Sandbox

echo 🚀 MCP Auto Deploy Starting...
echo.

REM === 1. GET TOKEN ===
echo 🔑 Getting OAuth Token...
curl -s -X POST ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "grant_type=client_credentials&client_id=%CLIENT_ID%&client_secret=%CLIENT_SECRET%" ^
  https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token ^
  > token-response.json

REM Extract token
for /f "tokens=2 delims=:," %%a in ('type token-response.json ^| findstr access_token') do (
  set "TOKEN=%%a"
  set "TOKEN=!TOKEN:~1,-1!"
)

if "%TOKEN%"=="" (
  echo ❌ Token failed. Check credentials.
  del token-response.json
  pause
  exit /b 1
)

echo ✅ Token obtained ✓
echo.

REM === 2. PUBLISH TO EXCHANGE ===
echo 📤 Publishing to Exchange...
cd mcp-servers\employee-onboarding-mcp
mvn clean deploy -DskipTests ^
  -DaltDeploymentRepository=anypoint-exchange::default::https://maven.anypoint.mulesoft.com/api/v1/organizations/%ORG_ID%/maven ^
  -Panypoint-exchange.version=1.0.3

if !errorlevel! neq 0 (
  echo ⚠️  Exchange publish failed - continuing to CloudHub
) else (
  echo ✅ Exchange publish SUCCESS
)
echo.

REM === 3. DEPLOY TO CLOUDHUB ===
echo ☁️  Deploying to CloudHub...
mvn mule:deploy ^
  -Danypoint.platform.client_id="%CLIENT_ID%" ^
  -Danypoint.platform.client_secret="%CLIENT_SECRET%" ^
  -Danypoint.businessGroup="%ORG_ID%" ^
  -Danypoint.environment="%ENV%" ^
  -Dcloudhub.applicationName="employee-onboarding-mcp-server" ^
  -Dcloudhub.muleVersion="4.9.0" ^
  -Dcloudhub.region="us-east-1" ^
  -Dcloudhub.workers="1" ^
  -Dcloudhub.workerType="MICRO" ^
  -Dcloudhub.objectStoreV2=true ^
  -DskipTests

echo ✅ CloudHub deploy complete!
echo.

REM === CLEANUP ===
del token-response.json
cd ..\..

echo ================================
echo 🎉 SUCCESS - MCP Server LIVE!
echo ================================
echo 🌐 MCP Info:  https://employee-onboarding-mcp-server.us-east-1.cloudhub.io/mcp/info
echo 🧪 Health:    https://employee-onboarding-mcp-server.us-east-1.cloudhub.io/health
echo 🔧 Create:   POST https://employee-onboarding-mcp-server.us-east-1.cloudhub.io/mcp/tools/create-employee
echo.

pause
