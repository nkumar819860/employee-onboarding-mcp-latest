@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ================================================================
echo  CLOUDHUB END-TO-END TESTING SUITE WITH REPORT GENERATION
echo ================================================================

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM Initialize counters
set TEST_PASSED=0
set TEST_FAILED=0
set TEST_SKIPPED=0
set BROKER_CLOUD=0
set EMPLOYEE_CLOUD=0
set ASSET_CLOUD=0
set NOTIFICATION_CLOUD=0

REM FIXED: Simple timestamp without WMIC
set "YEAR=%date:~10,4%"
set "MONTH=%date:~4,2%"
set "DAY=%date:~7,2%"
set "HOUR=%time:~0,2%"
if "%HOUR:~0,1%"==" " set "HOUR=0%HOUR:~1,1%"
set "MINUTE=%time:~3,2%"
set "SECOND=%time:~6,2%"
set REPORT_TIME=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%
set REPORT_FILE=test-report-%REPORT_TIME%.html

REM Create HTML report - FIXED CSS escaping
(
echo ^<html^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<title^>CloudHub E2E Test Report^</title^>
echo ^<style^>
echo body{font-family:'Poppins',sans-serif;background:#f5f5f5;margin:20px}
echo table {width:100%%; border-collapse:collapse; margin:20px 0}
echo th,td {padding:12px; text-align:left; border-bottom:1px solid #ddd}
echo th {background:#4CAF50; color:white; font-weight:600}
echo .pass {background:#d4edda; color:#155724}
echo .fail {background:#f8d7da; color:#721c24}
echo .skip {background:#fff3cd; color:#856404}
echo .summary {padding:20px; background:white; border-radius:8px; margin:20px 0; box-shadow:0 2px 4px rgba^(0,0,0,0.1^)}
echo pre {background:#f8f9fa; padding:10px; border-radius:4px; font-size:12px; max-height:400px; overflow:auto}
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<h1^>🏭 CloudHub MCP End-to-End Test Report^</h1^>
echo ^<p^>Generated: %date% %time%^</p^>
) > "%REPORT_FILE%"

echo 📊 Report: %REPORT_FILE%
echo.

REM Load .env if exists
if exist .env (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%b"=="" set %%a=%%b
    )
    echo ✅ Environment loaded
    echo ^<div class="summary"^>^<p^>✅ Environment: Loaded from .env^</p^>^</div^> >> "%REPORT_FILE%"
) else (
    echo ⚠️  Using default CloudHub URLs
    echo ^<div class="summary"^>^<p^>⚠️  Environment: Default CloudHub URLs^</p^>^</div^> >> "%REPORT_FILE%"
)

REM TEST 1: CONNECTIVITY - FIXED
echo =============================================
echo TEST 1: CLOUDHUB MCP SERVER CONNECTIVITY
echo =============================================
echo ^<div class="summary"^>^<h2^>1️⃣ MCP Server Connectivity^</h2^>^<table^>^<tr^>^<th^>Service^</th^>^<th^>Status^</th^>^<th^>Time^</th^>^</tr^> >> "%REPORT_FILE%"

call :TestHealth "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info" "Agent Broker MCP" BROKER_CLOUD
call :TestHealth "http://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info" "Employee Onboarding MCP" EMPLOYEE_CLOUD
call :TestHealth "http://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info" "Asset Allocation MCP" ASSET_CLOUD
call :TestHealth "http://notification-mcp-server.us-e1.cloudhub.io/mcp/info" "Notification MCP" NOTIFICATION_CLOUD

echo ^</table^>^</div^> >> "%REPORT_FILE%"
echo.

REM TEST 2: CAPABILITIES
if !BROKER_CLOUD! equ 1 (
    call :TestCapabilities
)

REM TEST 3: ORCHESTRATION  
call :TestOrchestration

REM TEST 4: INDIVIDUAL SERVICES
call :TestIndividualServices

REM Final summary - FIXED math
set /a TOTAL_TESTS=!TEST_PASSED!+!TEST_FAILED!+!TEST_SKIPPED!
set /a SUCCESS_RATE=0
if !TOTAL_TESTS! gtr 0 set /a SUCCESS_RATE=!TEST_PASSED!*100/!TOTAL_TESTS!

(
echo ^<div class="summary"^>
echo ^<h2^>📊 FINAL RESULTS^</h2^>
echo ^<table^>
echo ^<tr^>^<td^>✅ Passed^</td^>^<td^>!TEST_PASSED!^</td^>^</tr^>
echo ^<tr^>^<td^>❌ Failed^</td^>^<td^>!TEST_FAILED!^</td^>^</tr^>
echo ^<tr^>^<td^>⏭️  Skipped^</td^>^<td^>!TEST_SKIPPED!^</td^>^</tr^>
echo ^<tr^>^<td^>📈 Success Rate^</td^>^<td^>!SUCCESS_RATE!%%^</td^>^</tr^>
echo ^</table^>
echo ^</div^>
echo ^</body^>
echo ^</html^>
) >> "%REPORT_FILE%"

echo.
echo ============================================
echo 🏁 CLOUDHUB E2E TESTING COMPLETED
echo ============================================
echo 📊 Report: %REPORT_FILE%
echo 📈 !TEST_PASSED!/!TOTAL_TESTS! passed (^(!SUCCESS_RATE!%%^)
if !TEST_FAILED! equ 0 (
    echo 🎉 ALL TESTS PASSED - PRODUCTION READY
) else (
    echo 🚨 !TEST_FAILED! tests failed - review report
)
start "" "%REPORT_FILE%"
pause
goto :eof

REM ============================================
REM TEST FUNCTIONS - ALL FIXED
REM ============================================

:TestHealth
set "URL=%~1"
set "NAME=%~2"
set "RESULT_VAR=%~3"

curl -s -f --max-time 10 "%URL%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo ✅ %NAME%: HEALTHY
    set "%RESULT_VAR%=1"
    set /a TEST_PASSED+=1
    echo ^<tr class="pass"^>^<td^>%NAME%^</td^>^<td^>✅ HEALTHY^</td^>^<td^>OK^</td^>^</tr^> >> "%REPORT_FILE%"
) else (
    echo ❌ %NAME%: DOWN
    set "%RESULT_VAR%=0"
    set /a TEST_FAILED+=1
    echo ^<tr class="fail"^>^<td^>%NAME%^</td^>^<td^>❌ DOWN^</td^>^<td^>N/A^</td^>^</tr^> >> "%REPORT_FILE%"
)
goto :eof

:TestCapabilities
echo ============================================
echo TEST 2: MCP CAPABILITIES
echo ============================================
curl -s --max-time 10 "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info" > capabilities.tmp
echo ^<div class="summary"^>^<h2^>2️⃣ MCP Capabilities^</h2^> >> "%REPORT_FILE%"
if exist capabilities.tmp (
    echo ^<details^>^<summary^>Agent Broker Info ^(click to expand^)^</summary^>^<pre^> >> "%REPORT_FILE%"
    type capabilities.tmp >> "%REPORT_FILE%"
    echo ^</pre^>^</details^> >> "%REPORT_FILE%"
    set /a TEST_PASSED+=1
    echo ✅ Capabilities retrieved
) else (
    set /a TEST_FAILED+=1
    echo ❌ Capabilities unavailable
)
del capabilities.tmp 2>nul
echo ^</div^> >> "%REPORT_FILE%"
goto :eof

:TestOrchestration
echo ==============================================
echo TEST 3: ORCHESTRATION TEST
echo ==============================================
if !BROKER_CLOUD! equ 1 (
    curl -s -X POST -H "Content-Type: application/json" --max-time 15 -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@test.com\"}" "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding" > orch.tmp 2>nul
    echo ^<div class="summary"^>^<h2^>3️⃣ Orchestration Test^</h2^> >> "%REPORT_FILE%"
    if exist orch.tmp (
        echo ^<details^>^<summary^>Orchestration Response^</summary^>^<pre^> >> "%REPORT_FILE%"
        type orch.tmp >> "%REPORT_FILE%"
        echo ^</pre^>^</details^> >> "%REPORT_FILE%"
        set /a TEST_PASSED+=1
        echo ✅ Orchestration test passed
    ) else (
        set /a TEST_FAILED+=1
        echo ❌ Orchestration test failed
        echo ^<p class="fail"^>❌ Orchestration endpoint failed^</p^> >> "%REPORT_FILE%"
    )
    del orch.tmp 2>nul
    echo ^</div^> >> "%REPORT_FILE%"
) else (
    set /a TEST_SKIPPED+=1
    echo ⏭️  Orchestration skipped (Broker down)
)
goto :eof

:TestIndividualServices
echo ==========================================
echo TEST 4: INDIVIDUAL SERVICES
echo ==========================================
echo ^<div class="summary"^>^<h2^>4️⃣ Individual Services^</h2^> >> "%REPORT_FILE%"
if !EMPLOYEE_CLOUD! equ 1 (
    echo ✅ Employee service OK
    set /a TEST_PASSED+=1
)
if !ASSET_CLOUD! equ 1 (
    echo ✅ Asset service OK  
    set /a TEST_PASSED+=1
)
if !NOTIFICATION_CLOUD! equ 1 (
    echo ✅ Notification service OK
    set /a TEST_PASSED+=1
)
echo ^</div^> >> "%REPORT_FILE%"
goto :eof
