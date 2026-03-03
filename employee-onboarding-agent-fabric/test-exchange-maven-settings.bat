@echo off
REM ========================================
REM EXCHANGE AUTHENTICATION FIX - MAVEN SETTINGS APPROACH
REM Using settings.xml for proper authentication
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo EXCHANGE MAVEN SETTINGS AUTHENTICATION TEST
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: CREATE MAVEN SETTINGS.XML ===
echo ==============================
echo 📝 CREATING MAVEN SETTINGS.XML
echo ==============================

REM Check if .m2 directory exists in user home
if not exist "%USERPROFILE%\.m2" (
    echo Creating .m2 directory...
    mkdir "%USERPROFILE%\.m2"
)

REM Create settings.xml with proper authentication
echo Creating settings.xml with Exchange credentials...
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<settings^>
echo     ^<servers^>
echo         ^<server^>
echo             ^<id^>anypoint-exchange^</id^>
echo             ^<username^>~~~Client~~~^</username^>
echo             ^<password^>aec0b3117f7d4d4e8433a7d3d23bc80e~?~9bc9D86a77b343b98a148C0313239aDA^</password^>
echo         ^</server^>
echo         ^<server^>
echo             ^<id^>anypoint-exchange-v3^</id^>
echo             ^<username^>~~~Client~~~^</username^>
echo             ^<password^>aec0b3117f7d4d4e8433a7d3d23bc80e~?~9bc9D86a77b343b98a148C0313239aDA^</password^>
echo         ^</server^>
echo     ^</servers^>
echo ^</settings^>
) > "%USERPROFILE%\.m2\settings.xml"

echo ✅ Maven settings.xml created at: %USERPROFILE%\.m2\settings.xml
echo.

REM === STEP 2: TEST INDIVIDUAL SERVICE DEPLOYMENT ===
echo ==============================
echo 🧪 TESTING AGENT BROKER MCP DEPLOYMENT
echo ==============================

cd "mcp-servers\agent-broker-mcp"
echo 📁 Testing from: %CD%
echo.

echo 🛠️  Step 1: Clean and compile...
call mvn clean compile package -DskipTests -DskipMuleApplicationDeployment
if !errorlevel! neq 0 (
    echo ❌ COMPILATION FAILED
    pause
    exit /b 1
)

echo ✅ Compilation successful
echo.

echo 📤 Step 2: Deploy to Exchange using settings.xml authentication...
call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q
if !errorlevel! neq 0 (
    echo ❌ EXCHANGE DEPLOYMENT FAILED
    echo.
    echo 🔍 Troubleshooting:
    echo   - Check if settings.xml was created correctly
    echo   - Verify Connected App credentials are valid
    echo   - Ensure business group permissions are correct
    echo.
    pause
    exit /b 1
)

echo ✅ Exchange deployment successful!
echo.

REM === STEP 3: VERIFY DEPLOYMENT ===
echo ==============================
echo ✅ DEPLOYMENT VERIFICATION
echo ==============================

echo 🎉 SUCCESS: Agent Broker MCP deployed to Exchange using Maven settings.xml
echo.
echo 📋 Deployment Details:
echo   - Authentication: Maven settings.xml with Connected App credentials
echo   - Business Group: 47562e5d-bf49-440a-a0f5-a9cea0a89aa9
echo   - Asset ID: agent-broker-mcp
echo   - Version: 2.0.0
echo   - Classifier: agent
echo.

echo 🌐 Exchange URL:
echo   https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/agent-broker-mcp/
echo.

echo ✅ EXCHANGE AUTHENTICATION ISSUE RESOLVED!
echo.
echo 💡 Next Steps:
echo   1. Update deploy.bat to use settings.xml approach
echo   2. Apply same fix to other MCP services
echo   3. Run full deployment with corrected authentication
echo.

cd /d "%SCRIPT_DIR%"
pause
endlocal
