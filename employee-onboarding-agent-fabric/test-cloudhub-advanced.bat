@echo off
setlocal enabledelayedexpansion

REM ========================================================================
REM Advanced CloudHub End-to-End Testing Suite for Employee Onboarding
REM ========================================================================
REM This script provides comprehensive testing with enhanced logging and reporting

echo.
echo ========================================================================
echo  ADVANCED CLOUDHUB END-TO-END TESTING SUITE
echo  Employee Onboarding Agent Fabric - CloudHub Deployment
echo ========================================================================
echo.

REM Initialize test environment
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM Set test configuration with timestamps
set TEST_START_TIME=%TIME%
set TEST_DATE=%DATE%
for /f "tokens=1-3 delims=/ " %%a in ("%DATE%") do set TEST_DATE_CLEAN=%%c%%a%%b
for /f "tokens=1-3 delims=: " %%a in ("%TIME%") do set TEST_TIME_CLEAN=%%a%%b%%c
set TEST_LOG=test-cloudhub-results-%TEST_DATE_CLEAN%-%TEST_TIME_CLEAN%.log
set TEST_JSON=test-results-%TEST_DATE_CLEAN%-%TEST_TIME_CLEAN%.json
set FAILED_TESTS=0
set PASSED_TESTS=0
set TOTAL_TESTS=0
set WARNINGS=0

REM Initialize comprehensive test log
echo CloudHub Advanced End-to-End Test Results > "%TEST_LOG%"
echo Test Started: %TEST_DATE% %TEST_START_TIME% >> "%TEST_LOG%"
echo ================================================== >> "%TEST_LOG%"
echo. >> "%TEST_LOG%"

echo [INFO] Advanced test results will be logged to: %TEST_LOG%
echo [INFO] JSON results will be saved to: %TEST_JSON%
echo.

REM Load environment configuration
echo [INFO] Loading environment configuration...
if exist .env (
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
            echo [DEBUG] Loaded environment variable: %%a
        )
    )
    echo [SUCCESS] Environment configuration loaded from .env file
    echo Environment configuration loaded from .env file >> "%TEST_LOG%"
) else (
    echo [WARNING] .env file not found, using system environment variables
    echo WARNING: .env file not found >> "%TEST_LOG%"
    set /a WARNINGS+=1
)

REM Initialize JSON results structure
echo { > "%TEST_JSON%"
echo   "testSuite": "CloudHub Employee Onboarding E2E Tests", >> "%TEST_JSON%"
echo   "startTime": "%TEST_DATE% %TEST_START_TIME%", >> "%TEST_JSON%"
echo   "environment": "CloudHub", >> "%TEST_JSON%"
echo   "tests": [ >> "%TEST_JSON%"

echo.

REM ========================================================================
REM Test 1: Environment and Prerequisites Validation
REM ========================================================================
echo [TEST 1] Environment and Prerequisites Validation
echo ============================================
set /a TOTAL_TESTS+=1

echo [INFO] Validating test prerequisites...

REM Check curl availability
curl --version > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FAIL] curl is not installed or not available in PATH
    echo FAIL: curl not available >> "%TEST_LOG%"
    echo     { "test": "Curl Availability", "result": "FAIL", "message": "curl not installed" }, >> "%TEST_JSON%"
    set /a FAILED_TESTS+=1
) else (
    echo [PASS] curl is available
    echo PASS: curl is available >> "%TEST_LOG%"
    echo     { "test": "Curl Availability", "result": "PASS", "message": "curl installed and accessible" }, >> "%TEST_JSON%"
    set /a PASSED_TESTS+=1
)

REM Check internet connectivity
echo [INFO] Testing internet connectivity...
curl -s --connect-timeout 5 https://www.google.com > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FAIL] No internet connectivity or network issues
    echo FAIL: No internet connectivity >> "%TEST_LOG%"
    echo     { "test": "Internet Connectivity", "result": "FAIL", "message": "Cannot reach external servers" }, >> "%TEST_JSON%"
    set /a FAILED_TESTS+=1
) else (
    echo [PASS] Internet connectivity confirmed
    echo PASS: Internet connectivity confirmed >> "%TEST_LOG%"
    echo     { "test": "Internet Connectivity", "result": "PASS", "message": "External connectivity working" }, >> "%TEST_JSON%"
    set /a PASSED_TESTS+=1
)

