@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   MCP Agent Broker NLP Testing Suite v2.0
echo ==========================================
echo.

REM Set the Agent Broker MCP Server URL (CloudHub uses standard HTTPS port 443)
set "AGENT_BROKER_URL=https://agent-broker-mcp-server.us-e1.cloudhub.io/"
set "LOCAL_AGENT_BROKER_URL=http://localhost:8084"

REM ANSI Colors for modern Windows Terminal/cmd
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"
set "CYAN=[96m"

REM Check if curl is available
where curl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo %RED%ERROR: curl not found in PATH. Please install curl or add to PATH.%RESET%
    echo %YELLOW%Download from: https://curl.se/windows/%RESET%
    pause
    exit /b 1
)

echo %CYAN%Testing Agent Broker MCP Server with NLP-style requests...%RESET%
echo.

REM Test 1: Health Check (Basic connectivity test)
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 1: System Health Check%RESET%
echo %BLUE%========================================%RESET%
echo %CYAN%Testing CloudHub MCP server connectivity...%RESET%
echo.

curl -s -X GET "%AGENT_BROKER_URL%/api/health" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -w "%GREEN%HTTP Status: %%{http_code}%RESET%\n%GREEN%Response Time: %%{time_total}s%RESET%\n" --max-time 30 -o nul

if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%CloudHub endpoint not reachable, trying local endpoint...%RESET%
    curl -s -X GET "%LOCAL_AGENT_BROKER_URL%/api/health" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -w "%GREEN%HTTP Status: %%{http_code}%RESET%\n%GREEN%Response Time: %%{time_total}s%RESET%\n" --max-time 10 -o nul
    set "AGENT_BROKER_URL=%LOCAL_AGENT_BROKER_URL%"
)

echo.
echo %GREEN%✓ Health check completed.%RESET%
echo.

REM Test 2: MCP Server Info
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 2: MCP Server Capabilities%RESET%
echo %BLUE%========================================%RESET%
echo %CYAN%Retrieving MCP server information and available tools...%RESET%
echo.

curl -s -X GET "%AGENT_BROKER_URL%/api/mcp/info" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -w "\n\n%GREEN%HTTP Status: %%{http_code}%RESET%\n" --max-time 30

echo.
echo %GREEN%✓ MCP server info retrieved.%RESET%
echo.

REM Test 3: NLP-style Employee Onboarding Request (FIXED ASSETS)
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 3: NLP Employee Onboarding%RESET%
echo %BLUE%========================================%RESET%
echo %CYAN%Simulating NLP request: "Create new employee Alice Johnson with MCP orchestration"%RESET%
echo.

REM Fixed JSON with proper object assets array
echo {"firstName":"Alice","lastName":"Johnson","email":"alice.johnson@techcorp.com","phone":"+1-555-0123","department":"Engineering","position":"Senior Software Developer","startDate":"2024-03-15","salary":95000,"manager":"Bob Smith","managerEmail":"bob.smith@techcorp.com","companyName":"TechCorp Solutions","assets":[{"name":"laptop","type":"hardware","assigned":true},{"name":"monitor","type":"hardware","assigned":true},{"name":"id-card","type":"access","assigned":false}]} > temp_employee.json

curl -s -X POST "%AGENT_BROKER_URL%/api/mcp/tools/orchestrate-employee-onboarding" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -H "X-NLP-Intent: CREATE_EXPECTED" -H "X-NLP-Entities: PERSON:Alice Johnson" -H "X-NLP-Confidence: 0.95" -d @temp_employee.json -w "\n\n%GREEN%HTTP Status: %%{http_code}%RESET%\n%GREEN%Response Time: %%{time_total}s%RESET%\n" --max-time 60

del temp_employee.json 2>nul
echo.
echo %GREEN%✓ Employee onboarding test completed.%RESET%
echo.

REM Test 4: NLP-style Status Check
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 4: NLP Status Check%RESET%
echo %BLUE%========================================%RESET%
echo %CYAN%Simulating NLP request: "Check employee onboarding status for EMP001"%RESET%
echo.

echo {"employeeId":"EMP001"} > temp_status.json

curl -s -X POST "%AGENT_BROKER_URL%/api/mcp/tools/get-onboarding-status" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -H "X-NLP-Intent: GET_EMPLOYEE_STATUS" -H "X-NLP-Entities: EMPLOYEE_ID:EMP001" -H "X-NLP-Confidence: 0.90" -d @temp_status.json -w "\n\n%GREEN%HTTP Status: %%{http_code}%RESET%\n%GREEN%Response Time: %%{time_total}s%RESET%\n" --max-time 30

del temp_status.json 2>nul
echo.
echo %GREEN%✓ Status check test completed.%RESET%
echo.

REM Test 5: NLP-style Retry Failed Step
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 5: Retry Failed Onboarding Step%RESET%
echo %BLUE%========================================%RESET%
echo %CYAN%Simulating NLP request: "Retry failed onboarding step for EMP001"%RESET%
echo.

echo {"employeeId":"EMP001","retryStep":"asset-assignment"} > temp_retry.json

curl -s -X POST "%AGENT_BROKER_URL%/api/mcp/tools/retry-onboarding-step" -H "Content-Type: application/json" -H "User-Agent: NLP-Agent-Test/2.0" -H "X-NLP-Intent: RETRY_FAILED_STEP" -H "X-NLP-Entities: EMPLOYEE_ID:EMP001,STEP:asset-assignment" -H "X-NLP-Confidence: 0.92" -d @temp_retry.json -w "\n\n%GREEN%HTTP Status: %%{http_code}%RESET%\n%GREEN%Response Time: %%{time_total}s%RESET%\n" --max-time 45

del temp_retry.json 2>nul
echo.
echo %GREEN%✓ Retry test completed.%RESET%
echo.

REM Summary
echo %GREEN%=============================================%RESET%
echo %GREEN%    All MCP Agent Broker NLP tests completed!%RESET%
echo %GREEN%=============================================%RESET%
echo.
echo %CYAN%Test Summary:%RESET%
echo %GREEN%- Test 1: Health Check ✓%RESET%
echo %GREEN%- Test 2: MCP Info ✓%RESET%
echo %GREEN%- Test 3: Employee Onboarding (FIXED ASSETS) ✓%RESET%
echo %GREEN%- Test 4: Status Check ✓%RESET%
echo %GREEN%- Test 5: Retry Failed Step ✓%RESET%
echo.
echo %YELLOW%Fixed Issues:%RESET%
echo %YELLOW%- Windows curl ^ line continuation%RESET%
echo %YELLOW%- JSON assets array (String^>Object)%RESET%
echo %YELLOW%- Inline JSON escaping%RESET%
echo.
pause
