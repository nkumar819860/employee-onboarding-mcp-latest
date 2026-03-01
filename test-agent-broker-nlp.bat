@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   MCP Agent Broker NLP Testing Suite
echo ==========================================
echo.

REM Set the Agent Broker MCP Server URL (CloudHub uses standard HTTPS port 443)
set "AGENT_BROKER_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io"
set "LOCAL_AGENT_BROKER_URL=http://localhost:8084"

echo Testing Agent Broker MCP Server with NLP-style requests...
echo.

REM Colors for output (ANSI codes for modern Windows Terminal/cmd)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

REM Test 1: Health Check (Basic connectivity test)
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 1: System Health Check%RESET%
echo %BLUE%========================================%RESET%
echo Testing MCP server connectivity...
echo.

curl -s -X GET "%AGENT_BROKER_URL%/api/health" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -w "HTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30 ^
     -o nul

if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%CloudHub endpoint not reachable, trying local endpoint...%RESET%
    curl -s -X GET "%LOCAL_AGENT_BROKER_URL%/api/health" ^
         -H "Content-Type: application/json" ^
         -H "User-Agent: NLP-Agent-Test/1.0" ^
         -w "HTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
         --max-time 10 ^
         -o nul
    set "AGENT_BROKER_URL=%LOCAL_AGENT_BROKER_URL%"
)

echo.
echo %GREEN%✓ Health check completed.%RESET%
echo.

REM Test 2: MCP Server Info
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 2: MCP Server Capabilities%RESET%
echo %BLUE%========================================%RESET%
echo Retrieving MCP server information and available tools...
echo.

curl -s -X GET "%AGENT_BROKER_URL%/api/mcp/info" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -w "\n\nHTTP Status: %%{http_code}\n" ^
     --max-time 30

echo.
echo %GREEN%✓ MCP server info retrieved.%RESET%
echo.

REM Test 3: NLP-style Employee Onboarding Request
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 3: NLP Employee Onboarding%RESET%
echo %BLUE%========================================%RESET%
echo Simulating NLP request: "Create new employee Alice Johnson with MCP orchestration"
echo.

REM Create JSON payload for employee onboarding
set "EMPLOYEE_JSON={"firstName":"Alice","lastName":"Johnson","email":"alice.johnson@techcorp.com","phone":"+1-555-0123","department":"Engineering","position":"Senior Software Developer","startDate":"2024-03-15","salary":95000,"manager":"Bob Smith","managerEmail":"bob.smith@techcorp.com","companyName":"TechCorp Solutions","assets":["laptop","monitor","id-card"]}"

echo Payload: !EMPLOYEE_JSON!
echo.

curl -s -X POST "%AGENT_BROKER_URL%/api/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: CREATE_EXPECTED"
     -H "X-NLP-Entities: PERSON:Alice Johnson" ^
     -H "X-NLP-Confidence: 0.95" ^
     -d "!EMPLOYEE_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 60

echo.
echo %GREEN%✓ Employee onboarding test completed.%RESET%
echo.

REM Test 4: NLP-style Status Check
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 4: NLP Status Check%RESET%
echo %BLUE%========================================%RESET%
echo Simulating NLP request: "Check employee onboarding status for EMP001"
echo.

set "STATUS_JSON={"employeeId":"EMP001"}"

curl -s -X POST "%AGENT_BROKER_URL%/api/mcp/tools/get-onboarding-status" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: GET_EMPLOYEE_STATUS" ^
     -H "X-NLP-Entities: EMPLOYEE_ID:EMP001" ^
     -H "X-NLP-Confidence: 0.90" ^
     -d "!STATUS_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30

echo.
echo %GREEN%✓ Status check test completed.%RESET%
echo.

REM Test 5: NLP-style Retry Failed Step
echo %BLUE
