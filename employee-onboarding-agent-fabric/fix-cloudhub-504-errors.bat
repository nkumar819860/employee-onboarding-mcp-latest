@echo off
setlocal enabledelayedexpansion

echo ========================================================================
echo 🚀 QUICK FIX FOR CLOUDHUB HTTP 504 ERRORS
echo ========================================================================
echo This script applies the most common fixes for CloudHub 504 timeout errors
echo.

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [INFO] HTTP 504 errors usually indicate applications are deployed but not responding
echo [INFO] Most common causes: Memory issues, HTTP listener config, startup failures
echo.

echo ========================================================================
echo STEP 1: UPDATE WORKER SIZE (MOST COMMON FIX)
echo ========================================================================

echo [INFO] Checking current worker configuration in .env file...

if exist .env (
    findstr /C:"CLOUDHUB_WORKER_TYPE" .env
    if !ERRORLEVEL! equ 0 (
        echo [INFO] Found CLOUDHUB_WORKER_TYPE configuration
    ) else (
        echo [INFO] CLOUDHUB_WORKER_TYPE not found in .env, adding it...
        echo CLOUDHUB_WORKER_TYPE=0.1 >> .env
        echo [SUCCESS] Added CLOUDHUB_WORKER_TYPE=0.1 to .env
    )
) else (
    echo [ERROR] .env file not found!
    echo [INFO] Creating .env file with basic CloudHub configuration...
    echo # CloudHub Configuration > .env
    echo CLOUDHUB_WORKER_TYPE=0.1 >> .env
    echo CLOUDHUB_WORKERS=1 >> .env
    echo CLOUDHUB_REGION=us-east-1 >> .env
    echo ANYPOINT_ENV=Sandbox >> .env
    echo.
    echo [WARNING] Please add your Anypoint Platform credentials to .env:
    echo   ANYPOINT_CLIENT_ID=your_client_id
    echo   ANYPOINT_CLIENT_SECRET=your_client_secret
    echo   ANYPOINT_ORG_ID=your_org_id
    echo   ANYPOINT_USERNAME=your_username
    echo   ANYPOINT_PASSWORD=your_password
    pause
    exit /b 1
)

echo.
echo [INFO] Updating .env to use 0.1 vCore workers (1GB RAM) instead of MICRO (256MB)...

REM Update CLOUDHUB_WORKER_TYPE to 0.1 vCore
powershell -Command ^
    "$content = Get-Content '.env' -Raw; ^
     $content = $content -replace 'CLOUDHUB_WORKER_TYPE=MICRO', 'CLOUDHUB_WORKER_TYPE=0.1'; ^
     $content = $content -replace 'CLOUDHUB_WORKER_TYPE=micro', 'CLOUDHUB_WORKER_TYPE=0.1'; ^
     if ($content -notmatch 'CLOUDHUB_WORKER_TYPE=0.1') { ^
         if ($content -match 'CLOUDHUB_WORKER_TYPE=') { ^
             $content = $content -replace 'CLOUDHUB_WORKER_TYPE=[^`r`n]*', 'CLOUDHUB_WORKER_TYPE=0.1'; ^
         } else { ^
             $content = $content + [Environment]::NewLine + 'CLOUDHUB_WORKER_TYPE=0.1'; ^
         } ^
     } ^
     Set-Content '.env' $content -NoNewline"

echo [SUCCESS] Updated worker type to 0.1 vCore (1GB RAM)
echo.

echo Current .env configuration:
findstr /C:"CLOUDHUB_" .env
echo.

echo ========================================================================
echo STEP 2: CHECK AND FIX HTTP LISTENER CONFIGURATIONS
echo ========================================================================

echo [INFO] Checking HTTP listener configurations in Mule flows...

set HTTP_CONFIG_ISSUES=0

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\src\main\mule\global.xml" (
        echo [INFO] Checking %%d HTTP listener configuration...
        
        REM Check if global.xml has proper HTTP listener config
        findstr /C:"host.*0.0.0.0" "%%d\src\main\mule\global.xml" > nul
        if !ERRORLEVEL! neq 0 (
            echo [WARNING] %%d may not have proper host configuration (should be 0.0.0.0)
            set /a HTTP_CONFIG_ISSUES+=1
        ) else (
            echo [PASS] %%d has proper host configuration
        )
        
        REM Check if it uses ${mule.http.port}
        findstr /C:"mule.http.port" "%%d\src\main\mule\global.xml" > nul
        if !ERRORLEVEL! neq 0 (
            echo [WARNING] %%d may not use ${mule.http.port} (required for CloudHub)
            set /a HTTP_CONFIG_ISSUES+=1
        ) else (
            echo [PASS] %%d uses mule.http.port variable
        )
    ) else (
        echo [WARNING] %%d does not have global.xml file
        set /a HTTP_CONFIG_ISSUES+=1
    )
)

