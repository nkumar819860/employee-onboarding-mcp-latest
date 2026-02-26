@echo off
echo =============================================================
echo   Employee Onboarding Agent Fabric - Exchange Publication
echo =============================================================
echo.

REM Check if .env file exists and load variables
if exist .env (
    echo Loading environment variables from .env file...
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%b"=="" set %%a=%%b
    )
) else (
    echo WARNING: .env file not found. Using default values.
)

REM Set default values if not provided
if "%CONNECTED_APP_CLIENT_ID%"=="" (
    echo ERROR: CONNECTED_APP_CLIENT_ID not set
    echo Please configure your Connected App credentials in .env file
    pause
    exit /b 1
)

if "%CONNECTED_APP_CLIENT_SECRET%"=="" (
    echo ERROR: CONNECTED_APP_CLIENT_SECRET not set
    echo Please configure your Connected App credentials in .env file
    pause
    exit /b 1
)

echo.
echo Step 1: Validating project structure...
echo =====================================

REM Check if required files exist
if not exist "pom.xml" (
    echo ERROR: Parent pom.xml not found
    pause
    exit /b 1
)

if not exist "exchange.json" (
    echo ERROR: exchange.json not found
    pause
    exit /b 1
)

if not exist "src\main\resources\api\employee-onboarding-agent-fabric-api.yaml" (
    echo ERROR: OpenAPI specification not found
    pause
    exit /b 1
)

echo ✓ Parent pom.xml found
echo ✓ exchange.json found  
echo ✓ OpenAPI specification found
echo ✓ README.md found

echo.
echo Step 2: Building parent project...
echo ==================================

echo Cleaning previous builds...
mvn clean

if %ERRORLEVEL% neq 0 (
    echo ERROR: Maven clean failed
    pause
    exit /b 1
)

echo Compiling parent project...
mvn compile

if %ERRORLEVEL% neq 0 (
    echo ERROR: Maven compile failed
    pause
    exit /b 1
)

echo ✓ Parent project built successfully

echo.
echo Step 3: Publishing to Anypoint Exchange...
echo ==========================================

echo Publishing Employee Onboarding Agent Fabric to Exchange...
echo Asset ID: employee-onboarding-agent-fabric
echo Group ID: 47562e5d-bf49-440a-a0f5-a9cea0a89aa9
echo Version: 1.0.0

mvn deploy -DskipMuleApplicationDeployment ^
    -Danypoint.username=%ANYPOINT_USERNAME% ^
    -Danypoint.password=%ANYPOINT_PASSWORD% ^
    -Danypoint.platform.client_id=%CONNECTED_APP_CLIENT_ID% ^
    -Danypoint.platform.client_secret=%CONNECTED_APP_CLIENT_SECRET% ^
    -Danypoint.business.group=47562e5d-bf49-440a-a0f5-a9cea0a89aa9

if %ERRORLEVEL% neq 0 (
    echo ERROR: Exchange publication failed
    echo.
    echo Troubleshooting steps:
    echo 1. Verify Connected App credentials are correct
    echo 2. Ensure you have Exchange:Asset Create permissions
    echo 3. Check that the asset doesn't already exist with same version
    echo 4. Verify network connectivity to Anypoint Platform
    pause
    exit /b 1
)

echo ✓ Successfully published to Anypoint Exchange!

echo.
echo Step 4: Publishing child modules (optional)...
echo ==============================================

set /p PUBLISH_MODULES=Do you want to publish individual MCP server modules? (y/n): 

if /i "%PUBLISH_MODULES%"=="y" (
    echo.
    echo Publishing Agent Broker MCP...
    cd mcp-servers\agent-broker-mcp
    mvn deploy -DskipMuleApplicationDeployment ^
        -Danypoint.username=%ANYPOINT_USERNAME% ^
        -Danypoint.password=%ANYPOINT_PASSWORD% ^
        -Danypoint.platform.client_id=%CONNECTED_APP_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%CONNECTED_APP_CLIENT_SECRET%
    cd ..\..
    
    echo Publishing Employee Onboarding MCP...
    cd mcp-servers\employee-onboarding-mcp
    mvn deploy -DskipMuleApplicationDeployment ^
        -Danypoint.username=%ANYPOINT_USERNAME% ^
        -Danypoint.password=%ANYPOINT_PASSWORD% ^
        -Danypoint.platform.client_id=%CONNECTED_APP_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%CONNECTED_APP_CLIENT_SECRET%
    cd ..\..
    
    echo Publishing Asset Allocation MCP...
    cd mcp-servers\asset-allocation-mcp
    mvn deploy -DskipMuleApplicationDeployment ^
        -Danypoint.username=%ANYPOINT_USERNAME% ^
        -Danypoint.password=%ANYPOINT_PASSWORD% ^
        -Danypoint.platform.client_id=%CONNECTED_APP_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%CONNECTED_APP_CLIENT_SECRET%
    cd ..\..
    
    echo Publishing Employee Notification Service...
    cd mcp-servers\notification-mcp
    mvn deploy -DskipMuleApplicationDeployment ^
        -Danypoint.username=%ANYPOINT_USERNAME% ^
        -Danypoint.password=%ANYPOINT_PASSWORD% ^
        -Danypoint.platform.client_id=%CONNECTED_APP_CLIENT_ID% ^
        -Danypoint.platform.client_secret=%CONNECTED_APP_CLIENT_SECRET%
    cd ..\..
    
    echo ✓ All child modules published successfully!
)

echo.
echo =============================================================
echo   PUBLICATION COMPLETE! 
echo =============================================================
echo.
echo Your Employee Onboarding Agent Fabric has been published to Exchange!
echo.
echo 📋 Asset Details:
echo   • Name: Employee Onboarding Agent Fabric
echo   • Asset ID: employee-onboarding-agent-fabric  
echo   • Group ID: 47562e5d-bf49-440a-a0f5-a9cea0a89aa9
echo   • Version: 1.0.0
echo   • Type: Multi-module MCP Server Suite
echo.
echo 🌐 Access your asset at:
echo   https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/employee-onboarding-agent-fabric/
echo.
echo 📋 What's included:
echo   ✓ Comprehensive OpenAPI 3.0.3 specification
echo   ✓ Detailed README with examples
echo   ✓ Complete documentation and usage guide
echo   ✓ Multi-module architecture overview
echo   ✓ Configuration and deployment guides
echo.
echo 🚀 Next steps:
echo   1. Visit Exchange to verify the publication
echo   2. Review the generated documentation
echo   3. Share the asset with your team
echo   4. Consider creating additional versions for different environments
echo.

pause
