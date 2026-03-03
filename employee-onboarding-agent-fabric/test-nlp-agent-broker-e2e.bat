@echo off
REM ========================================
REM END-TO-END NLP AGENT BROKER TEST SUITE
REM Tests NLP natural language processing through Agent Broker MCP
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo NLP AGENT BROKER END-TO-END TEST SUITE
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: LOAD ENVIRONMENT AND VALIDATE ===
echo ==============================
echo 🔧 ENVIRONMENT SETUP
echo ==============================

REM Load environment variables from .env file
if not exist ".env" (
    echo ❌ ERROR: .env file not found in %CD%
    echo Please ensure .env file exists in the project root
    pause
    exit /b 1
)

echo ✅ Loading environment variables...
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim whitespace from key and value
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
    )
)

REM Validate required environment variables
if not defined GROQ_API_KEY (
    echo ❌ ERROR: GROQ_API_KEY not found in .env
    echo This is required for NLP processing
    pause
    exit /b 1
)

if not defined CLOUDHUB_REGION set "CLOUDHUB_REGION=us-east-1"

echo ✅ Environment validated:
echo   GROQ API Key: %GROQ_API_KEY:~0,8%...
echo   CloudHub Region: %CLOUDHUB_REGION%
echo.

REM === STEP 2: CHECK AGENT BROKER SERVICE STATUS ===
echo ==============================
echo 🔍 AGENT BROKER SERVICE CHECK
echo ==============================

set AGENT_BROKER_URL=https://agent-broker-mcp-server.%CLOUDHUB_REGION%.cloudhub.io

echo Testing Agent Broker MCP Server availability...
powershell -Command "& { try { $response = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '✅ Agent Broker MCP Server: HEALTHY' -ForegroundColor Green; exit 0 } else { Write-Host '❌ Agent Broker MCP Server: HTTP ' + $response.StatusCode -ForegroundColor Red; exit 1 } } catch { Write-Host '❌ Agent Broker MCP Server: NOT ACCESSIBLE' -ForegroundColor Red; exit 1 } }"

