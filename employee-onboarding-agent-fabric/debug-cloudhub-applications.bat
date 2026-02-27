@echo off
setlocal enabledelayedexpansion

echo ========================================================================
echo 🔍 CLOUDHUB APPLICATION DEBUGGING SUITE
echo ========================================================================
echo This script helps diagnose CloudHub application startup issues
echo.

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

REM Load environment variables
if exist .env (
    echo [INFO] Loading environment variables...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" (
            set "%%a=%%b"
        )
    )
    echo [SUCCESS] Environment variables loaded
) else (
    echo [WARNING] .env file not found
)

echo.
echo ========================================================================
echo STEP 1: APPLICATION STATUS CHECK
echo ========================================================================

echo [INFO] Checking application status in CloudHub Runtime Manager...

REM Define applications to check
set APPS=agent-broker-mcp-server employee-onboarding-mcp-server asset-allocation-mcp-server notification-mcp-server

for %%A in (%APPS%) do (
    echo.
    echo [INFO] Checking %%A status...
    
    REM Check if anypoint CLI is available
    anypoint-cli --version > nul 2>&1
    if !ERRORLEVEL! equ 0 (
        if defined ANYPOINT_USERNAME (
            echo   Logging in to Anypoint Platform...
            anypoint-cli auth login --username "!ANYPOINT_USERNAME!" --password "!ANYPOINT_PASSWORD!" --organization "!ANYPOINT_ORG_ID!" > nul 2>&1
            
            if !ERRORLEVEL! equ 0 (
                echo   Getting application status...
                anypoint-cli runtime-mgr cloudhub-application describe --environment "!ANYPOINT_ENV!" --output json "%%A" > temp_app_status.json 2>&1
                
                if !ERRORLEVEL! equ 0 (
                    echo   [SUCCESS] %%A status retrieved
                    findstr /C:"status" temp_app_status.json
                    findstr /C:"lastUpdateTime" temp_app_status.json
                    findstr /C:"workerLogLevel" temp_app_status.json
                ) else (
                    echo   [ERROR] Failed to get %%A status
                    type temp_app_status.json 2>nul
                )
            ) else (
                echo   [ERROR] Failed to authenticate with Anypoint Platform
            )
        ) else (
            echo   [SKIP] ANYPOINT_USERNAME not configured, skipping CLI check
        )
    ) else (
        echo   [SKIP] Anypoint CLI not available
    )
    
    REM Check basic HTTP connectivity
    echo   Testing HTTP connectivity to %%A...
    curl -s --connect-timeout 10 --max-time 30 -w "HTTP Status: %%{http_code} | Response Time: %%{time_total}s" https://%%A.us-e1.cloudhub.io/health -o temp_response.txt 2>&1
    echo.
    
    REM Try different endpoints
    echo   Testing root endpoint...
    curl -s --connect-timeout 10 --max-time 30 -w "HTTP Status: %%{http_code}" https://%%A.us-e1.cloudhub.io/ 2>&1
    echo.
    
    if exist temp_app_status.json del temp_app_status.json
    if exist temp_response.txt del temp_response.txt
)

echo.
echo ========================================================================
echo STEP 2: COMMON CLOUDHUB ISSUES DIAGNOSIS
echo ========================================================================

echo [INFO] Analyzing common CloudHub startup issues...
echo.

echo [CHECK 1] Application Configuration Issues:
echo   • Verify Mule runtime version compatibility
echo   • Check if applications have proper HTTP listeners configured
echo   • Ensure database connections (if any) are properly configured
echo   • Verify all required properties are set
echo.

echo [CHECK 2] Resource and Memory Issues:
echo   • MICRO workers have limited memory (256MB)
echo   • Applications may need more memory to start
echo   • Check if applications are trying to load large datasets on startup
echo.

echo [CHECK 3] CloudHub Endpoint Configuration:
echo   • Applications should listen on 0.0.0.0:${mule.http.port} or 0.0.0.0:8081
echo   • CloudHub automatically sets mule.http.port
echo   • Verify HTTP listeners are properly configured
echo.

echo [CHECK 4] Startup Dependencies:
echo   • Check if applications depend on external services during startup
echo   • Database connectivity issues
echo   • External API calls during initialization
echo.

echo ========================================================================
echo STEP 3: DETAILED LOG ANALYSIS (if CLI available)
echo ========================================================================

if defined ANYPOINT_USERNAME (
    for %%A in (%APPS%) do (
        echo.
        echo [INFO] Getting logs for %%A...
        anypoint-cli runtime-mgr cloudhub-application logs --environment "!ANYPOINT_ENV!" --limit 50 "%%A" 2>&1
        echo ----------------------------------------
    )
) else (
    echo [SKIP] Anypoint credentials not configured for log retrieval
    echo.
    echo Manual log check instructions:
    echo 1. Go to https://anypoint.mulesoft.com/cloudhub/
    echo 2. Select your application
    echo 3. Go to Logs tab
    echo 4. Look for startup errors, especially:
    echo    - OutOfMemoryError
    echo    - ClassNotFoundException  
    echo    - Connection refused errors
    echo    - HTTP listener binding issues
)

