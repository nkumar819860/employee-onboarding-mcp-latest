@echo off
echo ========================================
echo  MCP Services - Deploy and Publish to Exchange
echo ========================================
echo.

REM Set environment variables
set MAVEN_OPTS=-Xmx1024m
set JAVA_HOME=%JAVA_HOME%

REM Check if Maven is available
mvn --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Maven is not installed or not in PATH
    echo Please install Maven and ensure it's in your PATH
    pause
    exit /b 1
)

REM Check if Anypoint CLI is available
anypoint-cli-v4 --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Anypoint CLI is not installed or not in PATH
    echo You can install it with: npm install -g @mulesoft/anypoint-cli-v4
    echo Continuing without CLI validation...
    echo.
)

echo Starting deployment and Exchange publishing process...
echo.

REM Navigate to MCP servers directory
cd mcp-servers

echo ========================================
echo  1. Publishing Notification MCP Server
echo ========================================
cd notification-mcp
echo Building and publishing notification-mcp-server...
call mvn clean compile
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed for notification-mcp-server
    cd ..\..
    pause
    exit /b 1
)

echo Publishing to Exchange...
call mvn deploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Exchange publishing failed for notification-mcp-server
    cd ..\..
    pause
    exit /b 1
)

echo Deploying to CloudHub...
call mvn deploy -DmuleDeploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CloudHub deployment failed for notification-mcp-server
    echo Note: This might be due to missing environment variables or credentials
    echo Please check your Maven settings.xml and environment configuration
)

cd ..

echo.
echo ========================================
echo  2. Publishing Asset Allocation MCP Server
echo ========================================
cd asset-allocation-mcp
echo Building and publishing asset-allocation-mcp-server...
call mvn clean compile
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed for asset-allocation-mcp-server
    cd ..\..
    pause
    exit /b 1
)

echo Publishing to Exchange...
call mvn deploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Exchange publishing failed for asset-allocation-mcp-server
    cd ..\..
    pause
    exit /b 1
)

echo Deploying to CloudHub...
call mvn deploy -DmuleDeploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CloudHub deployment failed for asset-allocation-mcp-server
    echo Note: This might be due to missing environment variables or credentials
    echo Please check your Maven settings.xml and environment configuration
)

cd ..

echo.
echo ========================================
echo  3. Publishing Agent Broker MCP Server
echo ========================================
cd agent-broker-mcp
echo Building and publishing employee-onboarding-agent-broker...
call mvn clean compile
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed for employee-onboarding-agent-broker
    cd ..\..
    pause
    exit /b 1
)

echo Publishing to Exchange...
call mvn deploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Exchange publishing failed for employee-onboarding-agent-broker
    cd ..\..
    pause
    exit /b 1
)

echo Deploying to CloudHub...
call mvn deploy -DmuleDeploy -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CloudHub deployment failed for employee-onboarding-agent-broker
    echo Note: This might be due to missing environment variables or credentials
    echo Please check your Maven settings.xml and environment configuration
)

cd ..\..

echo.
echo ========================================
echo  Deployment and Publishing Summary
echo ========================================
echo.
echo All services have been processed:
echo.
echo 1. Notification MCP Server
echo    - Artifact ID: notification-mcp-server
echo    - Exchange: Published
echo    - CloudHub: Attempted deployment
echo.
echo 2. Asset Allocation MCP Server  
echo    - Artifact ID: asset-allocation-mcp-server
echo    - Exchange: Published
echo    - CloudHub: Attempted deployment
echo.
echo 3. Agent Broker MCP Server
echo    - Artifact ID: employee-onboarding-agent-broker
echo    - Exchange: Published
echo    - CloudHub: Attempted deployment
echo.
echo ========================================
echo  Next Steps
echo ========================================
echo.
echo 1. Verify Exchange Publishing:
echo    - Login to Anypoint Platform
echo    - Navigate to Exchange
echo    - Verify all three assets are published
echo    - Check that OpenAPI specifications are included
echo.
echo 2. Configure CloudHub Properties:
echo    - Set Gmail credentials for notification service
echo    - Set database URLs for asset allocation service
echo    - Set MCP service endpoints for agent broker
echo.
echo 3. Test Deployments:
echo    - Run health checks on all deployed services
echo    - Test MCP tool endpoints
echo    - Verify service integration
echo.
echo Deployment and publishing process completed!
echo.
pause
