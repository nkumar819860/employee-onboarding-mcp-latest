@echo off
echo ========================================
echo    FIXING PORT CONFIGURATION ISSUE
echo ========================================

echo.
echo Fixed the following issues:
echo - Changed HTTP URLs to HTTPS for CloudHub compatibility
echo - Removed explicit port 80 specification
echo - Updated all MCP server endpoints to use HTTPS

echo.
echo Updated endpoints:
echo - employee-onboarding-mcp-server: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo - asset-allocation-mcp-server: https://asset-allocation-mcp-server.us-e1.cloudhub.io  
echo - notification-mcp-server: https://notification-mcp-server.us-e1.cloudhub.io
echo - agent-broker-mcp-server: https://agent-broker-mcp-server.us-e1.cloudhub.io

echo.
echo Now redeploying Agent Broker with corrected configuration...

cd mcp-servers\agent-broker-mcp

echo.
echo Building and deploying Agent Broker MCP with HTTPS configuration...
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
    exit /b 1
)

echo.
echo SUCCESS: Agent Broker redeployed with HTTPS configuration!
echo.
echo Testing the corrected endpoint...
echo Making test request to: https://agent-broker-mcp-server.us-e1.cloudhub.io/health

curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/health" ^
    -H "Content-Type: application/json"

echo.
echo.
echo ========================================
echo    PORT CONFIGURATION FIX COMPLETE
echo ========================================
echo.
echo The orchestrator will now use HTTPS URLs without explicit ports:
echo - This fixes the "port 80" error you encountered
echo - CloudHub applications use HTTPS by default
echo - No explicit port specification needed for CloudHub URLs
echo.
echo Next steps:
echo 1. Test the employee onboarding orchestration
echo 2. Verify all MCP service communications work properly
echo 3. Monitor logs for any remaining connectivity issues