echo.

REM ========================================================================
REM Test 2: CloudHub MCP Server Health Checks with Detailed Validation
REM ========================================================================
echo [TEST 2] CloudHub MCP Server Health Checks
echo ============================================
set /a TOTAL_TESTS+=1

echo [INFO] Testing CloudHub MCP Server health endpoints with detailed validation...

REM Define CloudHub service endpoints
set BROKER_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io
set EMPLOYEE_URL=https://employee-onboarding-service.us-e1.cloudhub.io
set ASSET_URL=https://asset-allocation-service.us-e1.cloudhub.io
set NOTIFICATION_URL=https://employee-notification-service.us-e1.cloudhub.io

REM Test Agent Broker MCP with detailed response analysis
echo [INFO] Testing Agent Broker MCP...
curl -s -f -w "%%{http_code}" "%BROKER_URL%/health" -o temp_broker_response.json 2>&1 > temp_broker_code.txt
set /p BROKER_HTTP_CODE=<temp_broker_code.txt

if "%BROKER_HTTP_CODE%"=="200" (
    echo [PASS] Agent Broker MCP: HEALTHY ^(HTTP 200^)
    echo PASS: Agent Broker MCP healthy - HTTP 200 >> "%TEST_LOG%"
    echo     { "test": "Agent Broker Health", "result": "PASS", "httpCode": %BROKER_HTTP_CODE%, "url": "%BROKER_URL%/health" }, >> "%TEST_JSON%"
    set BROKER_CLOUD=1
    set /a PASSED_TESTS+=1
) else (
    echo [FAIL] Agent Broker MCP: NOT AVAILABLE ^(HTTP %BROKER_HTTP_CODE%^)
    echo FAIL: Agent Broker MCP not available - HTTP %BROKER_HTTP_CODE% >> "%TEST_LOG%"
    echo     { "test": "Agent Broker Health", "result": "FAIL", "httpCode": "%BROKER_HTTP_CODE%", "url": "%BROKER_URL%/health" }, >> "%TEST_JSON%"
    set BROKER_CLOUD=0
    set /a FAILED_TESTS+=1
)

REM Test Employee Onboarding MCP with detailed response analysis
echo [INFO] Testing Employee Onboarding MCP...
curl -s -f -w "%%{http_code}" "%EMPLOYEE_URL%/health" -o temp_employee_response.json 2>&1 > temp_employee_code.txt
set /p EMPLOYEE_HTTP_CODE=<temp_employee_code.txt

if "%EMPLOYEE_HTTP_CODE%"=="200" (
    echo [PASS] Employee Onboarding MCP: HEALTHY ^(HTTP 200^)
    echo PASS: Employee Onboarding MCP healthy - HTTP 200 >> "%TEST_LOG%"
    echo     { "test": "Employee Onboarding Health", "result": "PASS", "httpCode": %EMPLOYEE_HTTP_CODE%, "url": "%EMPLOYEE_URL%/health" }, >> "%TEST_JSON%"
    set EMPLOYEE_CLOUD=1
    set /a PASSED_TESTS+=1
) else (
    echo [FAIL] Employee Onboarding MCP: NOT AVAILABLE ^(HTTP %EMPLOYEE_HTTP_CODE%^)
    echo FAIL: Employee Onboarding MCP not available - HTTP %EMPLOYEE_HTTP_CODE% >> "%TEST_LOG%"
    echo     { "test": "Employee Onboarding Health", "result": "FAIL", "httpCode": "%EMPLOYEE_HTTP_CODE%", "url": "%EMPLOYEE_URL%/health" }, >> "%TEST_JSON%"
    set EMPLOYEE_CLOUD=0
    set /a FAILED_TESTS+=1
)

REM Test Asset Allocation MCP with detailed response analysis
echo [INFO] Testing Asset Allocation MCP...
curl -s -f -w "%%{http_code}" "%ASSET_URL%/health" -o temp_asset_response.json 2>&1 > temp_asset_code.txt
set /p ASSET_HTTP_CODE=<temp_asset_code.txt

