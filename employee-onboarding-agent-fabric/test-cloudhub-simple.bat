@echo off
REM ========================================
REM SIMPLE CLOUDHUB URL TESTING SCRIPT
REM ========================================

echo ========================================
echo CLOUDHUB URL TESTING
echo ========================================
echo.

REM Define CloudHub service URLs
set AGENT_BROKER_URL=https://agent-broker-mcp-server.us-e1.cloudhub.io
set EMPLOYEE_MCP_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
set ASSET_MCP_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
set NOTIFICATION_MCP_URL=https://notification-mcp-server.us-e1.cloudhub.io

echo Testing CloudHub Service URLs:
echo   Agent Broker:    %AGENT_BROKER_URL%
echo   Employee MCP:    %EMPLOYEE_MCP_URL%
echo   Asset MCP:       %ASSET_MCP_URL%
echo   Notification:    %NOTIFICATION_MCP_URL%
echo.

echo ==============================
echo HEALTH CHECK TESTS
echo ==============================
echo.

echo [1/4] Testing Agent Broker Health...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/health' -UseBasicParsing -TimeoutSec 10; Write-Host 'Agent Broker: HEALTHY (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Agent Broker: FAILED' -ForegroundColor Red }"

echo [2/4] Testing Employee MCP Health...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%EMPLOYEE_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10; Write-Host 'Employee MCP: HEALTHY (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Employee MCP: FAILED' -ForegroundColor Red }"

echo [3/4] Testing Asset MCP Health...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%ASSET_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10; Write-Host 'Asset MCP: HEALTHY (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Asset MCP: FAILED' -ForegroundColor Red }"

echo [4/4] Testing Notification MCP Health...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%NOTIFICATION_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10; Write-Host 'Notification MCP: HEALTHY (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Notification MCP: FAILED' -ForegroundColor Red }"

echo.
echo ==============================
echo MCP INFO TESTS
echo ==============================
echo.

echo [1/4] Testing Agent Broker MCP Info...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10; Write-Host 'Agent Broker MCP Info: ACCESSIBLE (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Agent Broker MCP Info: FAILED' -ForegroundColor Red }"

echo [2/4] Testing Employee MCP Info...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%EMPLOYEE_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10; Write-Host 'Employee MCP Info: ACCESSIBLE (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Employee MCP Info: FAILED' -ForegroundColor Red }"

echo [3/4] Testing Asset MCP Info...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%ASSET_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10; Write-Host 'Asset MCP Info: ACCESSIBLE (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Asset MCP Info: FAILED' -ForegroundColor Red }"

echo [4/4] Testing Notification MCP Info...
powershell -Command "try { $r = Invoke-WebRequest -Uri '%NOTIFICATION_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10; Write-Host 'Notification MCP Info: ACCESSIBLE (HTTP' $r.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Notification MCP Info: FAILED' -ForegroundColor Red }"

echo.
echo ==============================
echo EMPLOYEE ONBOARDING API TEST
echo ==============================
echo.

echo Testing Employee Onboarding API...
powershell -Command "$body = '{\"firstName\":\"TestUser\",\"lastName\":\"CloudHub\",\"email\":\"testuser.cloudhub@company.com\",\"department\":\"Engineering\",\"assets\":[\"laptop\",\"phone\"]}'; try { $r = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing -TimeoutSec 30; Write-Host 'Employee Onboarding API: SUCCESS (HTTP' $r.StatusCode ')' -ForegroundColor Green; Write-Host 'Response Length:' $r.Content.Length 'chars' -ForegroundColor Cyan } catch { Write-Host 'Employee Onboarding API: FAILED' -ForegroundColor Red }"

echo.
echo ==============================
echo REACT CLIENT CONFIGURATION
echo ==============================
echo.

echo Checking React client configuration...

REM Check apiService.js
echo [1/3] Checking apiService.js configuration...
findstr /C:"agent-broker-mcp-server.us-e1.cloudhub.io" "react-client\src\services\apiService.js" >nul 2>&1
if %errorlevel% equ 0 (
    echo apiService.js: CloudHub URLs configured correctly
) else (
    echo apiService.js: CloudHub URLs not found
)

REM Check .env.production
echo [2/3] Checking .env.production file...
if exist "react-client\.env.production" (
    echo .env.production: Environment file exists
    findstr /C:"agent-broker-mcp-server.us-e1.cloudhub.io" "react-client\.env.production" >nul 2>&1
    if %errorlevel% equ 0 (
        echo .env.production: CloudHub URLs configured
    ) else (
        echo .env.production: CloudHub URLs missing
    )
) else (
    echo .env.production: Environment file missing
)

REM Check React project
echo [3/3] Checking React project structure...
if exist "react-client\package.json" (
    echo package.json: React project structure ready
) else (
    echo package.json: React project structure incomplete
)

echo.
echo ==============================
echo SUMMARY
echo ==============================
echo.

echo CloudHub URLs Ready for Use:
echo   Agent Broker:    %AGENT_BROKER_URL%
echo   Employee MCP:    %EMPLOYEE_MCP_URL%
echo   Asset MCP:       %ASSET_MCP_URL%
echo   Notification:    %NOTIFICATION_MCP_URL%
echo.

echo Key Endpoints:
echo   Health Checks:   /health
echo   MCP Info:        /mcp/info
echo   Orchestration:   %AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding
echo.

echo Next Steps:
echo   1. Fix any failed tests shown above
echo   2. Build React client: cd react-client ^&^& npm run build
echo   3. Deploy React app to hosting platform
echo   4. Test the complete system end-to-end
echo.

pause
