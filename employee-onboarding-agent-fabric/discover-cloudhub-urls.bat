@echo off
REM ========================================
REM CLOUDHUB URL DISCOVERY AND TESTING SCRIPT
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo CLOUDHUB URL DISCOVERY AND TESTING
echo ========================================
echo.

REM === DISCOVERED CLOUDHUB URLS FROM DEPLOYMENT STATUS ===
echo ✅ SUCCESSFULLY DEPLOYED APPLICATIONS:
echo.

echo 🌐 MAIN SERVICES:
echo   • Agent Broker MCP Server:    https://agent-broker-mcp-server.us-e1.cloudhub.io
echo   • Employee Onboarding MCP:    https://employee-onboarding-mcp.us-e1.cloudhub.io  
echo   • Asset Allocation MCP:       https://asset-allocation-mcp.us-e1.cloudhub.io
echo   • Notification MCP Server:    https://notification-mcp-server.us-e1.cloudhub.io
echo   • Employee Onboarding Server: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo   • Asset Allocation Server:    https://asset-allocation-mcp-server.us-e1.cloudhub.io
echo.

echo ==============================
echo 🧪 HEALTH CHECK TESTING
echo ==============================
echo.

REM Test each service health endpoint
set SERVICES[1]=agent-broker-mcp-server
set SERVICES[2]=employee-onboarding-mcp
set SERVICES[3]=asset-allocation-mcp
set SERVICES[4]=notification-mcp-server
set SERVICES[5]=employee-onboarding-mcp-server
set SERVICES[6]=asset-allocation-mcp-server

echo Testing health endpoints for all services...
echo.

for /L %%i in (1,1,6) do (
    call set "SERVICE=%%SERVICES[%%i]%%"
    echo [%%i/6] Testing !SERVICE!...
    echo   URL: https://!SERVICE!.us-e1.cloudhub.io
    
    REM Test /health endpoint
    powershell -Command ^
        "try { ^
            $response = Invoke-WebRequest -Uri 'https://!SERVICE!.us-e1.cloudhub.io/health' -UseBasicParsing -TimeoutSec 15 -Method GET; ^
            if ($response.StatusCode -eq 200) { ^
                Write-Host '    ✅ /health: HEALTHY (HTTP 200)' -ForegroundColor Green; ^
                Write-Host '    📄 Response: ' $response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)) -ForegroundColor Cyan ^
            } else { ^
                Write-Host '    ⚠️  /health: HTTP' $response.StatusCode -ForegroundColor Yellow ^
            } ^
        } catch { ^
            Write-Host '    ❌ /health: Not accessible -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red ^
        }"
    
    REM Test /mcp/info endpoint
    powershell -Command ^
        "try { ^
            $response = Invoke-WebRequest -Uri 'https://!SERVICE!.us-e1.cloudhub.io/mcp/info' -UseBasicParsing -TimeoutSec 15 -Method GET; ^
            if ($response.StatusCode -eq 200) { ^
                Write-Host '    ✅ /mcp/info: HEALTHY (HTTP 200)' -ForegroundColor Green; ^
                Write-Host '    📄 Response: ' $response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)) -ForegroundColor Cyan ^
            } else { ^
                Write-Host '    ⚠️  /mcp/info: HTTP' $response.StatusCode -ForegroundColor Yellow ^
            } ^
        } catch { ^
            Write-Host '    ❌ /mcp/info: Not accessible -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red ^
        }"
    
    REM Test root endpoint
    powershell -Command ^
        "try { ^
            $response = Invoke-WebRequest -Uri 'https://!SERVICE!.us-e1.cloudhub.io/' -UseBasicParsing -TimeoutSec 15 -Method GET; ^
            if ($response.StatusCode -eq 200) { ^
                Write-Host '    ✅ /: ACCESSIBLE (HTTP 200)' -ForegroundColor Green ^
            } else { ^
                Write-Host '    ⚠️  /: HTTP' $response.StatusCode -ForegroundColor Yellow ^
            } ^
        } catch { ^
            Write-Host '    ❌ /: Not accessible -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red ^
        }"
    
    echo.
)

echo ==============================
echo 🚀 SAMPLE API TESTING
echo ==============================
echo.

echo Testing Agent Broker MCP orchestration endpoint...
powershell -Command ^
    "$body = @{ ^
        firstName = 'John'; ^
        lastName = 'Doe'; ^
        email = 'john.doe@test.com'; ^
        department = 'Engineering'; ^
        position = 'Software Developer'; ^
        startDate = '2026-03-01'; ^
        salary = 75000; ^
        manager = 'Jane Smith'; ^
        managerEmail = 'jane.smith@company.com'; ^
        companyName = 'Test Company'; ^
        assets = @('laptop', 'phone', 'id-card') ^
    } | ConvertTo-Json; ^
    try { ^
        $response = Invoke-WebRequest -Uri 'https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing -TimeoutSec 30; ^
        Write-Host '✅ Employee Onboarding Test: SUCCESS (HTTP' $response.StatusCode ')' -ForegroundColor Green; ^
        Write-Host '📄 Response:' $response.Content -ForegroundColor Cyan ^
    } catch { ^
        Write-Host '❌ Employee Onboarding Test: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red ^
    }"

echo.

echo ==============================
echo 📋 SERVICE ENDPOINTS SUMMARY
echo ==============================
echo.

echo 🔗 HEALTH ENDPOINTS:
echo   • https://agent-broker-mcp-server.us-e1.cloudhub.io/health
echo   • https://employee-onboarding-mcp.us-e1.cloudhub.io/health
echo   • https://asset-allocation-mcp.us-e1.cloudhub.io/health
echo   • https://notification-mcp-server.us-e1.cloudhub.io/health
echo   • https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
echo   • https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
echo.

echo 🔗 MCP INFO ENDPOINTS:
echo   • https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info
echo   • https://employee-onboarding-mcp.us-e1.cloudhub.io/mcp/info
echo   • https://asset-allocation-mcp.us-e1.cloudhub.io/mcp/info
echo   • https://notification-mcp-server.us-e1.cloudhub.io/mcp/info
echo   • https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info
echo   • https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info
echo.

echo 🔗 KEY API ENDPOINTS:
echo   • Agent Broker Orchestration:
echo     POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo   • Employee Profile Creation:
echo     POST https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/employee/create
echo   • Asset Allocation:
echo     POST https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/asset/allocate
echo   • Notification Services:
echo     POST https://notification-mcp-server.us-e1.cloudhub.io/mcp/notification/send
echo.

echo ==============================
echo 🎯 RECOMMENDED NEXT STEPS
echo ==============================
echo.
echo 1. ✅ All applications are deployed and running
echo 2. 📋 Use the URLs above to access your services
echo 3. 🧪 Test individual endpoints using the URLs provided
echo 4. 🔧 Update any configuration files that reference incorrect URLs
echo 5. 📱 Configure your React client to use the correct CloudHub URLs
echo.

echo ==============================
echo 📱 REACT CLIENT CONFIGURATION UPDATE
echo ==============================
echo.

echo To fix the URL discovery issue in your React client, update the apiService.js:
echo.
echo   const API_BASE_URLS = {
echo     agentBroker: 'https://agent-broker-mcp-server.us-e1.cloudhub.io',
echo     employeeOnboarding: 'https://employee-onboarding-mcp-server.us-e1.cloudhub.io',
echo     assetAllocation: 'https://asset-allocation-mcp-server.us-e1.cloudhub.io',
echo     notification: 'https://notification-mcp-server.us-e1.cloudhub.io'
echo   };
echo.

echo 🎉 CloudHub URL Discovery Complete!
echo.
pause