if "%ASSET_HTTP_CODE%"=="200" (
    echo [PASS] Asset Allocation MCP: HEALTHY ^(HTTP 200^)
    echo PASS: Asset Allocation MCP healthy - HTTP 200 >> "%TEST_LOG%"
    echo     { "test": "Asset Allocation Health", "result": "PASS", "httpCode": %ASSET_HTTP_CODE%, "url": "%ASSET_URL%/health" }, >> "%TEST_JSON%"
    set ASSET_CLOUD=1
    set /a PASSED_TESTS+=1
) else (
    echo [FAIL] Asset Allocation MCP: NOT AVAILABLE ^(HTTP %ASSET_HTTP_CODE%^)
    echo FAIL: Asset Allocation MCP not available - HTTP %ASSET_HTTP_CODE% >> "%TEST_LOG%"
    echo     { "test": "Asset Allocation Health", "result": "FAIL", "httpCode": "%ASSET_HTTP_CODE%", "url": "%ASSET_URL%/health" }, >> "%TEST_JSON%"
    set ASSET_CLOUD=0
    set /a FAILED_TESTS+=1
)

REM Test Notification MCP with detailed response analysis
echo [INFO] Testing Employee Notification Service...
curl -s -f -w "%%{http_code}" "%NOTIFICATION_URL%/health" -o temp_notification_response.json 2>&1 > temp_notification_code.txt
set /p NOTIFICATION_HTTP_CODE=<temp_notification_code.txt

if "%NOTIFICATION_HTTP_CODE%"=="200" (
    echo [PASS] Employee Notification Service: HEALTHY ^(HTTP 200^)
    echo PASS: Employee Notification Service healthy - HTTP 200 >> "%TEST_LOG%"
    echo     { "test": "Notification Service Health", "result": "PASS", "httpCode": %NOTIFICATION_HTTP_CODE%, "url": "%NOTIFICATION_URL%/health" }, >> "%TEST_JSON%"
    set NOTIFICATION_CLOUD=1
    set /a PASSED_TESTS+=1
) else (
    echo [FAIL] Employee Notification Service: NOT AVAILABLE ^(HTTP %NOTIFICATION_HTTP_CODE%^)
    echo FAIL: Employee Notification Service not available - HTTP %NOTIFICATION_HTTP_CODE% >> "%TEST_LOG%"
    echo     { "test": "Notification Service Health", "result": "FAIL", "httpCode": "%NOTIFICATION_HTTP_CODE%", "url": "%NOTIFICATION_URL%/health" }, >> "%TEST_JSON%"
    set NOTIFICATION_CLOUD=0
    set /a FAILED_TESTS+=1
)

echo.

REM ========================================================================
REM Test 3: MCP Server Information and Capabilities Testing
REM ========================================================================
echo [TEST 3] MCP Server Information and Capabilities
echo ============================================
set /a TOTAL_TESTS+=1

if %BROKER_CLOUD%==1 (
    echo [INFO] Testing MCP server capabilities for Agent Broker...
    curl -s -w "%%{http_code}" "%BROKER_URL%/mcp/info" -o temp_broker_info.json 2>&1 > temp_broker_info_code.txt
    set /p BROKER_INFO_CODE=<temp_broker_info_code.txt
    
    if "!BROKER_INFO_CODE!"=="200" (
        echo [PASS] Agent Broker MCP info endpoint accessible
        echo PASS: Agent Broker MCP info endpoint - HTTP 200 >> "%TEST_LOG%"
        echo     { "test": "Agent Broker Info Endpoint", "result": "PASS", "httpCode": !BROKER_INFO_CODE! }, >> "%TEST_JSON%"
        set /a PASSED_TESTS+=1
        
        REM Display some info from the response
        echo [INFO] MCP Server Information:
        type temp_broker_info.json 2>nul || echo [INFO] Response data not readable
    ) else (
        echo [FAIL] Agent Broker MCP info endpoint not accessible ^(HTTP !BROKER_INFO_CODE!^)
        echo FAIL: Agent Broker MCP info endpoint - HTTP !BROKER_INFO_CODE! >> "%TEST_LOG%"
        echo     { "test": "Agent Broker Info Endpoint", "result": "FAIL", "httpCode": "!BROKER_INFO_CODE!" }, >> "%TEST_JSON%"
        set /a FAILED_TESTS+=1
    )
) else (
    echo [SKIP] Agent Broker not available - skipping info endpoint test
    echo SKIP: Agent Broker not available for info endpoint test >> "%TEST_LOG%"
    echo     { "test": "Agent Broker Info Endpoint", "result": "SKIP", "message": "Agent Broker not available" }, >> "%TEST_JSON%"
)