echo.
echo ========================================================================
echo STEP 4: RECOMMENDED FIXES
echo ========================================================================

echo.
echo 💡 IMMEDIATE TROUBLESHOOTING STEPS:
echo.
echo [FIX 1] Check HTTP Listener Configuration:
echo   • Verify global.xml has proper HTTP listener config
echo   • Should use host="0.0.0.0" port="${mule.http.port}"
echo   • CloudHub sets mule.http.port automatically
echo.
echo [FIX 2] Increase Worker Size (if memory issues):
echo   • MICRO workers have only 256MB RAM
echo   • Consider upgrading to 0.1 vCore (1GB RAM) or higher
echo   • Update CLOUDHUB_WORKER_TYPE in .env file
echo.
echo [FIX 3] Simplify Application Startup:
echo   • Remove complex startup processes
echo   • Defer database connections until first request
echo   • Remove heavy initialization logic
echo.
echo [FIX 4] Check CloudHub Application Properties:
echo   • Ensure applications don't hardcode localhost URLs
echo   • Use CloudHub-provided environment variables
echo   • Verify SSL/TLS configurations
echo.

echo ========================================================================
echo STEP 5: QUICK FIXES TO TRY
echo ========================================================================

echo.
echo 🚀 QUICK FIXES YOU CAN IMPLEMENT NOW:
echo.

echo [QUICK FIX 1] Update Worker Size:
echo   Edit .env file and change:
echo   CLOUDHUB_WORKER_TYPE=MICRO
echo   to:
echo   CLOUDHUB_WORKER_TYPE=0.1
echo   Then redeploy: .\deploy.bat
echo.

echo [QUICK FIX 2] Add Health Check Endpoint:
echo   Create a simple health endpoint that returns HTTP 200
echo   Example Mule flow that always returns "OK"
echo.

echo [QUICK FIX 3] Check HTTP Listener in global.xml:
echo   Should look like:
echo   ^<http:listener-config name="HTTP_Listener_Configuration" 
echo                        host="0.0.0.0" 
echo                        port="${mule.http.port}" 
echo                        protocol="HTTP"/^>
echo.

echo [QUICK FIX 4] Verify Application Names:
echo   Ensure CloudHub application names match expectations:
for %%A in (%APPS%) do (
    echo   - %%A
)

echo.
echo ========================================================================
echo STEP 6: MANUAL VERIFICATION STEPS
echo ========================================================================

echo.
echo 📋 MANUAL STEPS TO VERIFY IN CLOUDHUB CONSOLE:
echo.
echo 1. Open CloudHub Runtime Manager:
echo    https://anypoint.mulesoft.com/cloudhub/
echo.
echo 2. For each application, check:
echo    ✓ Status should be "Started" (not "Failed" or "Starting")
echo    ✓ Last update time should be recent
echo    ✓ No error indicators in the dashboard
echo.
echo 3. Click on each application and verify:
echo    ✓ Properties are properly set
echo    ✓ Worker size is appropriate
echo    ✓ Runtime version is compatible
echo.
echo 4. Check application logs for:
echo    ✗ OutOfMemoryError
echo    ✗ Port binding failures
echo    ✗ ClassNotFoundException
echo    ✗ Connection refused errors
echo    ✗ SSL/TLS handshake failures
echo.

echo ========================================================================
echo 🎯 NEXT STEPS RECOMMENDATION
echo ========================================================================

echo.
echo Based on HTTP 504 errors, the most likely issues are:
echo.
echo 1️⃣  MEMORY ISSUES (Most Common)
echo    └─ MICRO workers (256MB) may be insufficient
echo    └─ Try: Set CLOUDHUB_WORKER_TYPE=0.1 in .env and redeploy
echo.
echo 2️⃣  HTTP LISTENER CONFIGURATION
echo    └─ Applications not listening on correct host/port
echo    └─ Check: global.xml HTTP listener configuration
echo.
echo 3️⃣  STARTUP FAILURES
echo    └─ Applications failing to start due to dependencies
echo    └─ Check: CloudHub logs for startup errors
echo.

echo To fix the immediate issue:
echo 1. Update .env: CLOUDHUB_WORKER_TYPE=0.1
echo 2. Run: .\deploy.bat
echo 3. Wait 5 minutes for deployment
echo 4. Run: .\run-cloudhub-tests.bat
echo.

echo ========================================================================
echo 🏁 CLOUDHUB DEBUGGING COMPLETED
echo ========================================================================

echo.
echo Press any key to continue...
pause >nul
