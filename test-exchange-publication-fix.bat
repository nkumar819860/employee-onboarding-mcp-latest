@echo off
echo ========================================
echo  EXCHANGE PUBLICATION FIX TEST
echo ========================================
echo.

REM Set environment variables
set MAVEN_OPTS=-Xmx2048m -XX:MaxPermSize=512m
set CLIENT_ID=aec0b3117f7d4d4e8433a7d3d23bc80e
set CLIENT_SECRET=9bc9D86a77b343b98a148C0313239aDA
set BUSINESS_GROUP=47562e5d-bf49-440a-a0f5-a9cea0a89aa9

echo Step 1: Clean and compile the asset-allocation-mcp project...
cd "employee-onboarding-agent-fabric\mcp-servers\asset-allocation-mcp"

echo Cleaning previous builds...
call mvn clean -q
if %errorlevel% neq 0 (
    echo ERROR: Maven clean failed
    pause
    exit /b 1
)

echo Compiling project...
call mvn compile -q
if %errorlevel% neq 0 (
    echo ERROR: Maven compile failed
    pause
    exit /b 1
)

echo.
echo Step 2: Testing exchange publication...
echo Command: mvn deploy -Dconnected.app.client.id=%CLIENT_ID% -Dconnected.app.client.secret=%CLIENT_SECRET% -Danypoint.business.group=%BUSINESS_GROUP%

call mvn deploy -Dconnected.app.client.id=%CLIENT_ID% -Dconnected.app.client.secret=%CLIENT_SECRET% -Danypoint.business.group=%BUSINESS_GROUP% -DskipTests=true

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS: Exchange publication completed successfully!
    echo.
    echo Asset Details:
    echo - Name: Asset Allocation MCP Server
    echo - Version: 2.0.0
    echo - GroupId: %BUSINESS_GROUP%
    echo - Classifier: mule-application
    echo.
) else (
    echo.
    echo ❌ ERROR: Exchange publication failed with error code %errorlevel%
    echo.
    echo Troubleshooting steps:
    echo 1. Check network connectivity to Anypoint Exchange
    echo 2. Verify connected app credentials are valid
    echo 3. Ensure business group ID is correct
    echo 4. Check if exchange.json main file reference is correct
    echo.
)

echo.
echo Step 3: Verify exchange.json configuration...
echo Main file reference: 
findstr "main" "exchange.json"
echo.

echo Step 4: Check pom.xml exchange plugin configuration...
echo Exchange plugin version: 
findstr "exchange-mule-maven-plugin" "pom.xml" -A 1
echo.

cd ..\..\..
echo Test completed. Press any key to continue...
pause >nul