echo.

REM ========================================================================
REM Test 4: Employee Onboarding Orchestration Flow Test
REM ========================================================================
echo [TEST 4] Employee Onboarding Orchestration Flow
echo ============================================
set /a TOTAL_TESTS+=1

if %BROKER_CLOUD%==1 (
    echo [INFO] Testing complete employee onboarding orchestration...
    
    REM Generate unique test data
    set TEST_EMAIL=test.employee.%RANDOM%@cloudhubtesting.com
    set TEST_EMPLOYEE_JSON={"firstName":"TestUser","lastName":"CloudHub","email":"%TEST_EMAIL%","phone":"555-0123","department":"Engineering","position":"Software Developer","startDate":"2024-03-01","salary":75000,"manager":"Jane Smith","managerEmail":"jane.smith@company.com","companyName":"Test Company Inc","assets":["laptop","phone","id-card"]}
    
    echo [INFO] Creating test employee: %TEST_EMAIL%
    echo [INFO] Sending orchestration request to CloudHub...
    
    curl -s -X POST ^
        -H "Content-Type: application/json" ^
        -d "!TEST_EMPLOYEE_JSON!" ^
        -w "%%{http_code}" ^
        "%BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" ^
        -o temp_orchestration_response.json > temp_orchestration_code.txt 2>&1
    
    set /p ORCHESTRATION_CODE=<temp_orchestration_code.txt
    
    if "!ORCHESTRATION_CODE!"=="200" (
        echo [PASS] Employee onboarding orchestration request successful ^(HTTP 200^)
        echo PASS: Employee onboarding orchestration - HTTP 200 >> "%TEST_LOG%"
        echo     { "test": "Employee Onboarding Orchestration", "result": "PASS", "httpCode": !ORCHESTRATION_CODE!, "email": "%TEST_EMAIL%" }, >> "%TEST_JSON%"
        set /a PASSED_TESTS+=1
        
        echo [INFO] Waiting 15 seconds for processing...
        timeout /t 15 /nobreak > nul
        
        echo [INFO] Testing onboarding status check...
        curl -s -X GET ^
            -w "%%{http_code}" ^
            "%BROKER_URL%/mcp/tools/get-onboarding-status?email=%TEST_EMAIL%" ^
            -o temp_status_response.json > temp_status_code.txt 2>&1
        
        set /p STATUS_CODE=<temp_status_code.txt
        
        if "!STATUS_CODE!"=="200" (
            echo [PASS] Onboarding status check successful ^(HTTP 200^)
            echo PASS: Onboarding status check - HTTP 200 >> "%TEST_LOG%"
            echo     { "test": "Onboarding Status Check", "result": "PASS", "httpCode": !STATUS_CODE! }, >> "%TEST_JSON%"
            set /a PASSED_TESTS+=1
            
            echo [INFO] Status Response:
            type temp_status_response.json 2>nul || echo [INFO] Response data not readable
        ) else (
            echo [FAIL] Onboarding status check failed ^(HTTP !STATUS_CODE!^)
            echo FAIL: Onboarding status check - HTTP !STATUS_CODE! >> "%TEST_LOG%"
            echo     { "test": "Onboarding Status Check", "result": "FAIL", "httpCode": "!STATUS_CODE!" }, >> "%TEST_JSON%"
            set /a FAILED_TESTS+=1
        )
    ) else (
        echo [FAIL] Employee onboarding orchestration failed ^(HTTP !ORCHESTRATION_CODE!^)
        echo FAIL: Employee onboarding orchestration - HTTP !ORCHESTRATION_CODE! >> "%TEST_LOG%"
        echo     { "test": "Employee Onboarding Orchestration", "result": "FAIL", "httpCode": "!ORCHESTRATION_CODE!" }, >> "%TEST_JSON%"
        set /a FAILED_TESTS+=1
    )
) else (
    echo [SKIP] Agent Broker not available - skipping orchestration test
    echo SKIP: Agent Broker not available for orchestration test >> "%TEST_LOG%"
    echo     { "test": "Employee Onboarding Orchestration", "result": "SKIP", "message": "Agent Broker not available" }, >> "%TEST_JSON%"
)

