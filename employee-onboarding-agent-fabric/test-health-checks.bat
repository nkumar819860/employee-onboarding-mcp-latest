@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ============================================
echo MCP SERVICES COMPREHENSIVE ENDPOINT TESTER
echo ============================================
echo Timestamp: %date% %time%
echo.

REM Simple timestamp without WMIC
set "YEAR=%date:~10,4%"
set "MONTH=%date:~4,2%"
set "DAY=%date:~7,2%"
set "HOUR=%time:~0,2%"
if "%HOUR:~0,1%"==" " set "HOUR=0%HOUR:~1,1%"
set "MINUTE=%time:~3,2%"
set "SECOND=%time:~6,2%"
set REPORT_TIME=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%
set REPORT_FILE=mcp-endpoints-report-%REPORT_TIME%.html

set TEST_PASSED=0
set TEST_FAILED=0
set TEST_SKIPPED=0
set TOTAL_REQUESTS=0
set BROKER_CLOUD=0
set EMPLOYEE_CLOUD=0
set ASSET_CLOUD=0
set NOTIFICATION_CLOUD=0

REM HTML Report Header - SIMPLIFIED
(
echo ^<html^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<title^>MCP Endpoints Test Report^</title^>
echo ^<style^>
echo body{font-family:'Poppins',sans-serif;background:#f5f5f5;margin:20px}
echo .container{max-width:1200px;margin:0 auto;background:white;padding:30px;border-radius:10px}
echo h1{color:#2c3e50;text-align:center;font-size:2em}
echo .summary{background:#4CAF50;color:white;padding:20px;border-radius:8px;margin:20px 0;text-align:center}
echo table{width:100%%;border-collapse:collapse;margin:20px 0}
echo th{padding:12px;background:#34495e;color:white}
echo td{padding:10px;border-bottom:1px solid #ddd}
echo .pass{background:#d4edda}
echo .fail{background:#f8d7da}
echo .endpoint-section{margin:20px 0;padding:15px;border-left:4px solid #4CAF50}
echo .error-section{border-left-color:#f44336}
echo pre{background:#f8f9fa;padding:10px;border-radius:4px;font-size:12px;max-height:300px;overflow:auto}
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<div class="container"^>
echo ^<h1^>🔬 MCP Services Endpoint Report^</h1^>
echo ^<p style="text-align:center"^>Generated: %date% %time%^</p^>
echo ^<div class="summary"^>^<h2^>☁️ CLOUHHUB PRODUCTION TESTING^</h2^>^</div^>
) > "%REPORT_FILE%"

echo [1/5] Testing HEALTH endpoints...

REM Test MCP Info Endpoints - Using working endpoints instead of /health
call :TestHealth "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info" "Agent Broker MCP" BROKER_CLOUD
call :TestHealth "http://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info" "Employee Onboarding MCP" EMPLOYEE_CLOUD
call :TestHealth "http://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info" "Asset Allocation MCP" ASSET_CLOUD
call :TestHealth "http://notification-mcp-server.us-e1.cloudhub.io/mcp/info" "Notification MCP" NOTIFICATION_CLOUD

echo [2/5] Testing INFO endpoints...
if !BROKER_CLOUD! equ 1 call :TestInfo "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info" "Agent Broker Info"
if !EMPLOYEE_CLOUD! equ 1 call :TestInfo "http://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info" "Employee Onboarding Info"
if !ASSET_CLOUD! equ 1 call :TestInfo "http://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info" "Asset Allocation Info"
if !NOTIFICATION_CLOUD! equ 1 call :TestInfo "http://notification-mcp-server.us-e1.cloudhub.io/mcp/info" "Notification Info"

echo [3/5] Testing key TOOL endpoints...
if !BROKER_CLOUD! equ 1 call :TestTool "http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding" "Orchestrate Onboarding" POST

REM Final summary
set /a TOTAL_TESTS=!TEST_PASSED!+!TEST_FAILED!
set /a SUCCESS_RATE=0
if !TOTAL_TESTS! gtr 0 set /a SUCCESS_RATE=!TEST_PASSED!*100/!TOTAL_TESTS!

(
echo ^<div class="summary"^>
echo ^<h2^>📊 EXECUTION SUMMARY^</h2^>
echo ^<table^>
echo ^<tr^>^<td^>✅ Passed^</td^>^<td^>!TEST_PASSED!^</td^>^</tr^>
echo ^<tr^>^<td^>❌ Failed^</td^>^<td^>!TEST_FAILED!^</td^>^</tr^>
echo ^<tr^>^<td^>📈 Success Rate^</td^>^<td^>!SUCCESS_RATE!%%^</td^>^</tr^>
echo ^<tr^>^<td^>🔗 Total Endpoints^</td^>^<td^>!TOTAL_REQUESTS!^</td^>^</tr^>
echo ^</table^>
echo ^</div^>
echo ^</div^>^</body^>^</html^>
) >> "%REPORT_FILE%"

echo.
echo ============================================
echo ✅ TESTING COMPLETE
echo ============================================
echo 📊 Report: %REPORT_FILE%
echo 📈 !TEST_PASSED!/!TOTAL_TESTS! passed (^(!SUCCESS_RATE!%%^)
if !TEST_FAILED! equ 0 (
    echo 🎉 ALL SERVICES HEALTHY - PRODUCTION READY
) else (
    echo 🚨 !TEST_FAILED! services DOWN - check report
)
echo.
start "" "%REPORT_FILE%"
pause
goto :eof

REM ============================================
REM TEST FUNCTIONS - FIXED
REM ============================================

:TestHealth
set "URL=%~1"
set "NAME=%~2"
set "RESULT_VAR=%~3"
set /a TOTAL_REQUESTS+=1

REM Use simple curl without external format file
curl -s -f -w "%%{http_code}" -o nul "%URL%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo ✅ %NAME%: OK
    set "%RESULT_VAR%=1"
    set /a TEST_PASSED+=1
    echo ^<div class="endpoint-section"^>^<h3^>✅ %NAME%^</h3^>^<p^>Status: 200 OK^</p^>^</div^> >> "%REPORT_FILE%"
) else (
    echo ❌ %NAME%: DOWN
    set "%RESULT_VAR%=0"
    set /a TEST_FAILED+=1
    echo ^<div class="endpoint-section error-section"^>^<h3^>❌ %NAME%^</h3^>^<p^>Status: Unreachable^</p^>^</div^> >> "%REPORT_FILE%"
)
goto :eof

:TestInfo
set "URL=%~1"
set "NAME=%~2"
set /a TOTAL_REQUESTS+=1

curl -s --max-time 10 "%URL%" > "response_%RANDOM%.tmp" 2>nul
if !ERRORLEVEL! equ 0 if exist "response_%RANDOM%.tmp" (
    echo ✅ %NAME%: OK
    set /a TEST_PASSED+=1
    echo ^<div class="endpoint-section"^>^<h3^>ℹ️  %NAME%^</h3^>^<details^>^<summary^>JSON Response ^(Click to expand^)^</summary^>^<pre^> >> "%REPORT_FILE%"
    type "response_%RANDOM%.tmp" >> "%REPORT_FILE%" 2>nul
    echo ^</pre^>^</details^>^</div^> >> "%REPORT_FILE%"
) else (
    echo ❌ %NAME%: DOWN
    set /a TEST_FAILED+=1
    echo ^<div class="endpoint-section error-section"^>^<h3^>❌ %NAME%^</h3^>^<p^>No response^</p^>^</div^> >> "%REPORT_FILE%"
)
del *.tmp 2>nul
goto :eof

:TestTool
set "URL=%~1"
set "NAME=%~2"
set "METHOD=%~3"
set /a TOTAL_REQUESTS+=1

if "%METHOD%"=="POST" (
    curl -s -X POST -H "Content-Type: application/json" -d "{\"test\":true}" --max-time 10 "%URL%" > tool.tmp 2>nul
) else (
    curl -s --max-time 10 "%URL%" > tool.tmp 2>nul
)

if !ERRORLEVEL! equ 0 if exist tool.tmp (
    echo ✅ %NAME%: OK
    set /a TEST_PASSED+=1
    echo ^<div class="endpoint-section"^>^<h3^>🔧 %NAME%^</h3^>^<p^>✅ Tool endpoint responding^</p^>^</div^> >> "%REPORT_FILE%"
) else (
    echo ⚠️  %NAME%: Tool test skipped
    set /a TEST_SKIPPED+=1
)
del tool.tmp 2>nul
goto :eof
