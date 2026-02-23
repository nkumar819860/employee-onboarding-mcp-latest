@echo off
echo.
echo ======================================
echo CloudHub Deployment End-to-End Testing
echo ======================================
echo.

REM Define CloudHub URLs
set EMPLOYEE_SERVICE=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
set ASSET_SERVICE=https://asset-allocation-mcp-server.us-e1.cloudhub.io
set NOTIFICATION_SERVICE=https://notification-mcp-server.us-e1.cloudhub.io
set AGENT_BROKER=https://employee-onboarding-agent-broker.us-e1.cloudhub.io

echo Testing CloudHub deployed services...
echo.

echo 1. Testing Employee Onboarding MCP Server...
curl -f -s -o nul "%EMPLOYEE_SERVICE%/health" && echo ✓ Employee Service is UP || echo ✗ Employee Service is DOWN
curl -f -s -o nul "%EMPLOYEE_SERVICE%/api/console" && echo ✓ Employee API Console accessible || echo ✗ Employee API Console not accessible

echo.
echo 2. Testing Asset Allocation MCP Server...
curl -f -s -o nul "%ASSET_SERVICE%/health" && echo ✓ Asset Service is UP || echo ✗ Asset Service is DOWN
curl -f -s -o nul "%ASSET_SERVICE%/api/console" && echo ✓ Asset API Console accessible || echo ✗ Asset API Console not accessible

echo.
echo 3. Testing Notification MCP Server...
curl -f -s -o nul "%NOTIFICATION_SERVICE%/health" && echo ✓ Notification Service is UP || echo ✗ Notification Service is DOWN
curl -f -s -o nul "%NOTIFICATION_SERVICE%/api/console" && echo ✓ Notification API Console accessible || echo ✗ Notification API Console not accessible

echo.
echo 4. Testing Agent Broker MCP Server...
curl -f -s -o nul "%AGENT_BROKER%/health" && echo ✓ Agent Broker is UP || echo ✗ Agent Broker is DOWN
curl -f -s -o nul "%AGENT_BROKER%/api/console" && echo ✓ Agent Broker API Console accessible || echo ✗ Agent Broker API Console not accessible

echo.
echo ======================================
echo End-to-End Functional Testing
echo ======================================
echo.

echo Testing complete employee onboarding workflow...

REM Test 1: Create Employee Profile
echo.
echo Test 1: Creating employee profile...
curl -X POST "%EMPLOYEE_SERVICE%/employees" ^
  -H "Content-Type: application/json" ^
  -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@company.com\",\"phone\":\"555-1234\",\"department\":\"Engineering\",\"position\":\"Software Developer\",\"startDate\":\"2024-03-01\",\"salary\":75000}" ^
  -w "HTTP Status: %%{http_code}\n" ^
  -s -o employee_response.json

if exist employee_response.json (
    echo ✓ Employee creation request sent
    type employee_response.json
    del employee_response.json
) else (
    echo ✗ Employee creation failed
)

echo.
echo Test 2: Testing asset allocation...
curl -X POST "%ASSET_SERVICE%/allocate" ^
  -H "Content-Type: application/json" ^
  -d "{\"employeeId\":\"EMP001\",\"assets\":[\"laptop\",\"id-card\",\"phone\"]}" ^
  -w "HTTP Status: %%{http_code}\n" ^
  -s -o asset_response.json

if exist asset_response.json (
    echo ✓ Asset allocation request sent
    type asset_response.json
    del asset_response.json
) else (
    echo ✗ Asset allocation failed
)

echo.
echo Test 3: Testing notification service...
curl -X POST "%NOTIFICATION_SERVICE%/send-welcome-email" ^
  -H "Content-Type: application/json" ^
  -d "{\"employeeEmail\":\"john.doe@company.com\",\"employeeName\":\"John Doe\",\"managerName\":\"Jane Smith\",\"startDate\":\"2024-03-01\"}" ^
  -w "HTTP Status: %%{http_code}\n" ^
  -s -o notification_response.json

if exist notification_response.json (
    echo ✓ Notification request sent
    type notification_response.json
    del notification_response.json
) else (
    echo ✗ Notification failed
)

echo.
echo Test 4: Testing complete onboarding workflow via Agent Broker...
curl -X POST "%AGENT_BROKER%/onboard-employee" ^
  -H "Content-Type: application/json" ^
  -d "{\"firstName\":\"Alice\",\"lastName\":\"Johnson\",\"email\":\"alice.johnson@company.com\",\"phone\":\"555-5678\",\"department\":\"Marketing\",\"position\":\"Marketing Manager\",\"startDate\":\"2024-03-15\",\"salary\":85000,\"manager\":\"Bob Wilson\",\"managerEmail\":\"bob.wilson@company.com\",\"assets\":[\"laptop\",\"id-card\"]}" ^
  -w "HTTP Status: %%{http_code}\n" ^
  -s -o workflow_response.json

if exist workflow_response.json (
    echo ✓ Complete onboarding workflow request sent
    type workflow_response.json
    del workflow_response.json
) else (
    echo ✗ Complete onboarding workflow failed
)

echo.
echo ======================================
echo Testing Summary
echo ======================================
echo.
echo All CloudHub services have been tested for:
echo - Health check endpoints
echo - API console accessibility
echo - Individual service functionality
echo - Complete end-to-end workflow
echo.
echo Check the HTTP status codes above:
echo - 200: Success
echo - 404: Endpoint not found (may need configuration)
echo - 500: Internal server error
echo - Connection failed: Service not accessible
echo.
echo Visit the CloudHub console to check application logs:
echo https://anypoint.mulesoft.com/cloudhub/
echo.
pause
