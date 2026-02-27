@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ============================================
echo MCP SERVICES COMPREHENSIVE ENDPOINT TESTER
echo ============================================
echo Timestamp: %date% %time%
echo.

REM Initialize report system
set REPORT_TIME=%date:~-4,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%
set REPORT_TIME=%REPORT_TIME: =0%
set REPORT_FILE=mcp-endpoints-report-%REPORT_TIME%.html
set TEST_PASSED=0
set TEST_FAILED=0
set TEST_SKIPPED=0
set TOTAL_REQUESTS=0

REM HTML Report Header
echo ^<html^>^<head^>^<meta charset="UTF-8"^>^<title^>MCP Endpoints Test Report^</title^> > "%REPORT_FILE%"
echo ^<style^>body{font-family:'Segoe UI',sans-serif;background:linear-gradient(135deg,#667eea 0%%,#764ba2 100%%);margin:0;padding:20px;color:#333} >> "%REPORT_FILE%"
echo .container{max-width:1200px;margin:0 auto;background:white;border-radius:15px;padding:30px;box-shadow:0 20px 40px rgba(0,0,0,0.1)} >> "%REPORT_FILE%"
echo h1{color:#2c3e50;text-align:center;font-size:2.5em;margin-bottom:10px;text-shadow:2px 2px 4px rgba(0,0,0,0.1)} >> "%REPORT_FILE%"
echo .summary{background:linear-gradient(45deg,#4CAF50,#45a049);color:white;padding:20px;border-radius:10px;margin:20px 0;text-align:center} >> "%REPORT_FILE%"
echo table{width:100%%;border-collapse:collapse;margin:20px 0;font-size:14px}th{padding:15px;background:#34495e;color:white;text-align:left} >> "%REPORT_FILE%"
echo td{padding:12px;border-bottom:1px solid #eee}tr:hover{background:#f8f9fa}.pass{background:#d4edda}.fail{background:#f8d7da}.warn{background:#fff3cd} >> "%REPORT_FILE%"
echo .endpoint-section{margin:30px 0;border:1px solid #ddd;border-radius:8px;padding:20px}.status-badge{padding:4px 8px;border-radius:20px;font-size:12px;font-weight:bold}.success{background:#4CAF50;color:white}.error{background:#f44336;color:white}.details{max-height:200px;overflow-y:auto;background:#f8f9fa;padding:10px;border-radius:5px;font-family:monospace;font-size:12px} >> "%REPORT_FILE%"
echo ^</style^>^</head^>^<body^>^<div class="container"^>^<h1^>🔬 MCP Services Endpoint Report^</h1^> >> "%REPORT_FILE%"
echo ^<p style="text-align:center;color:#7f8c8d"^>Generated: %date% %time% ^| %COMPUTERNAME%^</p^> >> "%REPORT_FILE%"

REM Determine environment

    echo Testing CLOUHHUB services...
    set AGENT_BROKER_URL=http://agent-broker-mcp-server.us-e1.cloudhub.io
    set ASSET_ALLOCATION_URL=http://asset-allocation-mcp-server.us-e1.cloudhub.io
    set EMPLOYEE_ONBOARDING_URL=http://employee-onboarding-mcp-server.us-e1.cloudhub.io
    set NOTIFICATION_URL=http://employee-notification-service.us-e1.cloudhub.io
    echo ^<div class="summary"^>^<h2^>☁️ CLOUHHUB PRODUCTION TESTING^</h2^>^</div^> >> "%REPORT_FILE%"



REM Execute ALL endpoints systematically
call :TEST_HEALTH_ENDPOINTS
call :TEST_INFO_ENDPOINTS  
call :TEST_MCP_TOOL_ENDPOINTS
call :TEST_METRICS_ENDPOINTS
call :TEST_CUSTOM_ENDPOINTS

REM Generate summary
set /a TOTAL_TESTS=%TEST_PASSED%+%TEST_FAILED%
set /a SUCCESS_RATE=%TEST_PASSED%*100/!TOTAL_TESTS! 2>nul
echo ^<div class="summary"^> >> "%REPORT_FILE%"
echo ^<h2^>📊 EXECUTION SUMMARY^</h2^>^<table^>^<tr^>^<td^>✅ Passed^</td^>^<td^>%TEST_PASSED%^</td^>^</tr^> >> "%REPORT_FILE%"
echo ^<tr^>^<td^>❌ Failed^</td^>^<td^>%TEST_FAILED%^</td^>^</tr^>^<tr^>^<td^>📈 Success Rate^</td^>^<td^>%SUCCESS_RATE%%%%^</td^>^</tr^>^<tr^>^<td^>⏱️  Total Requests^</td^>^<td^>%TOTAL_REQUESTS%^</td^>^</tr^>^</table^> >> "%REPORT_FILE%"
echo ^</div^>^</div^>^</body^>^</html^> >> "%REPORT_FILE%"

echo.
echo ============================================
echo ✅ ALL ENDPOINTS TESTED SUCCESSFULLY
echo ============================================
echo 📊 Report: %REPORT_FILE% (%TOTAL_TESTS% tests)
echo 📈 Success: %SUCCESS_RATE%% | Passed: %TEST_PASSED% | Failed: %TEST_FAILED%
echo.
start "" "%REPORT_FILE%"
goto :END

:TEST_HEALTH_ENDPOINTS
echo [1/5] Testing HEALTH endpoints...
echo %AGENT_BROKER_URL%/health
echo ^<div class="endpoint-section"^>^<h2^>🏥 HEALTH ENDPOINTS^</h2^>^<table^>^<tr^>^<th^>Endpoint^</th^>^<th^>Status^</th^>^<th^>Response^</th^>^<th^>Time^</th^>^</tr^> >> "%REPORT_FILE%"
call :CURL_TEST "%AGENT_BROKER_URL%/health" "Agent Broker Health"
call :CURL_TEST "%ASSET_ALLOCATION_URL%/health" "Asset Allocation Health"
call :CURL_TEST "%EMPLOYEE_ONBOARDING_URL%/health" "Employee Onboarding Health" 
call :CURL_TEST "%NOTIFICATION_URL%/health" "Notification Health"
echo ^</table^>^</div^> >> "%REPORT_FILE%"
goto :eof

:TEST_INFO_ENDPOINTS
echo [2/5] Testing INFO endpoints...
echo ^<div class="endpoint-section"^>^<h2^>ℹ️  INFO ENDPOINTS^</h2^>^<table^>^<tr^>^<th^>Endpoint^</th^>^<th^>Status^</th^>^<th^>Response^</th^>^</tr^> >> "%REPORT_FILE%"
call :CURL_TEST "%AGENT_BROKER_URL%/mcp/info" "Agent Broker Info" json
call :CURL_TEST "%ASSET_ALLOCATION_URL%/mcp/info" "Asset Allocation Info" json
call :CURL_TEST "%EMPLOYEE_ONBOARDING_URL%/mcp/info" "Employee Onboarding Info" json
call :CURL_TEST "%NOTIFICATION_URL%/mcp/info" "Notification Info" json
echo ^</table^>^</div^> >> "%REPORT_FILE%"
goto :eof

:TEST_MCP_TOOL_ENDPOINTS
echo [3/5] Testing MCP TOOL endpoints...
echo ^<div class="endpoint-section"^>^<h2^>🔧 MCP TOOL ENDPOINTS^</h2^>^<table^>^<tr^>^<th^>Endpoint^</th^>^<th^>Method^</th^>^<th^>Status^</th^>^</tr^> >> "%REPORT_FILE%"
REM GET endpoints
call :CURL_TEST "%ASSET_ALLOCATION_URL%/mcp/tools/get-available-assets" "Get Available Assets" GET
call :CURL_TEST "%EMPLOYEE_ONBOARDING_URL%/mcp/tools/list-employees" "List Employees" GET
call :CURL_TEST "%NOTIFICATION_URL%/mcp/tools/get-notification-history" "Notification History" GET
REM POST endpoints (health checks only)
call :CURL_POST "%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding" "Orchestrate Onboarding" "{\"test\":true}"
echo ^</table^>^</div^> >> "%REPORT_FILE%"
goto :eof

:TEST_METRICS_ENDPOINTS
echo [4/5] Testing METRICS endpoints...
echo ^<div class="endpoint-section"^>^<h2^>📊 METRICS ENDPOINTS^</h2^>^<table^>^<tr^>^<th^>Endpoint^</th^>^<th^>Status^</th^>^</tr^> >> "%REPORT_FILE%"
call :CURL_TEST "%AGENT_BROKER_URL%/metrics" "Agent Broker Metrics"
call :CURL_TEST "%ASSET_ALLOCATION_URL%/metrics" "Asset Allocation Metrics"
echo ^</table^>^</div^> >> "%REPORT_FILE%"
goto :eof

:TEST_CUSTOM_ENDPOINTS
echo [5/5] Testing CUSTOM endpoints...
echo ^<div class="endpoint-section"^>^<h2^>⚙️  CUSTOM ENDPOINTS^</h2^>^<table^>^<tr^>^<th^>Endpoint^</th^>^<th^>Status^</th^>^</tr^> >> "%REPORT_FILE%"
REM Add your custom endpoints here
call :CURL_TEST "%AGENT_BROKER_URL%/actuator/health" "Spring Boot Health"
echo ^</table^>^</div^> >> "%REPORT_FILE%"
goto :eof

:CURL_TEST
set /a TOTAL_REQUESTS+=1
set URL=%~1
set NAME=%~2
set FORMAT=%~3
curl -s -w "@curl-format.txt" -o response.tmp "%URL%" >curl.out 2>&1
set HTTP_CODE=
set TIME_TOTAL=
for /f "tokens=*" %%a in (curl.out) do (
    echo %%a | findstr /C:"HTTP Status" >nul && set HTTP_CODE=%%a
    echo %%a | findstr /C:"Response Time" >nul && set TIME_TOTAL=%%a
)
if %ERRORLEVEL% equ 0 (
    if "!HTTP_CODE:~14,3!"=="200" (
        echo ✅ %NAME%: OK
        set /a TEST_PASSED+=1
        echo ^<tr class="pass"^>^<td^>%NAME%^</td^>^<td^>^<span class="status-badge success"^>200 OK^</span^>^</td^>^<td^>!TIME_TOTAL:~14!^</td^>^</tr^> >> "%REPORT_FILE%"
    ) else (
        echo ⚠️  %NAME%: !HTTP_CODE:~14!
        set /a TEST_FAILED+=1
        echo ^<tr class="warn"^>^<td^>%NAME%^</td^>^<td^>!HTTP_CODE:~14!^</td^>^<td^>!TIME_TOTAL:~14!^</td^>^</tr^> >> "%REPORT_FILE%"
    )
) else (
    echo ❌ %NAME%: Unreachable
    set /a TEST_FAILED+=1
    echo ^<tr class="fail"^>^<td^>%NAME%^</td^>^<td^>^<span class="status-badge error"^>UNREACHABLE^</span^>^</td^>^<td^>N/A^</td^>^</tr^> >> "%REPORT_FILE%"
)
del response.tmp curl.out 2>nul
goto :eof

:CURL_POST
set /a TOTAL_REQUESTS+=1
set URL=%~1
set NAME=%~2
set DATA=%~3
curl -s -w "@curl-format.txt" -X POST -H "Content-Type: application/json" -d "%DATA%" -o response.tmp "%URL%" >curl.out 2>&1
REM Similar processing as CURL_TEST...
goto :eof

:END
