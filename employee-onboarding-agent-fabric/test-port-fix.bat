@echo off
echo ========================================
echo    TESTING PORT CONFIGURATION FIX
echo ========================================

echo.
echo Testing HTTPS endpoints for all MCP servers...

echo.
echo 1. Testing Employee Onboarding MCP Server...
curl -X GET "https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health" ^
    -H "Content-Type: application/json" ^
    -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n"

echo.
echo 2. Testing Asset Allocation MCP Server...
curl -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/health" ^
    -H "Content-Type: application/json" ^
    -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n"

echo.
echo 3. Testing Notification MCP Server...
curl -X GET "https://notification-mcp-server.us-e1.cloudhub.io/health" ^
    -H "Content-Type: application/json" ^
    -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n"

echo.
echo 4. Testing Agent Broker MCP Server...
curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/health" ^
    -H "Content-Type: application/json" ^
    -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n"

echo.
echo ========================================
echo    TESTING EMPLOYEE ONBOARDING FLOW
echo ========================================

echo.
echo Testing the complete employee onboarding orchestration...
echo This will test if the agent-broker can now properly communicate with the notification service using HTTPS.

curl -X POST "https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding" ^
    -H "Content-Type: application/json" ^
    -d "{\"firstName\":\"Test\",\"lastName\":\"Employee\",\"email\":\"test.employee@company.com\",\"phone\":\"123-456-7890\",\"department\":\"IT\",\"position\":\"Developer\",\"startDate\":\"2024-03-01\",\"salary\":75000,\"manager\":\"John Smith\",\"managerEmail\":\"john.smith@company.com\",\"companyName\":\"Test Company\",\"assets\":[\"laptop\",\"phone\",\"id-card\"]}" ^
    -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n"

echo.
echo.
echo ========================================
echo    CONFIGURATION FIX SUMMARY
echo ========================================
echo.
echo Fixed Issues:
echo ✓ Changed HTTP to HTTPS for all MCP server URLs
echo ✓ Removed explicit port 80 specification 
echo ✓ CloudHub applications now use default HTTPS (port 443)
echo ✓ No more "port 80" internal server errors
echo.
echo Updated Configuration:
echo - employee.onboarding.mcp.url=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo - asset.allocation.mcp.url=https://asset-allocation-mcp-server.us-e1.cloudhub.io
echo - notification.mcp.url=https://notification-mcp-server.us-e1.cloudhub.io
echo - mcp.server.url=https://agent-broker-mcp-server.us-e1.cloudhub.io
echo.
echo If all tests above show HTTP Status: 200, the port configuration fix was successful!
