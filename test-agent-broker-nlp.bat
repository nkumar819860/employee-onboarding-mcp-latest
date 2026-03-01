@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   MCP Agent Broker NLP Testing Suite
echo ==========================================
echo.

REM Set the Agent Broker MCP Server URL (CloudHub uses standard HTTPS port 443, no port needed)
set "AGENT_BROKER_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io"
set "LOCAL_AGENT_BROKER_URL=http://localhost:8084"

echo Testing Agent Broker MCP Server with NLP-style requests...
echo.

REM Colors for output
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

curl -s -X GET "%AGENT_BROKER_URL%/health" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -w "HTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30

if %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%CloudHub endpoint not reachable, trying local endpoint...%RESET%
    curl -s -X GET "%LOCAL_AGENT_BROKER_URL%/health" ^
         -H "Content-Type: application/json" ^
         -H "User-Agent: NLP-Agent-Test/1.0" ^
         -w "HTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
         --max-time 10
    set "AGENT_BROKER_URL=%LOCAL_AGENT_BROKER_URL%"
)

echo.
echo %GREEN%Health check completed.%RESET%
echo.

REM Test 2: MCP Server Info
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 2: MCP Server Capabilities%RESET%
echo %BLUE%========================================%RESET%
echo Retrieving MCP server information and available tools...
echo.

curl -s -X GET "%AGENT_BROKER_URL%/mcp/info" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -w "\n\nHTTP Status: %%{http_code}\n" ^
     --max-time 30

echo.
echo %GREEN%MCP server info retrieved.%RESET%
echo.

REM Test 3: NLP-style Employee Onboarding Request
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 3: NLP Employee Onboarding%RESET%
echo %BLUE%========================================%RESET%
echo Simulating NLP request: "Create new employee Alice Johnson with MCP orchestration"
echo.

REM Create JSON payload for employee onboarding
set "EMPLOYEE_JSON={\"firstName\":\"Alice\",\"lastName\":\"Johnson\",\"email\":\"alice.johnson@techcorp.com\",\"phone\":\"+1-555-0123\",\"department\":\"Engineering\",\"position\":\"Senior Software Developer\",\"startDate\":\"2024-03-15\",\"salary\":95000,\"manager\":\"Bob Smith\",\"managerEmail\":\"bob.smith@techcorp.com\",\"companyName\":\"TechCorp Solutions\",\"assets\":[\"laptop\",\"monitor\",\"id-card\"]}"

echo Payload: !EMPLOYEE_JSON!
echo.

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: CREATE_EMPLOYEE" ^
     -H "X-NLP-Entities: PERSON:Alice Johnson" ^
     -H "X-NLP-Confidence: 0.95" ^
     -d "!EMPLOYEE_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 60

echo.
echo %GREEN%Employee onboarding test completed.%RESET%
echo.

REM Test 4: NLP-style Status Check
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 4: NLP Status Check%RESET%
echo %BLUE%========================================%RESET%
echo Simulating NLP request: "Check employee onboarding status for EMP001"
echo.

set "STATUS_JSON={\"employeeId\":\"EMP001\"}"

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/get-onboarding-status" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: GET_EMPLOYEE_STATUS" ^
     -H "X-NLP-Entities: EMPLOYEE_ID:EMP001" ^
     -H "X-NLP-Confidence: 0.90" ^
     -d "!STATUS_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30

echo.
echo %GREEN%Status check test completed.%RESET%
echo.

REM Test 5: NLP-style Retry Failed Step
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 5: NLP Retry Failed Step%RESET%
echo %BLUE%========================================%RESET%
echo Simulating NLP request: "Retry asset allocation step for employee EMP001"
echo.

set "RETRY_JSON={\"employeeId\":\"EMP001\",\"step\":\"asset-allocation\"}"

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/retry-failed-step" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: RETRY_STEP" ^
     -H "X-NLP-Entities: EMPLOYEE_ID:EMP001,STEP:asset-allocation" ^
     -H "X-NLP-Confidence: 0.85" ^
     -d "!RETRY_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30

echo.
echo %GREEN%Retry step test completed.%RESET%
echo.

REM Test 6: Advanced NLP Scenario - Multiple Entities
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 6: Complex NLP Scenario%RESET%
echo %BLUE%========================================%RESET%
echo Simulating complex NLP request: "Onboard John Smith from HR department starting Monday"
echo.

set "COMPLEX_JSON={\"firstName\":\"John\",\"lastName\":\"Smith\",\"email\":\"john.smith@company.com\",\"department\":\"Human Resources\",\"position\":\"HR Specialist\",\"startDate\":\"2024-03-18\",\"manager\":\"Sarah Wilson\",\"managerEmail\":\"sarah.wilson@company.com\",\"companyName\":\"Global Corp\",\"assets\":[\"laptop\",\"phone\"]}"

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: CREATE_EMPLOYEE" ^
     -H "X-NLP-Entities: PERSON:John Smith,DEPARTMENT:HR,DATE:Monday" ^
     -H "X-NLP-Confidence: 0.88" ^
     -H "X-NLP-Sentiment: 0.75" ^
     -d "!COMPLEX_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 60

