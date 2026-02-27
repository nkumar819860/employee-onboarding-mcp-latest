@echo off
echo ============================================
echo MCP SERVICES HEALTH CHECK SCRIPT
echo ============================================
echo.
echo Testing health endpoints for all MCP services...
echo Timestamp: %date% %time%
echo.

REM Set default ports for local testing
set AGENT_BROKER_PORT=8081
set ASSET_ALLOCATION_PORT=8082
set EMPLOYEE_ONBOARDING_PORT=8083
set NOTIFICATION_PORT=8084

REM Check if running on CloudHub (production URLs)
if "%TEST_MODE%"=="CLOUDHUB" (
    echo Testing CloudHub deployed services...
    set AGENT_BROKER_URL=https://agent-broker-mcp-server.us-e2.cloudhub.io
    set ASSET_ALLOCATION_URL=https://asset-allocation-mcp-server.us-e2.cloudhub.io
    set EMPLOYEE_ONBOARDING_URL=https://employee-onboarding-mcp-server.us-e2.cloudhub.io
    set NOTIFICATION_URL=https://notification-mcp-server.us-e2.cloudhub.io
) else (
    echo Testing local deployed services...
    set AGENT_BROKER_URL=http://localhost:%AGENT_BROKER_PORT%
    set ASSET_ALLOCATION_URL=http://localhost:%ASSET_ALLOCATION_PORT%
    set EMPLOYEE_ONBOARDING_URL=http://localhost:%EMPLOYEE_ONBOARDING_PORT%
    set NOTIFICATION_URL=http://localhost:%NOTIFICATION_PORT%
)

echo.
echo ============================================
echo 1. AGENT BROKER MCP SERVICE HEALTH CHECK
echo ============================================
echo Testing: %AGENT_BROKER_URL%/health
curl -s -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" %AGENT_BROKER_URL%/health || echo ERROR: Agent Broker service unreachable
echo.

echo ============================================
echo 2. ASSET ALLOCATION MCP SERVICE HEALTH CHECK  
echo ============================================
echo Testing: %ASSET_ALLOCATION_URL%/health
curl -s -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" %ASSET_ALLOCATION_URL%/health || echo ERROR: Asset Allocation service unreachable
echo.

echo ============================================
echo 3. EMPLOYEE ONBOARDING MCP SERVICE HEALTH CHECK
echo ============================================
echo Testing: %EMPLOYEE_ONBOARDING_URL%/health  
curl -s -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" %EMPLOYEE_ONBOARDING_URL%/health || echo ERROR: Employee Onboarding service unreachable
echo.

echo ============================================
echo 4. NOTIFICATION MCP SERVICE HEALTH CHECK
echo ============================================
echo Testing: %NOTIFICATION_URL%/health
curl -s -w "\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" %NOTIFICATION_URL%/health || echo ERROR: Notification service unreachable
echo.

echo ============================================
echo MCP SERVICE INFO ENDPOINTS TEST
echo ============================================
echo.

echo Testing Agent Broker MCP Info...
echo URL: %AGENT_BROKER_URL%/mcp/info
curl -s %AGENT_BROKER_URL%/mcp/info | python -m json.tool 2>nul || echo Service info unavailable
echo.

echo Testing Asset Allocation MCP Info...
echo URL: %ASSET_ALLOCATION_URL%/mcp/info
curl -s %ASSET_ALLOCATION_URL%/mcp/info | python -m json.tool 2>nul || echo Service info unavailable
echo.

echo Testing Employee Onboarding MCP Info...
echo URL: %EMPLOYEE_ONBOARDING_URL%/mcp/info
curl -s %EMPLOYEE_ONBOARDING_URL%/mcp/info | python -m json.tool 2>nul || echo Service info unavailable
echo.

echo Testing Notification MCP Info...
echo URL: %NOTIFICATION_URL%/mcp/info
curl -s %NOTIFICATION_URL%/mcp/info | python -m json.tool 2>nul || echo Service info unavailable
echo.

echo ============================================
echo HEALTH CHECK SUMMARY
echo ============================================
echo.
echo All health endpoints tested. Review the HTTP status codes above:
echo - 200: Service is healthy and running
echo - 404: Endpoint not found (check deployment)
echo - 500: Service error (check logs)
echo - Connection errors: Service not running or unreachable
echo.

REM Test a few key MCP tool endpoints
echo ============================================
echo SAMPLE MCP TOOL ENDPOINT TESTS
echo ============================================
echo.

echo Testing Asset Allocation - Get Available Assets...
curl -s -w "\nHTTP Status: %%{http_code}\n" -X GET %ASSET_ALLOCATION_URL%/mcp/tools/get-available-assets || echo Tool endpoint unavailable
echo.

echo Testing Employee Onboarding - List Employees...  
curl -s -w "\nHTTP Status: %%{http_code}\n" -X GET %EMPLOYEE_ONBOARDING_URL%/mcp/tools/list-employees || echo Tool endpoint unavailable
echo.

echo ============================================
echo HEALTH CHECK COMPLETE
echo ============================================
echo Timestamp: %date% %time%
echo.

REM Usage instructions
echo USAGE INSTRUCTIONS:
echo.
echo For local testing: test-health-checks.bat
echo For CloudHub testing: set TEST_MODE=CLOUDHUB && test-health-checks.bat
echo.
echo You can also test individual services by setting custom URLs:
echo set AGENT_BROKER_URL=https://your-custom-url.com
echo test-health-checks.bat
echo.

pause
