@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo ============================================
echo CLOUDHUB ENDPOINT DIAGNOSTIC TOOL v2.0
echo ============================================
echo Timestamp: %date% %time%
echo.

REM Simple timestamp - NO WMIC
set "YEAR=%date:~10,4%"
set "MONTH=%date:~4,2%"
set "DAY=%date:~7,2%"
set "HOUR=%time:~0,2%"
if "%HOUR:~0,1%"==" " set "HOUR=0%HOUR:~1,1%"
set "MINUTE=%time:~3,2%"
set "SECOND=%time:~6,2%"
set REPORT_TIME=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%
set REPORT_FILE=cloudhub-diagnostic-%REPORT_TIME%.html
set TEST_PASSED=0
set TEST_FAILED=0

REM HTML Report Header
(
echo ^<html^>
echo ^<head^>
echo ^<meta charset="UTF-8"^>
echo ^<title^>CloudHub Endpoint Diagnostic Report^</title^>
echo ^<style^>
echo body{font-family:'Poppins',sans-serif;background:#f5f5f5;margin:20px}
echo .container{max-width:1000px;margin:auto;background:white;padding:30px;border-radius:10px;box-shadow:0 4px 12px rgba^(0,0,0,0.1^)}
echo h1{text-align:center;color:#2c3e50;font-size:2em}
echo h2{color:#34495e;border-bottom:2px solid #4CAF50;padding-bottom:10px}
echo .service-section{margin:20px 0;padding:20px;border-left:4px solid #ddd;border-radius:4px}
echo .healthy{border-left-color:#4CAF50;background:#f0f8f0}
echo .down{border-left-color:#f44336;background:#fdf2f2}
echo table{width:100%%;border-collapse:collapse;margin:15px 0}
echo th{background:#34495e;color:white;padding:10px}
echo td{padding:8px;border-bottom:1px solid #eee}
echo .endpoint-ok{color:#4CAF50;font-weight:bold}
echo .endpoint-fail{color:#f44336;font-weight:bold}
echo pre{background:#f8f9fa;padding:10px;border-radius:4px;font-size:12px;overflow:auto;max-height:200px}
echo .summary{padding:20px;background:#4CAF50;color:white;border-radius:8px;text-align:center;margin:20px 0}
echo ^</style^>
echo ^</head^>
echo ^<body^>
echo ^<div class="container"^>
echo ^<h1^>🔍 CloudHub Endpoint Diagnostic Report^</h1^>
echo ^<p^>Generated: %date% %time% ^| Host: %COMPUTERNAME%^</p^>
) > "%REPORT_FILE%"

echo 📊 Report will be saved: %REPORT_FILE%
echo.

REM Define endpoints using simple arrays
set ENDPOINTS[0]=http://agent-broker-mcp-server.us-e1.cloudhub.io
set ENDPOINTS[1]=http://employee-onboarding-mcp-server.us-e1.cloudhub.io
set ENDPOINTS[2]=http://asset-allocation-mcp-server.us-e1.cloudhub.io
set ENDPOINTS[3]=http://notification-mcp-server.us-e1.cloudhub.io

set NAMES[0]=Agent Broker MCP
set NAMES[1]=Employee Onboarding MCP
set NAMES[2]=Asset Allocation MCP
set NAMES[3]=Notification MCP

echo ============================================
echo PRIMARY ENDPOINT TESTS
echo ============================================

REM Test primary endpoints
for /L %%i in (0,1,3) do (
    call :TestService %%i
    echo.
)

echo ============================================
echo ALTERNATIVE ENDPOINT TESTS
echo ============================================

REM Test alternative naming patterns
call :TestAltEndpoint "http://employee-onboarding-agent-broker.us-e1.cloudhub.io" "Alt Agent Broker"
call :TestAltEndpoint "http://employee-onboarding-service.us-e1.cloudhub.io" "Alt Employee Service"
call :TestAltEndpoint "http://asset-allocation-service.us-e1.cloudhub.io" "Alt Asset Service"
call :TestAltEndpoint "http://employee-notification-service.us-e1.cloudhub.io" "Alt Notification"

REM Final summary
set /a SUCCESS_RATE=0
if !TEST_PASSED! gtr 0 set /a SUCCESS_RATE=!TEST_PASSED!*100/(!TEST_PASSED!+!TEST_FAILED!)

(
echo ^<div class="summary"^>
echo ^<h2^>📊 EXECUTIVE SUMMARY^</h2^>
echo ^<table^>
echo ^<tr^>^<td^>✅ Healthy Services^</td^>^<td^>!TEST_PASSED!^</td^>^</tr^>
echo ^<tr^>^<td^>❌ Down Services^</td^>^<td^>!TEST_FAILED!^</td^>^</tr^>
echo ^<tr^>^<td^>📈 Availability^</td^>^<td^>!SUCCESS_RATE!%%^</td^>^</tr^>
echo ^</table^>
) >> "%REPORT_FILE%"

if !TEST_FAILED! equ 0 (
    echo ^<p^>🎉 ALL SERVICES HEALTHY - PRODUCTION READY^</p^> >> "%REPORT_FILE%"
) else (
    echo ^<h3^>🚨 TROUBLESHOOTING STEPS^</h3^> >> "%REPORT_FILE%"
    echo ^<ul^> >> "%REPORT_FILE%"
    echo ^<li^>Check CloudHub Runtime Manager: ^<a href="https://anypoint.mulesoft.com/cloudhub/"^>Open Console^</a^>^</li^> >> "%REPORT_FILE%"
    echo ^<li^>Verify application names match deployed apps^</li^> >> "%REPORT_FILE%"
    echo ^<li^>Confirm us-e1 region deployment^</li^> >> "%REPORT_FILE%"
    echo ^<li^>Check application logs for startup errors^</li^> >> "%REPORT_FILE%"
    echo ^</ul^> >> "%REPORT_FILE%"
)
echo ^</div^>^</body^>^</html^> >> "%REPORT_FILE%"

echo.
echo ============================================
echo ✅ DIAGNOSTIC COMPLETE
echo ============================================
echo 📊 Report: %REPORT_FILE%
echo 📈 !TEST_PASSED! healthy, !TEST_FAILED! down (^(!SUCCESS_RATE!%% availability^)
start "" "%REPORT_FILE%"
pause
goto :eof

:TestService
set /a INDEX=%1
set "BASE_URL=!ENDPOINTS[%INDEX%]!"
set "SERVICE_NAME=!NAMES[%INDEX%]!"

echo --- Testing %SERVICE_NAME% ---
echo Base URL: !BASE_URL!

echo ^<div class="service-section"^>^<h2^>%SERVICE_NAME%^</h2^>^<p^>^<strong^>Base:^</strong^> !BASE_URL!^</p^> >> "%REPORT_FILE%"

REM Test 3 endpoints per service
call :TestEndpoint "!BASE_URL!" "%SERVICE_NAME% - Root" root_test
call :TestEndpoint "!BASE_URL!/health" "%SERVICE_NAME% - Health" health_test  
call :TestEndpoint "!BASE_URL!/mcp/info" "%SERVICE_NAME% - MCP Info" mcp_test

REM Check if service is healthy (any endpoint responds)
if !root_test! equ 1 (
    set /a TEST_PASSED+=1
    echo ^<p class="endpoint-ok"^>✅ SERVICE HEALTHY^</p^> >> "%REPORT_FILE%"
) else (
    set /a TEST_FAILED+=1
    echo ^<p class="endpoint-fail"^>❌ SERVICE DOWN^</p^> >> "%REPORT_FILE%"
)
echo ^</div^> >> "%REPORT_FILE%"
goto :eof

:TestEndpoint
set "URL=%~1"
set "NAME=%~2"
set "RESULT_VAR=%~3"

curl -s -f --max-time 8 "%URL%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo   ✅ !NAME!: OK
    set "!RESULT_VAR!=1"
    echo ^<p^>✅ !NAME!: ^<code^>!URL!^</code^> ^- OK^</p^> >> "%REPORT_FILE%"
) else (
    echo   ❌ !NAME!: DOWN
    set "!RESULT_VAR!=0"
    echo ^<p class="endpoint-fail"^>❌ !NAME!: ^<code^>!URL!^</code^> ^- DOWN^</p^> >> "%REPORT_FILE%"
)

REM Capture response preview for failed endpoints
if !ERRORLEVEL! neq 0 (
    curl -s --max-time 5 "%URL%" > diag_%RANDOM%.tmp 2>nul
    if exist diag_%RANDOM%.tmp (
        echo ^<details^>^<summary^>Diagnostic Response^</summary^>^<pre^> >> "%REPORT_FILE%"
        type diag_%RANDOM%.tmp >> "%REPORT_FILE%" 2>nul
        echo ^</pre^>^</details^> >> "%REPORT_FILE%"
        del diag_*.tmp 2>nul
    )
)
goto :eof

:TestAltEndpoint
set "ALT_URL=%~1"
set "ALT_NAME=%~2"

echo Testing %ALT_NAME%...
curl -s -f --max-time 8 "%ALT_URL%" >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo ✅ %ALT_NAME%: FOUND ^(!ALT_URL!^)
    echo ^<div class="service-section healthy"^> >> "%REPORT_FILE%"
    echo ^<h3^>🎯 ALTERNATIVE FOUND: %ALT_NAME%^</h3^> >> "%REPORT_FILE%"
    echo ^<p^>Working URL: ^<code^>%ALT_URL%^</code^>^</p^> >> "%REPORT_FILE%"
    echo ^</div^> >> "%REPORT_FILE%"
    set /a TEST_PASSED+=1
) else (
    echo ❌ %ALT_NAME%: NOT FOUND
)
goto :eof
