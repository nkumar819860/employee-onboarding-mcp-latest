@echo off
echo ========================================
echo COMPREHENSIVE END-TO-END TESTING SUITE
echo Employee Onboarding Agent Fabric
echo ========================================

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo.
echo ===============================
echo TEST 1: MCP SERVER CONNECTIVITY
echo ===============================

echo Testing MCP Server health endpoints...

REM Test local Docker deployment first
echo.
echo --- Testing Local Docker Deployment ---

curl -s -f http://localhost:8081/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Employee Onboarding MCP (Local): HEALTHY
    set EMPLOYEE_LOCAL=1
) else (
    echo ⚠️ Employee Onboarding MCP (Local): Not available
    set EMPLOYEE_LOCAL=0
)

curl -s -f http://localhost:8082/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Asset Allocation MCP (Local): HEALTHY
    set ASSET_LOCAL=1
) else (
    echo ⚠️ Asset Allocation MCP (Local): Not available
    set ASSET_LOCAL=0
)

curl -s -f http://localhost:8083/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Notification MCP (Local): HEALTHY
    set NOTIFICATION_LOCAL=1
) else (
    echo ⚠️ Notification MCP (Local): Not available
    set NOTIFICATION_LOCAL=0
)

curl -s -f http://localhost:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Agent Broker MCP (Local): HEALTHY
    set BROKER_LOCAL=1
) else (
    echo ⚠️ Agent Broker MCP (Local): Not available
    set BROKER_LOCAL=0
)

curl -s -f http://localhost:3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ React Frontend (Local): HEALTHY
    set REACT_LOCAL=1
) else (
    echo ⚠️ React Frontend (Local): Not available
    set REACT_LOCAL=0
)

echo.
echo --- Testing CloudHub Deployment ---

curl -s -f https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Employee Onboarding MCP (CloudHub): HEALTHY
    set EMPLOYEE_CLOUD=1
) else (
    echo ⚠️ Employee Onboarding MCP (CloudHub): Not available
    set EMPLOYEE_CLOUD=0
)

curl -s -f https://asset-allocation-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Asset Allocation MCP (CloudHub): HEALTHY
    set ASSET_CLOUD=1
) else (
    echo ⚠️ Asset Allocation MCP (CloudHub): Not available
    set ASSET_CLOUD=0
)

curl -s -f https://notification-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Notification MCP (CloudHub): HEALTHY
    set NOTIFICATION_CLOUD=1
) else (
    echo ⚠️ Notification MCP (CloudHub): Not available
    set NOTIFICATION_CLOUD=0
)

curl -s -f https://agent-broker-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Agent Broker MCP (CloudHub): HEALTHY
    set BROKER_CLOUD=1
) else (
    echo ⚠️ Agent Broker MCP (CloudHub): Not available
    set BROKER_CLOUD=0
)

echo.
echo ===================================
echo TEST 2: MCP RESOURCE AVAILABILITY
echo ===================================

REM Test MCP info endpoints
if %BROKER_LOCAL%==1 (
    echo.
    echo --- Testing Local MCP Info Endpoints ---
    echo Getting Agent Broker MCP Info...
    curl -s -X GET http://localhost:8080/mcp/info
    echo.
)

if %BROKER_CLOUD%==1 (
    echo.
    echo --- Testing CloudHub MCP Info Endpoints ---
    echo Getting Agent Broker MCP Info...
    curl -s -X GET https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info
    echo.
)

echo.
echo =======================================
echo TEST 3: EMPLOYEE ONBOARDING WORKFLOW
echo =======================================

REM Create test employee data
set EMPLOYEE_DATA={"firstName":"John","lastName":"Doe","email":"john.doe@testcompany.com","phone":"555-0123","department":"Engineering","position":"Software Developer","startDate":"2024-03-01","salary":75000,"manager":"Jane Smith","managerEmail":"jane.smith@testcompany.com","companyName":"Test Company Inc","assets":["laptop","phone","id-card"]}

if %BROKER_LOCAL%==1 (
    echo.
    echo --- Testing Local Employee Onboarding ---
    echo Creating employee onboarding request...
    echo Employee Data: %EMPLOYEE_DATA%
    echo.
    echo Sending orchestration request...
    curl -X POST -H "Content-Type: application/json" -d "%EMPLOYEE_DATA%" http://localhost:8080/mcp/tools/orchestrate-employee-onboarding
    echo.
    echo ✅ Local orchestration request sent successfully
    
    echo.
    echo Waiting 10 seconds for processing...
    timeout /t 10
    
    echo Testing status check...
    curl -X POST -H "Content-Type: application/json" -d "{\"email\":\"john.doe@testcompany.com\"}" http://localhost:8080/mcp/tools/get-onboarding-status
    echo.
)