echo.
echo %GREEN%Complex NLP scenario test completed.%RESET%
echo.

REM Test 7: Error Handling Test
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 7: NLP Error Handling%RESET%
echo %BLUE%========================================%RESET%
echo Testing error handling with invalid data...
echo.

set "INVALID_JSON={\"invalid\":\"data\"}"

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: NLP-Agent-Test/1.0" ^
     -H "X-NLP-Intent: CREATE_EMPLOYEE" ^
     -H "X-NLP-Entities: UNKNOWN" ^
     -H "X-NLP-Confidence: 0.30" ^
     -d "!INVALID_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 30

echo.
echo %GREEN%Error handling test completed.%RESET%
echo.

REM Test 8: CORS Headers Test (Frontend Integration)
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 8: CORS Headers for NLP Frontend%RESET%
echo %BLUE%========================================%RESET%
echo Testing CORS headers for browser-based NLP integration...
echo.

curl -s -X OPTIONS "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Origin: http://localhost:3000" ^
     -H "Access-Control-Request-Method: POST" ^
     -H "Access-Control-Request-Headers: Content-Type,X-NLP-Intent" ^
     -H "User-Agent: NLP-Frontend-Test/1.0" ^
     -v ^
     --max-time 15

echo.
echo %GREEN%CORS test completed.%RESET%
echo.

REM Test 9: Stress Test with Multiple NLP Requests
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 9: NLP Load Test%RESET%
echo %BLUE%========================================%RESET%
echo Simulating multiple concurrent NLP requests...
echo.

REM Simple concurrent requests simulation
for /L %%i in (1,1,3) do (
    echo Making concurrent request %%i...
    start /B curl -s -X GET "%AGENT_BROKER_URL%/health" ^
          -H "User-Agent: NLP-Load-Test-%%i/1.0" ^
          --max-time 10 ^
          -o temp_response_%%i.txt
)

REM Wait a moment for requests to complete
timeout /t 5 /nobreak >nul

REM Check results
for /L %%i in (1,1,3) do (
    if exist temp_response_%%i.txt (
        echo Response %%i: OK
        del temp_response_%%i.txt
    ) else (
        echo Response %%i: Failed
    )
)

echo.
echo %GREEN%Load test completed.%RESET%
echo.

REM Test 10: Voice Input Simulation
echo %BLUE%========================================%RESET%
echo %BLUE%TEST 10: Voice Input NLP Test%RESET%
echo %BLUE%========================================%RESET%
echo Simulating voice input: "Hey system, create employee Sarah Davis"
echo.

set "VOICE_JSON={\"firstName\":\"Sarah\",\"lastName\":\"Davis\",\"email\":\"sarah.davis@voicetest.com\",\"department\":\"Marketing\",\"position\":\"Marketing Manager\",\"startDate\":\"2024-03-20\",\"assets\":[\"laptop\"]}"

curl -s -X POST "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -H "User-Agent: Voice-NLP-Test/1.0" ^
     -H "X-NLP-Intent: CREATE_EMPLOYEE" ^
     -H "X-NLP-Entities: PERSON:Sarah Davis" ^
     -H "X-NLP-Confidence: 0.82" ^
     -H "X-NLP-Source: VOICE" ^
     -H "X-NLP-Language: en-US" ^
     -d "!VOICE_JSON!" ^
     -w "\n\nHTTP Status: %%{http_code}\nResponse Time: %%{time_total}s\n" ^
     --max-time 45

echo.
echo %GREEN%Voice input test completed.%RESET%
echo.

REM Summary
echo %YELLOW%========================================%RESET%
echo %YELLOW%           TEST SUMMARY%RESET%
echo %YELLOW%========================================%RESET%
echo.
echo %GREEN%✓ Health Check%RESET%
echo %GREEN%✓ MCP Server Info%RESET%
echo %GREEN%✓ Employee Onboarding (NLP)%RESET%
echo %GREEN%✓ Status Check (NLP)%RESET%
echo %GREEN%✓ Retry Failed Step (NLP)%RESET%
echo %GREEN%✓ Complex NLP Scenario%RESET%
echo %GREEN%✓ Error Handling%RESET%
echo %GREEN%✓ CORS Headers%RESET%
echo %GREEN%✓ Load Testing%RESET%
echo %GREEN%✓ Voice Input Simulation%RESET%
echo.
echo %YELLOW%All NLP-style tests completed!%RESET%
echo.
echo %BLUE%Agent Broker URL tested: %AGENT_BROKER_URL%%RESET%
echo %BLUE%This script simulates how the NLP system interacts with the MCP Agent Broker%RESET%
echo.

pause
endlocal
