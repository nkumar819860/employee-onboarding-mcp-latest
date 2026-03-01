@echo off
echo ======================================
echo Agent Broker 504 Error Diagnostic Tool
echo ======================================
echo.
echo This script will help diagnose the 504 Gateway Timeout error
echo on https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health
echo.

echo Step 1: Testing basic connectivity to CloudHub application...
echo.
curl -v -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 2: Testing the health endpoint with verbose output...
echo.
curl -v -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 3: Testing without the /api prefix (direct endpoint)...
echo.
curl -v -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/health" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 4: Testing MCP info endpoint...
echo.
curl -v -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 5: Testing with HTTP instead of HTTPS...
echo.
curl -v -X GET "http://agent-broker-mcp-server.us-e1.cloudhub.io/api/health" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 6: Testing CloudHub management console endpoint...
echo.
curl -v -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/console" --connect-timeout 30
echo.
echo ----------------------------------------
echo.

echo Step 7: DNS Resolution Test...
echo.
nslookup agent-broker-mcp-server.us-e1.cloudhub.io
echo.
echo ----------------------------------------
echo.

echo DIAGNOSTIC COMPLETE!
echo.
echo ANALYSIS:
echo - If Step 1 fails: CloudHub application is not deployed or not running
echo - If Step 1 works but Step 2 fails: APIKit routing issue (path mismatch)
echo - If Step 3 works but Step 2 fails: /api prefix configuration issue
echo - If Step 5 works but HTTPS fails: HTTPS listener configuration issue
echo - If all fail: Network/DNS issue or application completely down
echo.
echo Next steps based on results:
echo 1. If application is down: Redeploy using fix-agent-broker-deployment.bat
echo 2. If routing issue: Check global.xml HTTP listener configuration
echo 3. If HTTPS issue: Verify port 8082 configuration in config.properties
echo.
pause