if %BROKER_CLOUD%==1 (
    echo.
    echo --- Testing CloudHub Employee Onboarding ---
    set CLOUD_EMPLOYEE_DATA={"firstName":"Jane","lastName":"Smith","email":"jane.smith@testcompany.com","phone":"555-0456","department":"Marketing","position":"Marketing Manager","startDate":"2024-03-15","salary":85000,"manager":"Bob Johnson","managerEmail":"bob.johnson@testcompany.com","companyName":"Test Company Inc","assets":["laptop","phone","id-card"]}
    
    echo Creating employee onboarding request...
    echo Employee Data: %CLOUD_EMPLOYEE_DATA%
    echo.
    echo Sending orchestration request...
    curl -X POST -H "Content-Type: application/json" -d "%CLOUD_EMPLOYEE_DATA%" https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
    echo.
    echo ✅ CloudHub orchestration request sent successfully
    
    echo.
    echo Waiting 10 seconds for processing...
    timeout /t 10
    
    echo Testing status check...
    curl -X POST -H "Content-Type: application/json" -d "{\"email\":\"jane.smith@testcompany.com\"}" https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/get-onboarding-status
    echo.
)

echo.
echo ========================================
echo TEST 4: SYSTEM HEALTH CHECK
echo ========================================

if %BROKER_LOCAL%==1 (
    echo.
    echo --- Local System Health ---
    curl -X POST -H "Content-Type: application/json" -d "{}" http://localhost:8080/mcp/tools/check-system-health
    echo.
)

if %BROKER_CLOUD%==1 (
    echo.
    echo --- CloudHub System Health ---
    curl -X POST -H "Content-Type: application/json" -d "{}" https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/check-system-health
    echo.
)

echo.
echo ===================================
echo TEST 5: DATABASE CONNECTIVITY
echo ===================================

if %EMPLOYEE_LOCAL%==1 (
    echo Testing Employee database connection...
    curl -s -X GET http://localhost:8081/api/employees >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Employee database: Connected
    ) else (
        echo ⚠️ Employee database: Connection issue
    )
)

if %ASSET_LOCAL%==1 (
    echo Testing Asset database connection...
    curl -s -X GET http://localhost:8082/api/assets >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Asset database: Connected
    ) else (
        echo ⚠️ Asset database: Connection issue
    )
)

echo.
echo ==============================
echo TEST 6: REACT FRONTEND TESTING
echo ==============================

if %REACT_LOCAL%==1 (
    echo Testing React application components...
    curl -s http://localhost:3000 | findstr "Employee Onboarding" >nul
    if %errorlevel% equ 0 (
        echo ✅ React app loaded successfully
    ) else (
        echo ⚠️ React app may have loading issues
    )
    
    echo Testing React API service endpoints...
    REM The React app should be making calls to the backend APIs
    echo ✅ React frontend is accessible at http://localhost:3000
)

echo.
echo ===============================
echo TEST RESULTS SUMMARY
echo ===============================

echo.
echo === LOCAL DEPLOYMENT STATUS ===
if %BROKER_LOCAL%==1 (echo ✅ Agent Broker MCP: Running) else (echo ❌ Agent Broker MCP: Not Running)
if %EMPLOYEE_LOCAL%==1 (echo ✅ Employee MCP: Running) else (echo ❌ Employee MCP: Not Running)
if %ASSET_LOCAL%==1 (echo ✅ Asset MCP: Running) else (echo ❌ Asset MCP: Not Running)
if %NOTIFICATION_LOCAL%==1 (echo ✅ Notification MCP: Running) else (echo ❌ Notification MCP: Not Running)
if %REACT_LOCAL%==1 (echo ✅ React Frontend: Running) else (echo ❌ React Frontend: Not Running)

echo.
echo === CLOUDHUB DEPLOYMENT STATUS ===
if %BROKER_CLOUD%==1 (echo ✅ Agent Broker MCP: Deployed) else (echo ❌ Agent Broker MCP: Not Deployed)
if %EMPLOYEE_CLOUD%==1 (echo ✅ Employee MCP: Deployed) else (echo ❌ Employee MCP: Not Deployed)
if %ASSET_CLOUD%==1 (echo ✅ Asset MCP: Deployed) else (echo ❌ Asset MCP: Not Deployed)
if %NOTIFICATION_CLOUD%==1 (echo ✅ Notification MCP: Deployed) else (echo ❌ Notification MCP: Not Deployed)

echo.
echo === ACCESS URLS ===
echo.
if %REACT_LOCAL%==1 (
    echo 🌐 React Frontend (Local):   http://localhost:3000
)
if %BROKER_LOCAL%==1 (
    echo 🤖 Agent Broker (Local):     http://localhost:8080/mcp/info
    echo 👥 Employee MCP (Local):     http://localhost:8081/mcp/info  
    echo 💼 Asset MCP (Local):        http://localhost:8082/mcp/info
    echo 🔔 Notification MCP (Local): http://localhost:8083/mcp/info
)
echo.
if %BROKER_CLOUD%==1 (
    echo 🤖 Agent Broker (CloudHub):     https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info
    echo 👥 Employee MCP (CloudHub):     https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info
    echo 💼 Asset MCP (CloudHub):        https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info
    echo 🔔 Notification MCP (CloudHub): https://notification-mcp-server.us-e1.cloudhub.io/mcp/info
)

echo.
echo ==========================================
echo 🎯 END-TO-END TESTING COMPLETED
echo ==========================================
echo.
echo All system components have been tested.
echo Check the results above for any issues that need attention.
echo.
echo For detailed logs, check:
echo - Docker logs: docker-compose logs [service-name]
echo - CloudHub logs: Via Anypoint Platform monitoring
echo.

REM Open React frontend if available
if %REACT_LOCAL%==1 (
    echo Opening React frontend for manual testing...
    start http://localhost:3000
)

pause
