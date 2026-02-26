@echo off
echo ================================================================
echo  CLOUDHUB END-TO-END TESTING SUITE
echo  Employee Onboarding Agent Fabric - CloudHub Deployment
echo ================================================================

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo.
echo Loading environment configuration...
if exist .env (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%b"=="" set %%a=%%b
    )
    echo ✅ Environment configuration loaded
) else (
    echo ⚠️  .env file not found, using default CloudHub URLs
)

echo.
echo =============================================
echo TEST 1: CLOUDHUB MCP SERVER CONNECTIVITY
echo =============================================

echo Testing CloudHub MCP Server health endpoints...
echo.

REM Test Agent Broker MCP
echo Testing Agent Broker MCP...
curl -s -f https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Agent Broker MCP: HEALTHY
    set BROKER_CLOUD=1
) else (
    echo ❌ Agent Broker MCP: NOT AVAILABLE
    set BROKER_CLOUD=0
)

REM Test Employee Onboarding MCP
echo Testing Employee Onboarding MCP...
curl -s -f https://employee-onboarding-service.us-e1.cloudhub.io/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Employee Onboarding MCP: HEALTHY
    set EMPLOYEE_CLOUD=1
) else (
    echo ❌ Employee Onboarding MCP: NOT AVAILABLE
    set EMPLOYEE_CLOUD=0
)

REM Test Asset Allocation MCP
echo Testing Asset Allocation MCP...
curl -s -f https://asset-allocation-service.us-e1.cloudhub.io/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Asset Allocation MCP: HEALTHY
    set ASSET_CLOUD=1
) else (
    echo ❌ Asset Allocation MCP: NOT AVAILABLE
    set ASSET_CLOUD=0
)

REM Test Notification MCP
echo Testing Employee Notification Service...
curl -s -f https://employee-notification-service.us-e1.cloudhub.io/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Employee Notification Service: HEALTHY
    set NOTIFICATION_CLOUD=1
) else (
    echo ❌ Employee Notification Service: NOT AVAILABLE
    set NOTIFICATION_CLOUD=0
)

echo.
echo ============================================
echo TEST 2: MCP SERVER INFO AND CAPABILITIES
echo ============================================

if %BROKER_CLOUD%==1 (
    echo.
    echo --- Agent Broker MCP Information ---
    echo Getting MCP server capabilities...
    curl -s -X GET https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/info
    echo.
    echo.
) else (
    echo ❌ Agent Broker not available - skipping capability test
)

echo.
echo ==============================================
echo TEST 3: EMPLOYEE ONBOARDING ORCHESTRATION
echo ==============================================

if %BROKER_CLOUD%==1 (
    echo.
    echo --- CloudHub Employee Onboarding Test ---
    
    REM Create test employee data - using proper escaping for batch
    echo Creating test employee onboarding request...
    
    echo Sending orchestration request to CloudHub...
    curl -X POST ^
        -H "Content-Type: application/json" ^
        -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@testcompany.com\",\"phone\":\"555-0123\",\"department\":\"Engineering\",\"position\":\"Software Developer\",\"startDate\":\"2024-03-01\",\"salary\":75000,\"manager\":\"Jane Smith\",\"managerEmail\":\"jane.smith@testcompany.com\",\"companyName\":\"Test Company Inc\",\"assets\":[\"laptop\",\"phone\",\"id-card\"]}" ^
        https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
    
    echo.
    echo ✅ CloudHub orchestration request sent
    
    echo.
    echo Waiting 15 seconds for processing...
    timeout /t 15 /nobreak
    
    echo.
    echo Testing onboarding status check...
    curl -X GET ^
        "https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/tools/get-onboarding-status?email=john.doe@testcompany.com"
    echo.
    
) else (
    echo ❌ Agent Broker not available - skipping orchestration test
)

echo.
echo ==========================================
echo TEST 4: INDIVIDUAL SERVICE TESTING
echo ==========================================

REM Test Employee Onboarding Service directly
if %EMPLOYEE_CLOUD%==1 (
    echo.
    echo --- Employee Onboarding Service Test ---
    echo Creating employee profile...
    curl -X POST ^
        -H "Content-Type: application/json" ^
        -d "{\"firstName\":\"Jane\",\"lastName\":\"Smith\",\"email\":\"jane.smith@testcompany.com\",\"department\":\"Marketing\",\"position\":\"Marketing Manager\",\"startDate\":\"2024-03-15\"}" ^
        https://employee-onboarding-service.us-e1.cloudhub.io/mcp/tools/create-employee
    echo.
)

REM Test Asset Allocation Service
if %ASSET_CLOUD%==1 (
    echo.
    echo --- Asset Allocation Service Test ---
    echo Allocating laptop asset...
    curl -X POST ^
        -H "Content-Type: application/json" ^
        -d "{\"employeeId\":\"EMP001\",\"assetType\":\"laptop\",\"specifications\":{\"brand\":\"MacBook Pro\",\"model\":\"16-inch M3\",\"ram\":\"32GB\",\"storage\":\"1TB SSD\"}}" ^
        https://asset-allocation-service.us-e1.cloudhub.io/mcp/tools/allocate-asset
    echo.
)