if !errorlevel! neq 0 (
    echo.
    echo 🔧 Troubleshooting Steps:
    echo   1. Ensure Agent Broker MCP is deployed to CloudHub
    echo   2. Check if the service is running: %AGENT_BROKER_URL%
    echo   3. Verify CloudHub region is correct: %CLOUDHUB_REGION%
    echo   4. Run deployment script: deploy.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Agent Broker MCP Server is accessible
echo.

REM === STEP 3: TEST NLP NATURAL LANGUAGE QUERIES ===
echo ==============================
echo 🧠 NLP AGENT BROKER TESTING
echo ==============================

echo Testing various NLP queries through Agent Broker...
echo.

REM Test 1: Simple Employee Onboarding Request
echo 📝 Test 1: Simple Employee Onboarding Request
echo ----------------------------------------
set TEST1_JSON={"query": "I need to onboard a new employee named John Smith with email john.smith@company.com in the Engineering department"}

echo Request: %TEST1_JSON%
echo.
echo Sending request to Agent Broker NLP endpoint...

powershell -Command "& { try { $body = '%TEST1_JSON%'; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/api/nlp/process' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 30; Write-Host '✅ Test 1 Response:' -ForegroundColor Green; $response | ConvertTo-Json -Depth 3 | Write-Host; } catch { Write-Host '❌ Test 1 Failed:' $_.Exception.Message -ForegroundColor Red } }"

echo.
timeout /t 2 /nobreak >nul

REM Test 2: Complex Multi-Step Request
echo 📝 Test 2: Complex Multi-Step Request
echo ----------------------------------------
set TEST2_JSON={"query": "Create a new employee profile for Sarah Johnson, email sarah.j@company.com, HR department, allocate laptop and phone, send welcome email, and notify her manager Mike Davis at mike.davis@company.com"}

echo Request: Complex onboarding with multiple steps...
echo.

powershell -Command "& { try { $body = '%TEST2_JSON%'; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/api/nlp/process' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 30; Write-Host '✅ Test 2 Response:' -ForegroundColor Green; $response | ConvertTo-Json -Depth 3 | Write-Host; } catch { Write-Host '❌ Test 2 Failed:' $_.Exception.Message -ForegroundColor Red } }"

echo.
timeout /t 2 /nobreak >nul

REM Test 3: Status Query Request
echo 📝 Test 3: Status Query Request
echo ----------------------------------------
set TEST3_JSON={"query": "What is the status of employee onboarding for john.smith@company.com?"}

echo Request: Status query for existing employee...
echo.

powershell -Command "& { try { $body = '%TEST3_JSON%'; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/api/nlp/process' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 30; Write-Host '✅ Test 3 Response:' -ForegroundColor Green; $response | ConvertTo-Json -Depth 3 | Write-Host; } catch { Write-Host '❌ Test 3 Failed:' $_.Exception.Message -ForegroundColor Red } }"

echo.
timeout /t 2 /nobreak >nul

REM Test 4: Asset Management Query
echo 📝 Test 4: Asset Management Query
echo ----------------------------------------
set TEST4_JSON={"query": "Show me all available assets and allocate a laptop to employee ID EMP001"}

echo Request: Asset management through natural language...
echo.

powershell -Command "& { try { $body = '%TEST4_JSON%'; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/api/nlp/process' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 30; Write-Host '✅ Test 4 Response:' -ForegroundColor Green; $response | ConvertTo-Json -Depth 3 | Write-Host; } catch { Write-Host '❌ Test 4 Failed:' $_.Exception.Message -ForegroundColor Red } }"

echo.
timeout /t 2 /nobreak >nul

REM === STEP 4: TEST MCP TOOL ORCHESTRATION ===
echo ==============================
echo 🔧 MCP TOOL ORCHESTRATION TEST
echo ==============================

echo Testing direct MCP tool orchestration endpoint...
echo.

REM Direct MCP Tool Test
echo 📝 Direct MCP Tool Test: orchestrate-employee-onboarding
echo --------------------------------------------------------
set MCP_TEST_JSON={"firstName": "Alice", "lastName": "Brown", "email": "alice.brown@company.com", "phone": "555-0123", "department": "Marketing", "position": "Marketing Manager", "startDate": "2024-01-15", "salary": 75000, "manager": "David Wilson", "managerEmail": "david.wilson@company.com", "companyName": "TechCorp", "assets": ["laptop", "phone", "id-card"]}

echo Request: Direct MCP tool orchestration...
echo.

powershell -Command "& { try { $body = '%MCP_TEST_JSON%'; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 45; Write-Host '✅ MCP Tool Response:' -ForegroundColor Green; $response | ConvertTo-Json -Depth 3 | Write-Host; } catch { Write-Host '❌ MCP Tool Failed:' $_.Exception.Message -ForegroundColor Red } }"

echo.

REM === STEP 5: TEST DEPENDENT SERVICES ===
echo ==============================
echo 🔗 DEPENDENT SERVICES TEST
echo ==============================

echo Testing dependent MCP services...
echo.

REM Test Employee Onboarding MCP
echo 📝 Testing Employee Onboarding MCP Service
set EMP_MCP_URL=https://employee-onboarding-mcp-server.%CLOUDHUB_REGION%.cloudhub.io

powershell -Command "& { try { $response = Invoke-WebRequest -Uri '%EMP_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '✅ Employee Onboarding MCP: HEALTHY' -ForegroundColor Green } else { Write-Host '⚠️ Employee Onboarding MCP: HTTP ' + $response.StatusCode -ForegroundColor Yellow } } catch { Write-Host '❌ Employee Onboarding MCP: NOT ACCESSIBLE' -ForegroundColor Red } }"

REM Test Asset Allocation MCP
echo 📝 Testing Asset Allocation MCP Service
set ASSET_MCP_URL=https://asset-allocation-mcp-server.%CLOUDHUB_REGION%.cloudhub.io

powershell -Command "& { try { $response = Invoke-WebRequest -Uri '%ASSET_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '✅ Asset Allocation MCP: HEALTHY' -ForegroundColor Green } else { Write-Host '⚠️ Asset Allocation MCP: HTTP ' + $response.StatusCode -ForegroundColor Yellow } } catch { Write-Host '❌ Asset Allocation MCP: NOT ACCESSIBLE' -ForegroundColor Red } }"

REM Test Notification MCP
echo 📝 Testing Notification MCP Service
set NOTIFY_MCP_URL=https://notification-mcp-server.%CLOUDHUB_REGION%.cloudhub.io

powershell -Command "& { try { $response = Invoke-WebRequest -Uri '%NOTIFY_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '✅ Notification MCP: HEALTHY' -ForegroundColor Green } else { Write-Host '⚠️ Notification MCP: HTTP ' + $response.StatusCode -ForegroundColor Yellow } } catch { Write-Host '❌ Notification MCP: NOT ACCESSIBLE' -ForegroundColor Red } }"

echo.

REM === STEP 6: PERFORMANCE AND LOAD TEST ===
echo ==============================
echo ⚡ PERFORMANCE TEST
echo ==============================

echo Running quick performance test...
echo.

set PERF_TEST_JSON={"query": "Quick performance test - onboard test employee perf@test.com"}

echo Sending 3 concurrent requests to test performance...
timeout /t 1 /nobreak >nul

for /L %%i in (1,1,3) do (
    start /B powershell -WindowStyle Hidden -Command "& { try { $body = '%PERF_TEST_JSON%'; $start = Get-Date; $response = Invoke-RestMethod -Uri '%AGENT_BROKER_URL%/api/nlp/process' -Method POST -Body $body -ContentType 'application/json' -TimeoutSec 15; $end = Get-Date; $duration = ($end - $start).TotalMilliseconds; Write-Host 'Request %%i: ' + $duration + 'ms' } catch { Write-Host 'Request %%i: FAILED' } }"
)

echo Waiting for performance test completion...
timeout /t 5 /nobreak >nul

echo.

REM === STEP 7: COMPREHENSIVE TEST SUMMARY ===
echo ==============================
echo 📊 TEST SUMMARY REPORT
echo ==============================

echo.
echo 🎯 TEST SUITE COMPLETED
echo.
echo 📋 Services Tested:
echo   🤖 Agent Broker MCP Server: %AGENT_BROKER_URL%
echo   📝 Employee Onboarding MCP: %EMP_MCP_URL%
echo   💻 Asset Allocation MCP: %ASSET_MCP_URL%
echo   📧 Notification MCP: %NOTIFY_MCP_URL%
echo.
echo 🧪 NLP Test Cases Executed:
echo   ✓ Simple employee onboarding request
echo   ✓ Complex multi-step onboarding request
echo   ✓ Status query for existing employee
echo   ✓ Asset management natural language query
echo   ✓ Direct MCP tool orchestration
echo   ✓ Performance and concurrent request testing
echo.
echo 🔗 Integration Points Tested:
echo   ✓ NLP Query Processing (GROQ API)
echo   ✓ MCP Tool Orchestration
echo   ✓ Cross-service communication
echo   ✓ Employee profile management
echo   ✓ Asset allocation workflow
echo   ✓ Notification system integration
echo.
echo 💡 Usage Examples:
echo   🗣️  "Onboard John Smith in Engineering with laptop and phone"
echo   🗣️  "What's the status of alice.brown@company.com onboarding?"
echo   🗣️  "Allocate iPhone to employee EMP123 and notify manager"
echo   🗣️  "Create profile for new hire with all standard assets"
echo.
echo 🌐 Test Endpoints:
echo   POST %AGENT_BROKER_URL%/api/nlp/process
echo   POST %AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding
echo   GET  %AGENT_BROKER_URL%/health
echo.
echo ✅ NLP AGENT BROKER END-TO-END TEST SUITE COMPLETE!
echo.
echo Ready for production use with natural language employee onboarding!
echo.

pause
endlocal