echo.

REM ========================================================================
REM Test 5: System Health and Performance Monitoring
REM ========================================================================
echo [TEST 5] System Health and Performance Monitoring
echo ============================================
set /a TOTAL_TESTS+=1

if %BROKER_CLOUD%==1 (
    echo [INFO] Testing system health check endpoint...
    curl -s -X POST ^
        -H "Content-Type: application/json" ^
        -d "{}" ^
        -w "%%{http_code}" ^
        "%BROKER_URL%/mcp/tools/check-system-health" ^
        -o temp_system_health.json > temp_system_health_code.txt 2>&1
    
    set /p SYSTEM_HEALTH_CODE=<temp_system_health_code.txt
    
    if "!SYSTEM_HEALTH_CODE!"=="200" (
        echo [PASS] System health check successful ^(HTTP 200^)
        echo PASS: System health check - HTTP 200 >> "%TEST_LOG%"
        echo     { "test": "System Health Check", "result": "PASS", "httpCode": !SYSTEM_HEALTH_CODE! }, >> "%TEST_JSON%"
        set /a PASSED_TESTS+=1
        
        echo [INFO] System Health Response:
        type temp_system_health.json 2>nul || echo [INFO] Response data not readable
    ) else (
        echo [FAIL] System health check failed ^(HTTP !SYSTEM_HEALTH_CODE!^)
        echo FAIL: System health check - HTTP !SYSTEM_HEALTH_CODE! >> "%TEST_LOG%"
        echo     { "test": "System Health Check", "result": "FAIL", "httpCode": "!SYSTEM_HEALTH_CODE!" }, >> "%TEST_JSON%"
        set /a FAILED_TESTS+=1
    )
) else (
    echo [SKIP] Agent Broker not available - skipping system health check
    echo SKIP: Agent Broker not available for system health check >> "%TEST_LOG%"
    echo     { "test": "System Health Check", "result": "SKIP", "message": "Agent Broker not available" }, >> "%TEST_JSON%"
)

REM Test performance monitoring endpoints
echo [INFO] Testing performance monitoring endpoints...

if %BROKER_CLOUD%==1 (
    curl -s -w "%%{http_code}" "%BROKER_URL%/metrics" -o temp_broker_metrics.json > temp_broker_metrics_code.txt 2>&1
    set /p BROKER_METRICS_CODE=<temp_broker_metrics_code.txt
    
    if "!BROKER_METRICS_CODE!"=="200" (
        echo [PASS] Agent Broker metrics endpoint accessible ^(HTTP 200^)
        echo PASS: Agent Broker metrics - HTTP 200 >> "%TEST_LOG%"
        set /a PASSED_TESTS+=1
    ) else (
        echo [INFO] Agent Broker metrics endpoint not available ^(HTTP !BROKER_METRICS_CODE!^)
        echo INFO: Agent Broker metrics not available - HTTP !BROKER_METRICS_CODE! >> "%TEST_LOG%"
        set /a WARNINGS+=1
    )
)

echo.

REM ========================================================================
REM Test Results Summary and Cleanup
REM ========================================================================
echo ============================================
echo ADVANCED CLOUDHUB TEST RESULTS SUMMARY
echo ============================================

REM Calculate overall health score
set /a TOTAL_SERVICES=4
set /a HEALTHY_SERVICES=0

if %BROKER_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %EMPLOYEE_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %ASSET_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %NOTIFICATION_CLOUD%==1 set /a HEALTHY_SERVICES+=1

echo.
echo === TEST EXECUTION SUMMARY ===
echo Total Tests Executed: %TOTAL_TESTS%
echo Tests Passed: %PASSED_TESTS%
echo Tests Failed: %FAILED_TESTS%
echo Warnings: %WARNINGS%

REM Calculate success rate
set /a SUCCESS_RATE=(%PASSED_TESTS% * 100) / %TOTAL_TESTS%
echo Success Rate: %SUCCESS_RATE%%%

echo.
echo === CLOUDHUB SERVICE STATUS ===
echo Healthy Services: %HEALTHY_SERVICES% out of %TOTAL_SERVICES%

if %BROKER_CLOUD%==1 (
    echo ✅ Agent Broker MCP: DEPLOYED ^& HEALTHY
) else (
    echo ❌ Agent Broker MCP: NOT DEPLOYED
)