REM Test Notification Service
if %NOTIFICATION_CLOUD%==1 (
    echo.
    echo --- Employee Notification Service Test ---
    echo Sending welcome email...
    curl -X POST ^
        -H "Content-Type: application/json" ^
        -d "{\"employeeId\":\"EMP001\",\"email\":\"test@testcompany.com\",\"firstName\":\"Test\",\"lastName\":\"User\",\"department\":\"Engineering\",\"startDate\":\"2024-03-01\",\"manager\":\"Jane Smith\"}" ^
        https://employee-notification-service.us-e1.cloudhub.io/mcp/tools/send-welcome-email
    echo.
)

echo.
echo ========================================
echo TEST 5: SYSTEM HEALTH CHECK
echo ========================================

if %BROKER_CLOUD%==1 (
    echo.
    echo --- CloudHub System Health Check ---
    echo Checking overall system health...
    curl -X POST ^
        -H "Content-Type: application/json" ^
        -d "{}" ^
        https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/tools/check-system-health
    echo.
    echo.
)

echo.
echo =======================================
echo TEST 6: PERFORMANCE AND MONITORING
echo =======================================

echo Testing CloudHub monitoring endpoints...
echo.

if %BROKER_CLOUD%==1 (
    echo --- Agent Broker Metrics ---
    curl -s https://employee-onboarding-agent-broker.us-e1.cloudhub.io/metrics 2>nul
    echo.
)

if %EMPLOYEE_CLOUD%==1 (
    echo --- Employee Service Metrics ---
    curl -s https://employee-onboarding-service.us-e1.cloudhub.io/metrics 2>nul
    echo.
)

echo.
echo ============================================
echo CLOUDHUB DEPLOYMENT TEST RESULTS
echo ============================================

echo.
echo === CLOUDHUB SERVICE STATUS ===
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

echo.
echo === CLOUDHUB ACCESS URLS ===
echo.
echo 🌐 CloudHub Runtime Manager:
echo    https://anypoint.mulesoft.com/cloudhub/
echo.
echo 🤖 Agent Broker MCP:
echo    https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/info
echo.
echo 👥 Employee Onboarding Service:
echo    https://employee-onboarding-service.us-e1.cloudhub.io/mcp/info
echo.
echo 💼 Asset Allocation Service:
echo    https://asset-allocation-service.us-e1.cloudhub.io/mcp/info
echo.
echo 📧 Employee Notification Service:
echo    https://employee-notification-service.us-e1.cloudhub.io/mcp/info
echo.

REM Calculate overall health score
set /a TOTAL_SERVICES=4
set /a HEALTHY_SERVICES=0

if %BROKER_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %EMPLOYEE_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %ASSET_CLOUD%==1 set /a HEALTHY_SERVICES+=1
if %NOTIFICATION_CLOUD%==1 set /a HEALTHY_SERVICES+=1

echo === OVERALL HEALTH SCORE ===
echo %HEALTHY_SERVICES% out of %TOTAL_SERVICES% services are healthy

if %HEALTHY_SERVICES%==%TOTAL_SERVICES% (
    echo.
    echo 🎉 ALL SERVICES HEALTHY - SYSTEM READY FOR PRODUCTION
    echo.
) else if %HEALTHY_SERVICES% geq 2 (
    echo.
    echo ⚠️  PARTIAL DEPLOYMENT - Some services need attention
    echo.
) else (
    echo.
    echo 🚨 CRITICAL - Most services are down - Check CloudHub deployment
    echo.
)

echo.
echo === NEXT STEPS ===
echo.
if %HEALTHY_SERVICES% lss %TOTAL_SERVICES% (
    echo 1. Check CloudHub Runtime Manager for deployment issues
    echo 2. Verify application logs in Anypoint Platform
    echo 3. Confirm environment configurations are correct
    echo 4. Re-deploy failed services using deploy-all-to-cloudhub.bat
    echo.
) else (
    echo 1. All services are healthy and ready for use
    echo 2. You can now test the React frontend against CloudHub
    echo 3. Consider running load tests for production readiness
    echo 4. Set up monitoring and alerting in Anypoint Platform
    echo.
)

echo === TROUBLESHOOTING ===
echo.
echo If services are not responding:
echo • Check Runtime Manager: https://anypoint.mulesoft.com/cloudhub/
echo • Verify Connected App credentials in .env file
echo • Ensure applications are deployed to correct environment
echo • Check application logs for startup issues
echo • Verify network connectivity and DNS resolution
echo.
echo For deployment issues, run:
echo • .\deploy-all-to-cloudhub.bat
echo • .\validate-credentials.bat
echo.

echo ============================================
echo 🏁 CLOUDHUB E2E TESTING COMPLETED
echo ============================================

REM Open CloudHub console for manual verification
echo Opening CloudHub Runtime Manager for manual verification...
start https://anypoint.mulesoft.com/cloudhub/

echo.
echo Press any key to continue...
pause >nul
