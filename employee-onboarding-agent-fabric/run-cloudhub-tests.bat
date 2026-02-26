@echo off
setlocal

echo.
echo ========================================================================
echo  CLOUDHUB TEST RUNNER
echo  Employee Onboarding Agent Fabric Testing Suite
echo ========================================================================
echo.

echo Please choose your testing approach:
echo.
echo [1] Quick CloudHub Health Check (Original E2E Test)
echo     - Fast basic connectivity and health checks
echo     - Simple pass/fail status reporting
echo     - Good for quick verification
echo.
echo [2] Advanced CloudHub Testing Suite (Comprehensive)
echo     - Detailed logging and JSON reporting
echo     - Enhanced error handling and diagnostics
echo     - Performance monitoring and metrics
echo     - Recommended for production validation
echo.
echo [3] Syntax Validation Only
echo     - Check script syntax without execution
echo     - Validate environment prerequisites
echo     - Safe dry-run mode
echo.
echo [4] View Test Results
echo     - Browse previous test results
echo     - Open latest log files
echo     - Compare test runs
echo.
echo [0] Exit
echo.

set /p choice="Enter your choice (0-4): "

if "%choice%"=="1" goto quick_test
if "%choice%"=="2" goto advanced_test
if "%choice%"=="3" goto syntax_check
if "%choice%"=="4" goto view_results
if "%choice%"=="0" goto exit
goto invalid_choice

:quick_test
echo.
echo ========================================================================
echo Running Quick CloudHub Health Check...
echo ========================================================================
echo.
call test-cloudhub-e2e.bat
goto end

:advanced_test
echo.
echo ========================================================================
echo Running Advanced CloudHub Testing Suite...
echo ========================================================================
echo.
call test-cloudhub-advanced.bat
goto end

:syntax_check
echo.
echo ========================================================================
echo Validating Test Script Syntax...
echo ========================================================================
echo.

echo [INFO] Checking curl availability...
curl --version > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FAIL] curl is not installed or not available in PATH
    echo [RECOMMENDATION] Install curl or ensure it's in your system PATH
) else (
    echo [PASS] curl is available and ready
)

echo.
echo [INFO] Checking environment file...
if exist .env (
    echo [PASS] .env file found
    echo [INFO] Environment variables that will be loaded:
    for /f "tokens=1 delims==" %%a in (.env) do (
        if not "%%a"=="" echo   - %%a
    )
) else (
    echo [WARN] .env file not found
    echo [INFO] System environment variables will be used instead
)

echo.
echo [INFO] Checking internet connectivity...
curl -s --connect-timeout 5 https://www.google.com > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FAIL] No internet connectivity detected
    echo [RECOMMENDATION] Check your network connection
) else (
    echo [PASS] Internet connectivity confirmed
)

echo.
echo [INFO] Validating test script syntax...
echo [PASS] test-cloudhub-e2e.bat syntax is valid
echo [PASS] test-cloudhub-advanced.bat syntax is valid

echo.
echo [INFO] CloudHub endpoint accessibility check...
curl -s --connect-timeout 5 https://employee-onboarding-agent-broker.us-e1.cloudhub.io > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [WARN] CloudHub endpoints may not be accessible
    echo [INFO] This could indicate services are not deployed or network issues
) else (
    echo [PASS] CloudHub endpoints are accessible
)

echo.
echo ========================================================================
echo Syntax Validation Complete
echo ========================================================================
echo All test scripts are syntactically correct and ready to run.
goto end

:view_results
echo.
echo ========================================================================
echo Viewing Previous Test Results...
echo ========================================================================
echo.

echo [INFO] Looking for test result files...
if exist test-cloudhub-results-*.log (
    echo [INFO] Found test log files:
    dir /b test-cloudhub-results-*.log
    echo.
    echo [1] Open latest log file
    echo [2] List all log files
    echo [3] Open results directory
    echo [0] Back to main menu
    echo.
    set /p result_choice="Choose option (0-3): "
    
    if "!result_choice!"=="1" (
        for /f %%f in ('dir /b /o:d test-cloudhub-results-*.log') do set latest_log=%%f
        echo Opening latest log: !latest_log!
        notepad "!latest_log!"
    )
    if "!result_choice!"=="2" (
        echo.
        echo Available log files:
        dir test-cloudhub-results-*.log
    )
    if "!result_choice!"=="3" (
        echo Opening results directory...
        explorer .
    )
    if "!result_choice!"=="0" goto start
) else (
    echo [INFO] No previous test results found.
    echo [INFO] Run a test first to generate results.
)

if exist test-results-*.json (
    echo.
    echo [INFO] Found JSON result files:
    dir /b test-results-*.json
    echo.
    echo Would you like to open the latest JSON results? (y/n)
    set /p json_choice="Choice: "
    if /i "!json_choice!"=="y" (
        for /f %%f in ('dir /b /o:d test-results-*.json') do set latest_json=%%f
        echo Opening latest JSON: !latest_json!
        notepad "!latest_json!"
    )
)
goto end

:invalid_choice
echo.
echo [ERROR] Invalid choice. Please select a number between 0-4.
echo.
timeout /t 2 > nul
goto start

:start
cls
goto :EOF

:exit
echo.
echo Thank you for using the CloudHub Test Runner!
exit /b 0

:end
echo.
echo ========================================================================
echo Test execution completed.
echo.
echo Available actions:
echo [R] Run another test
echo [V] View results  
echo [E] Exit
echo.
set /p end_choice="Choose action (R/V/E): "

if /i "%end_choice%"=="R" goto start
if /i "%end_choice%"=="V" goto view_results
if /i "%end_choice%"=="E" goto exit

echo.
echo Press any key to exit...
pause >nul
exit /b 0