if %EMPLOYEE_CLOUD%==1 (
    echo ✅ Employee Onboarding Service: DEPLOYED ^& HEALTHY
) else (
    echo ❌ Employee Onboarding Service: NOT DEPLOYED
)

if %ASSET_CLOUD%==1 (
    echo ✅ Asset Allocation Service: DEPLOYED ^& HEALTHY
) else (
    echo ❌ Asset Allocation Service: NOT DEPLOYED
)

if %NOTIFICATION_CLOUD%==1 (
    echo ✅ Employee Notification Service: DEPLOYED ^& HEALTHY
) else (
    echo ❌ Employee Notification Service: NOT DEPLOYED
)

REM Final JSON completion
set TEST_END_TIME=%TIME%
echo   ], >> "%TEST_JSON%"
echo   "summary": { >> "%TEST_JSON%"
echo     "totalTests": %TOTAL_TESTS%, >> "%TEST_JSON%"
echo     "passed": %PASSED_TESTS%, >> "%TEST_JSON%"
echo     "failed": %FAILED_TESTS%, >> "%TEST_JSON%"
echo     "warnings": %WARNINGS%, >> "%TEST_JSON%"
echo     "successRate": %SUCCESS_RATE%, >> "%TEST_JSON%"
echo     "healthyServices": %HEALTHY_SERVICES%, >> "%TEST_JSON%"
echo     "totalServices": %TOTAL_SERVICES%, >> "%TEST_JSON%"
echo     "endTime": "%TEST_DATE% %TEST_END_TIME%" >> "%TEST_JSON%"
echo   } >> "%TEST_JSON%"
echo } >> "%TEST_JSON%"

echo.
echo === OVERALL ASSESSMENT ===
if %SUCCESS_RATE% geq 80 (
    if %HEALTHY_SERVICES%==%TOTAL_SERVICES% (
        echo 🎉 EXCELLENT - All services healthy, system ready for production
        echo ASSESSMENT: EXCELLENT - Production Ready >> "%TEST_LOG%"
    ) else (
        echo ✅ GOOD - Most services healthy, minor issues detected
        echo ASSESSMENT: GOOD - Minor Issues >> "%TEST_LOG%"
    )
) else if %SUCCESS_RATE% geq 50 (
    echo ⚠️  MODERATE - Significant issues detected, requires attention
    echo ASSESSMENT: MODERATE - Requires Attention >> "%TEST_LOG%"
) else (
    echo 🚨 CRITICAL - Major deployment issues, system not ready
    echo ASSESSMENT: CRITICAL - Not Ready >> "%TEST_LOG%"
)

echo.
echo === DETAILED REPORTS ===
echo Test Log: %TEST_LOG%
echo JSON Results: %TEST_JSON%
echo.

REM Cleanup temporary files
del temp_*.txt temp_*.json >nul 2>&1

echo === NEXT STEPS AND RECOMMENDATIONS ===
echo.
if %SUCCESS_RATE% lss 80 (
    echo IMMEDIATE ACTIONS REQUIRED:
    echo 1. Check CloudHub Runtime Manager for deployment issues
    echo 2. Verify application logs in Anypoint Platform
    echo 3. Confirm environment configurations are correct
    echo 4. Re-deploy failed services using deploy-all-to-cloudhub.bat
    echo 5. Validate network connectivity and DNS resolution
) else (
    echo RECOMMENDED ACTIONS:
    echo 1. All critical services are operational
    echo 2. Consider setting up monitoring and alerting
    echo 3. Plan for load testing if preparing for production
    echo 4. Document any warnings for future reference
)

echo.
echo === QUICK ACCESS LINKS ===
echo 🌐 CloudHub Runtime Manager: https://anypoint.mulesoft.com/cloudhub/
echo 📊 Test Results JSON: %TEST_JSON%
echo 📝 Detailed Log: %TEST_LOG%

echo.
echo ============================================
echo 🏁 ADVANCED CLOUDHUB E2E TESTING COMPLETED
echo ============================================

echo.
echo Opening CloudHub Runtime Manager for manual verification...
start https://anypoint.mulesoft.com/cloudhub/

echo.
echo Press any key to continue...
pause >nul