if %HTTP_CONFIG_ISSUES% gtr 0 (
    echo.
    echo [WARNING] Found %HTTP_CONFIG_ISSUES% potential HTTP configuration issues
    echo.
    echo 💡 RECOMMENDED HTTP LISTENER CONFIGURATION:
    echo.
    echo In src/main/mule/global.xml, ensure you have:
    echo.
    echo ^<http:listener-config name="HTTP_Listener_Configuration"
    echo                      host="0.0.0.0"
    echo                      port="${mule.http.port}"
    echo                      protocol="HTTP"/^>
    echo.
    echo CloudHub automatically provides the mule.http.port variable
    echo.
) else (
    echo [SUCCESS] All HTTP listener configurations look correct
)

echo ========================================================================
echo STEP 3: REDEPLOY WITH UPDATED CONFIGURATION
echo ========================================================================

echo [INFO] Ready to redeploy with updated worker size (0.1 vCore = 1GB RAM)
echo [INFO] This should resolve memory-related 504 errors
echo.

echo Do you want to redeploy now with the updated configuration?
echo [Y] Yes - Redeploy all services with 0.1 vCore workers
echo [N] No  - I'll deploy manually later
echo.
set /p DEPLOY_CHOICE=Enter your choice (Y/N): 

if /i "%DEPLOY_CHOICE%"=="Y" (
    echo.
    echo [INFO] Starting redeployment with 0.1 vCore workers...
    echo [INFO] This will take approximately 5-10 minutes...
    echo.
    
    REM Call the main deployment script
    call deploy.bat
    
    if !ERRORLEVEL! equ 0 (
        echo.
        echo ========================================================================
        echo ✅ REDEPLOYMENT COMPLETED
        echo ========================================================================
        echo.
        echo [INFO] All applications have been redeployed with 0.1 vCore workers
        echo [INFO] Waiting 30 seconds for applications to fully start...
        
        timeout /t 30 /nobreak > nul
        
        echo.
        echo [INFO] Testing health endpoints...
        call run-cloudhub-tests.bat
        
    ) else (
        echo.
        echo ❌ DEPLOYMENT FAILED
        echo [INFO] Check the deployment output above for specific errors
        echo [INFO] You can also run debug-cloudhub-applications.bat for detailed analysis
    )
) else (
    echo.
    echo [INFO] Manual deployment steps:
    echo 1. Run: .\deploy.bat
    echo 2. Wait 5-10 minutes for deployment to complete
    echo 3. Run: .\run-cloudhub-tests.bat to verify health
    echo.
    echo [INFO] The .env file has been updated with 0.1 vCore worker size
    echo [INFO] This should resolve most 504 timeout errors
)

echo.
echo ========================================================================
echo STEP 4: ADDITIONAL TROUBLESHOOTING OPTIONS
echo ========================================================================

echo.
echo If 504 errors persist after redeployment, run these diagnostic tools:
echo.
echo 🔍 .\debug-cloudhub-applications.bat
echo    - Detailed CloudHub application analysis
echo    - Log retrieval and analysis
echo    - Application status verification
echo.
echo 🧪 .\run-cloudhub-tests.bat  
echo    - Comprehensive health check testing
echo    - API endpoint validation
echo    - Performance monitoring
echo.
echo 📊 Manual checks in CloudHub Console:
echo    - https://anypoint.mulesoft.com/cloudhub/
echo    - Check application logs for startup errors
echo    - Verify application status is "Started"
echo    - Monitor CPU and memory usage
echo.

echo ========================================================================
echo COMMON 504 ERROR CAUSES AND SOLUTIONS
echo ========================================================================

echo.
echo 🚨 MEMORY ISSUES (Most Common):
echo    Problem: MICRO workers (256MB) insufficient for MCP applications
echo    Solution: ✅ Updated to 0.1 vCore (1GB RAM)
echo.
echo 🌐 HTTP LISTENER MISCONFIGURATION:
echo    Problem: Not listening on 0.0.0.0:${mule.http.port}
echo    Solution: Check global.xml HTTP listener configuration
echo.
echo ⏰ STARTUP TIMEOUT:
echo    Problem: Applications taking too long to start
echo    Solution: Increase worker size, optimize startup code
echo.
echo 🔗 EXTERNAL DEPENDENCIES:
echo    Problem: Database or API connections failing on startup
echo    Solution: Check logs, implement connection retries
echo.

echo ========================================================================
echo 🏁 QUICK FIX COMPLETED
echo ========================================================================

echo.
echo Summary of changes:
echo ✅ Updated CLOUDHUB_WORKER_TYPE to 0.1 vCore (1GB RAM)
echo ✅ Provided HTTP listener configuration guidance
echo ✅ Created diagnostic and deployment options
echo.

if %HTTP_CONFIG_ISSUES% gtr 0 (
    echo ⚠️  HTTP configuration issues detected - review global.xml files
) else (
    echo ✅ HTTP configurations appear correct
)

echo.
echo The worker size increase should resolve most 504 timeout issues.
echo If problems persist, run debug-cloudhub-applications.bat for detailed analysis.
echo.

pause
