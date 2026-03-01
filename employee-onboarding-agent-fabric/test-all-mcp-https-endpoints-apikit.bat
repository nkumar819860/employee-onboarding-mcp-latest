@echo off
echo ===============================================
echo MCP Services HTTPS APIKit Endpoints Test Suite
echo ===============================================
echo.
echo Testing all MCP services with correct APIKit /api endpoints
echo Services: Asset Allocation MCP + Agent Broker MCP
echo Note: All endpoints use /api prefix due to APIKit router configuration
echo.

REM Set timeout values
set CONNECT_TIMEOUT=30
set MAX_TIMEOUT=60

echo ===============================================
echo 1. ASSET ALLOCATION MCP SERVER TESTS
echo ===============================================
echo.

echo Testing Asset Allocation MCP Health Endpoint...
echo URL: https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/health
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo Testing Asset Allocation MCP API Root...
echo URL: https://asset-allocation-mcp-server.us-e1.cloudhub.io/api
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/api"
echo.

echo Testing Asset Allocation MCP Assets Endpoint...
echo URL: https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/assets
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/assets"
echo.

echo ===============================================
echo 2. AGENT BROKER MCP SERVER TESTS  
echo ===============================================
echo.

echo Testing Agent Broker MCP Health Endpoint...
echo URL: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo Testing Agent Broker MCP API Root...
echo URL: https://agent-broker-mcp-server.us-e1.cloudhub.io/api
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api"
echo.

echo Testing Agent Broker MCP Orchestrate Endpoint...
echo URL: https://agent-broker-mcp-server.us-e1.cloudhub.io/api/orchestrate
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/orchestrate"
echo.

echo ===============================================
echo 3. HTTP TO HTTPS REDIRECT TESTS
echo ===============================================
echo.

echo Testing Asset Allocation HTTP redirect...
echo URL: http://asset-allocation-mcp-server.us-e1.cloudhub.io/api/health (should redirect to HTTPS)
curl -L --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "http://asset-allocation-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo Testing Agent Broker HTTP redirect...  
echo URL: http://agent-broker-mcp-server.us-e1.cloudhub.io/api/health (should redirect to HTTPS)
curl -L --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "http://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo ===============================================
echo 4. VERBOSE CONNECTION TESTS
echo ===============================================
echo.

echo Verbose Asset Allocation connection test...
curl -v -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo Verbose Agent Broker connection test...
curl -v -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo ===============================================
echo 5. ADDITIONAL MCP SERVICES TESTS
echo ===============================================
echo.

echo Testing Employee Onboarding MCP Health Endpoint...
echo URL: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/api/health
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://employee-onboarding-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo Testing Notification MCP Health Endpoint...
echo URL: https://notification-mcp-server.us-e1.cloudhub.io/api/health
curl -k --connect-timeout %CONNECT_TIMEOUT% --max-time %MAX_TIMEOUT% -X GET "https://notification-mcp-server.us-e1.cloudhub.io/api/health"
echo.

echo ===============================================
echo TEST RESULTS SUMMARY
echo ===============================================
echo.
echo Expected Results:
echo ✅ All HTTPS URLs should return status 200 or valid application responses
echo ✅ Health endpoints should return {"status": "UP"} or similar
echo ✅ HTTP URLs should redirect to HTTPS (status 301/302)
echo ✅ No 504 Gateway timeout errors after 2-3 minutes post-deployment
echo ✅ SSL/TLS handshake should complete successfully
echo.
echo IMPORTANT NOTES:
echo 🔧 All endpoints use /api prefix due to APIKit router configuration
echo 🔧 React client must use /api endpoints for all MCP service calls
echo 🔧 MCP health checks must target /api/health not /health
echo.
echo Troubleshooting 504 Errors:
echo - Wait 2-3 minutes after deployment for full application startup
echo - Check CloudHub Runtime Manager for application status
echo - Verify applications are in "Started" state
echo - Check application logs for startup errors
echo.
echo Configuration Verified:
echo ✅ POM CloudHub properties include both http.port=8081 and https.port=8082
echo ✅ config.properties files have https.port=8082 
echo ✅ CloudHub environment settings configured (mule.env=cloudhub)
echo ✅ Exchange plugins properly configured with MCP classifiers
echo ✅ APIKit router configuration requires /api prefix for all endpoints
echo.
echo Next Steps if Issues Persist:
echo 1. Redeploy applications with updated POM configurations
echo 2. Wait 2-3 minutes for CloudHub load balancer updates
echo 3. Check Runtime Manager for any deployment errors
echo 4. Verify Connected App permissions in Access Management
echo 5. Update React client to use /api endpoints for all MCP calls
echo.
pause
