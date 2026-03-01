@echo off
echo ========================================
echo Testing React Client API Fix
echo ========================================
echo.

echo Testing the exact same payload that works in Postman...
echo URL: http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo.

curl -X POST "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding" ^
-H "Content-Type: application/json" ^
-H "X-MCP-Client: React-Employee-Onboarding" ^
-d "{\"firstName\":\"John\",\"lastName\":\"Smith\",\"email\":\"john.smith@company.com\",\"department\":\"Engineering\",\"position\":\"Senior Software Engineer\",\"startDate\":\"2024-01-15\",\"manager\":\"Sarah Johnson\",\"managerName\":\"Sarah Johnson\",\"managerEmail\":\"sarah.johnson@company.com\",\"orientationDate\":\"2024-01-16\",\"companyName\":\"TechCorp Inc\",\"assets\":[{\"assetTag\":\"LAPTOP-001\",\"category\":\"LAPTOP\",\"priority\":\"HIGH\"}]}"

echo.
echo ========================================
echo Test completed. 
echo The React client should now send the same payload structure!
echo ========================================
pause
