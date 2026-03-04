@echo off
echo ========================================
echo Testing Assets Allocation MCP Server
echo Script-Based Database Initialization
echo ========================================

echo.
echo 1. Testing Health Check Endpoint...
curl -X GET "http://localhost:8082/api/health" -H "Content-Type: application/json" || echo Failed to connect to health endpoint

echo.
echo 2. Testing MCP Server Info...
curl -X GET "http://localhost:8082/api/mcp/info" -H "Content-Type: application/json" || echo Failed to connect to info endpoint

echo.
echo 3. Testing Asset Allocation (Script-based DB initialization should trigger)...
curl -X POST "http://localhost:8082/api/mcp/tools/allocate-assets" ^
  -H "Content-Type: application/json" ^
  -d "{\"employeeId\": \"TEST001\", \"firstName\": \"Test\", \"lastName\": \"Employee\", \"department\": \"IT\", \"position\": \"Developer\", \"assets\": [\"laptop\", \"id-card\"]}" || echo Failed to allocate assets

echo.
echo 4. Testing List Assets (should show script-initialized data)...
curl -X GET "http://localhost:8082/api/mcp/tools/list-assets" -H "Content-Type: application/json" || echo Failed to list assets

echo.
echo 5. Testing Get Available Assets...
curl -X GET "http://localhost:8082/api/mcp/tools/get-available-assets" -H "Content-Type: application/json" || echo Failed to get available assets

echo.
echo ========================================
echo Script-Based Initialization Test Complete
echo ========================================
echo.
echo Expected Results:
echo - Health check should return HEALTHY status
echo - Asset allocation should use H2 with script-based initialization
echo - List assets should show categories: LAPTOP, ID_CARD, MOBILE_PHONE, MONITOR, HEADSET, etc.
echo - Database initialization should show completion marker: _SCRIPT_INIT_COMPLETE_
echo - Allocated assets should have detailed specifications from script
echo.
pause
