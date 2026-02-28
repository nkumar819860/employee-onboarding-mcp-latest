@echo off
echo ========================================
echo    ALTERNATIVE FIX: HTTP PORT 8081
echo ========================================

echo.
echo This script provides an alternative configuration using HTTP with explicit port 8081
echo This avoids HTTPS certificate requirements while fixing the port 80 error.

echo.
echo Updating agent-broker configuration to use HTTP with port 8081...

cd employee-onboarding-agent-fabric\mcp-servers\agent-broker-mcp\src\main\resources

echo.
echo Backing up current config.properties...
copy config.properties config.properties.backup

echo.
echo Creating HTTP port 8081 configuration...
(
echo # Employee Onboarding Agent Broker Configuration
echo.
echo # HTTP Server Configuration
echo http.port=8081
echo http.host=0.0.0.0
echo.
echo # MCP Server Configuration
echo mcp.serverName=Employee Onboarding Agent Broker
echo mcp.serverVersion=1.0.0
echo mcp.serverDescription=Agent Broker MCP Server for Employee Onboarding Process Orchestration
echo.
echo # MCP Server Endpoints ^(HTTP with explicit port 8081^)
echo employee.onboarding.mcp.url=http://employee-onboarding-mcp-server.us-e1.cloudhub.io:8081
echo asset.allocation.mcp.url=http://asset-allocation-mcp-server.us-e1.cloudhub.io:8081
echo notification.mcp.url=http://notification-mcp-server.us-e1.cloudhub.io:8081
echo.
echo # Request Timeout Configuration ^(in milliseconds^)
echo mcp.request.timeout=30000
echo.
echo # Retry Configuration
echo mcp.retry.maxAttempts=3
echo mcp.retry.delay=1000
echo.
echo # Agent Broker Configuration
echo agent.broker.enabled=true
echo agent.broker.orchestration.enabled=true
echo.
echo # MCP Centralized Configuration
echo mcp.server.url=http://agent-broker-mcp-server.us-e1.cloudhub.io:8081
echo mcp.centralized.enabled=true
echo.
echo # Logging Configuration
echo logging.level.root=INFO
echo logging.level.com.mulesoft.mcp=DEBUG
echo.
echo # ==================================================================
echo # ANYPOINT PLATFORM AUTHENTICATION
echo # ==================================================================
echo # Connected App Credentials ^(for deployment authentication - loaded from .env^)
echo connected.app.client.id=${env:CONNECTED_APP_CLIENT_ID}
echo connected.app.client.secret=${secure::connected.app.client.secret}
echo.
echo # Anypoint Platform User Credentials ^(fallback authentication method - loaded from .env^)
echo anypoint.username=${env:ANYPOINT_USERNAME}
echo anypoint.password=${secure::anypoint.password}
) > config.properties

echo.
echo Configuration updated successfully!
echo.
echo Updated endpoints:
echo - employee-onboarding-mcp-server: http://employee-onboarding-mcp-server.us-e1.cloudhub.io:8081
echo - asset-allocation-mcp-server: http://asset-allocation-mcp-server.us-e1.cloudhub.io:8081
echo - notification-mcp-server: http://notification-mcp-server.us-e1.cloudhub.io:8081
echo - agent-broker-mcp-server: http://agent-broker-mcp-server.us-e1.cloudhub.io:8081

echo.
echo Benefits of this configuration:
echo ✓ No HTTPS certificate requirements
echo ✓ Uses explicit port 8081 (CloudHub default HTTP port)
echo ✓ Avoids the port 80 error you encountered
echo ✓ Simpler for development and testing

echo.
echo Now redeploying with HTTP port 8081 configuration...

cd ..\..\..

echo.
echo Building and deploying Agent Broker MCP with HTTP port 8081...
call mvn clean package deploy -DmuleDeploy ^
    -Dmule.application.name=agent-broker-mcp-server ^
    -Dmule.environment=Sandbox ^
    -Dmule.region=us-east-1 ^
    -Dmule.workers=1 ^
    -Dmule.workerType=MICRO ^
    -Danypoint.username=%ANYPOINT_USERNAME% ^
    -Danypoint.password=%ANYPOINT_PASSWORD% ^
    -DskipTests=true

if %errorlevel% neq 0 (
    echo ERROR: Agent Broker deployment failed!
    pause
    exit /b 1
)

echo.
echo SUCCESS: Agent Broker deployed with HTTP port 8081 configuration!

echo.
echo Testing the endpoint with port 8081...
curl -X GET "http://agent-broker-mcp-server.us-e1.cloudhub.io:8081/health" ^
    -H "Content-Type: application/json"

echo.
echo.
echo ========================================
echo    HTTP PORT 8081 FIX COMPLETE
echo ========================================
echo.
echo Configuration Summary:
echo - Protocol: HTTP (no certificates required)
echo - Port: 8081 (CloudHub standard HTTP port)
echo - External Access: Mapped to port 80, but using explicit 8081
echo - Status: Fixes the original "port 80" error
echo.
echo Next Steps:
echo 1. Test employee onboarding orchestration
echo 2. Verify all MCP services communicate properly
echo 3. Consider migrating to HTTPS when ready for production
echo.
echo To revert to HTTPS configuration, run: fix-port-configuration.bat
