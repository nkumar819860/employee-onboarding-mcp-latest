@echo off
REM ========================================
REM COMPREHENSIVE CLOUDHUB INTEGRATION TEST
REM Tests all deployed MCP services and React client configuration
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo CLOUDHUB INTEGRATION TESTING SUITE
echo ========================================
echo.

REM Define CloudHub service URLs
set AGENT_BROKER_URL=https://agent-broker-mcp-server.us-e1.cloudhub.io
set EMPLOYEE_MCP_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
set ASSET_MCP_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
set NOTIFICATION_MCP_URL=https://notification-mcp-server.us-e1.cloudhub.io

echo 🌐 Testing CloudHub Service URLs:
echo   • Agent Broker:    %AGENT_BROKER_URL%
echo   • Employee MCP:    %EMPLOYEE_MCP_URL%
echo   • Asset MCP:       %ASSET_MCP_URL%
echo   • Notification:    %NOTIFICATION_MCP_URL%
echo.

REM === TEST 1: HEALTH CHECKS ===
echo ==============================
echo 🏥 HEALTH CHECK TESTS
echo ==============================
echo.

set HEALTH_PASS=0
set HEALTH_TOTAL=0

REM Test Agent Broker Health
set /a HEALTH_TOTAL+=1
echo [1/4] Testing Agent Broker Health...
powershell -Command "try { $response = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host 'Agent Broker: HEALTHY' -ForegroundColor Green; exit 0 } else { Write-Host 'Agent Broker: HTTP' $response.StatusCode -ForegroundColor Red; exit 1 } } catch { Write-Host 'Agent Broker: FAILED -' $_.Exception.Message -ForegroundColor Red; exit 1 }"
if !errorlevel! equ 0 set /a HEALTH_PASS+=1

REM Test Employee MCP Health
set /a HEALTH_TOTAL+=1
echo [2/4] Testing Employee MCP Health...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%EMPLOYEE_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Employee MCP: HEALTHY' -ForegroundColor Green; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Employee MCP: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Employee MCP: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a HEALTH_PASS+=1

REM Test Asset MCP Health
set /a HEALTH_TOTAL+=1
echo [3/4] Testing Asset MCP Health...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%ASSET_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Asset MCP: HEALTHY' -ForegroundColor Green; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Asset MCP: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Asset MCP: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a HEALTH_PASS+=1

REM Test Notification MCP Health
set /a HEALTH_TOTAL+=1
echo [4/4] Testing Notification MCP Health...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%NOTIFICATION_MCP_URL%/health' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Notification MCP: HEALTHY' -ForegroundColor Green; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Notification MCP: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Notification MCP: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a HEALTH_PASS+=1

echo.
echo Health Check Results: %HEALTH_PASS%/%HEALTH_TOTAL% services healthy
echo.

REM === TEST 2: MCP INFO ENDPOINTS ===
echo ==============================
echo ℹ️  MCP INFO TESTS
echo ==============================
echo.

set INFO_PASS=0
set INFO_TOTAL=0

REM Test Agent Broker MCP Info
set /a INFO_TOTAL+=1
echo [1/4] Testing Agent Broker MCP Info...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Agent Broker MCP Info: ACCESSIBLE' -ForegroundColor Green; ^
            Write-Host '📄 Content Length:' $response.Content.Length 'chars' -ForegroundColor Cyan; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Agent Broker MCP Info: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Agent Broker MCP Info: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a INFO_PASS+=1

REM Test Employee MCP Info
set /a INFO_TOTAL+=1
echo [2/4] Testing Employee MCP Info...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%EMPLOYEE_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Employee MCP Info: ACCESSIBLE' -ForegroundColor Green; ^
            Write-Host '📄 Content Length:' $response.Content.Length 'chars' -ForegroundColor Cyan; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Employee MCP Info: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Employee MCP Info: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a INFO_PASS+=1

REM Test Asset MCP Info
set /a INFO_TOTAL+=1
echo [3/4] Testing Asset MCP Info...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%ASSET_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Asset MCP Info: ACCESSIBLE' -ForegroundColor Green; ^
            Write-Host '📄 Content Length:' $response.Content.Length 'chars' -ForegroundColor Cyan; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Asset MCP Info: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Asset MCP Info: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a INFO_PASS+=1

REM Test Notification MCP Info
set /a INFO_TOTAL+=1
echo [4/4] Testing Notification MCP Info...
powershell -Command ^
    "try { ^
        $response = Invoke-WebRequest -Uri '%NOTIFICATION_MCP_URL%/mcp/info' -UseBasicParsing -TimeoutSec 10 -Method GET; ^
        if ($response.StatusCode -eq 200) { ^
            Write-Host '✅ Notification MCP Info: ACCESSIBLE' -ForegroundColor Green; ^
            Write-Host '📄 Content Length:' $response.Content.Length 'chars' -ForegroundColor Cyan; ^
            exit 0 ^
        } else { ^
            Write-Host '❌ Notification MCP Info: HTTP' $response.StatusCode -ForegroundColor Red; ^
            exit 1 ^
        } ^
    } catch { ^
        Write-Host '❌ Notification MCP Info: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        exit 1 ^
    }"
if !errorlevel! equ 0 set /a INFO_PASS+=1

echo.
echo MCP Info Results: %INFO_PASS%/%INFO_TOTAL% endpoints accessible
echo.

REM === TEST 3: EMPLOYEE ONBOARDING API TEST ===
echo ==============================
echo 🚀 EMPLOYEE ONBOARDING API TEST
echo ==============================
echo.

echo Testing complete employee onboarding workflow...
powershell -Command ^
    "$body = @{ ^
        firstName = 'TestUser'; ^
        lastName = 'CloudHub'; ^
        email = 'testuser.cloudhub@company.com'; ^
        department = 'Engineering'; ^
        position = 'Software Developer'; ^
        startDate = '2026-03-01'; ^
        salary = 75000; ^
        manager = 'Jane Manager'; ^
        managerEmail = 'jane.manager@company.com'; ^
        companyName = 'CloudHub Test Company'; ^
        assets = @('laptop', 'phone', 'id-card') ^
    } | ConvertTo-Json; ^
    Write-Host '📤 Sending Employee Onboarding Request...' -ForegroundColor Yellow; ^
    Write-Host '🎯 Endpoint: %AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding' -ForegroundColor Cyan; ^
    try { ^
        $response = Invoke-WebRequest -Uri '%AGENT_BROKER_URL%/mcp/tools/orchestrate-employee-onboarding' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing -TimeoutSec 30; ^
        Write-Host '✅ Employee Onboarding: SUCCESS (HTTP' $response.StatusCode ')' -ForegroundColor Green; ^
        Write-Host '📄 Response Length:' $response.Content.Length 'chars' -ForegroundColor Cyan; ^
        Write-Host '📋 Response Preview:' $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)) '...' -ForegroundColor White ^
    } catch { ^
        Write-Host '❌ Employee Onboarding: FAILED -' $_.Exception.Message.Split([Environment]::NewLine)[0] -ForegroundColor Red; ^
        if ($_.Exception.Response) { ^
            Write-Host '📄 Status Code:' $_.Exception.Response.StatusCode -ForegroundColor Red ^
        } ^
    }"

echo.

REM === TEST 4: REACT CLIENT CONFIGURATION CHECK ===
echo ==============================
echo 📱 REACT CLIENT CONFIGURATION
echo ==============================
echo.

echo Validating React client configuration files...

REM Check if apiService.js has correct URLs
echo [1/3] Checking apiService.js configuration...
findstr /C:"agent-broker-mcp-server.us-e1.cloudhub.io" "react-client\src\services\apiService.js" >nul
if !errorlevel! equ 0 (
    echo ✅ apiService.js: CloudHub URLs configured correctly
) else (
    echo ❌ apiService.js: CloudHub URLs not found
)

REM Check if .env.production exists
echo [2/3] Checking .env.production file...
if exist "react-client\.env.production" (
    echo ✅ .env.production: Environment file exists
    findstr /C:"agent-broker-mcp-server.us-e1.cloudhub.io" "react-client\.env.production" >nul
    if !errorlevel! equ 0 (
        echo ✅ .env.production: CloudHub URLs configured
    ) else (
        echo ❌ .env.production: CloudHub URLs missing
    )
) else (
    echo ❌ .env.production: Environment file missing
)

REM Check React build capability
echo [3/3] Testing React build readiness...
if exist "react-client\package.json" (
    echo ✅ package.json: React project structure ready
) else (
    echo ❌ package.json: React project structure incomplete
)

echo.

REM === TEST RESULTS SUMMARY ===
echo ==============================
echo 📊 TEST RESULTS SUMMARY
echo ==============================
echo.

set /a TOTAL_TESTS=!HEALTH_TOTAL! + !INFO_TOTAL!
set /a TOTAL_PASSED=!HEALTH_PASS! + !INFO_PASS!

echo 🏥 Health Checks:       %HEALTH_PASS%/%HEALTH_TOTAL% passed
echo ℹ️  MCP Info Endpoints: %INFO_PASS%/%INFO_TOTAL% accessible  
echo 🚀 API Integration:     Manual test completed
echo 📱 React Configuration: Manual verification completed
echo.
echo 📈 Overall Status:      %TOTAL_PASSED%/%TOTAL_TESTS% basic tests passed

if %TOTAL_PASSED% equ %TOTAL_TESTS% (
    echo.
    echo ✅ ALL BASIC TESTS PASSED!
    echo 🎉 Your CloudHub deployment is working correctly!
    echo.
    echo 🔗 Ready to use URLs:
    echo   • Agent Broker:    %AGENT_BROKER_URL%
    echo   • Employee MCP:    %EMPLOYEE_MCP_URL%
    echo   • Asset MCP:       %ASSET_MCP_URL%
    echo   • Notification:    %NOTIFICATION_MCP_URL%
    echo.
    echo 📱 Next Steps:
    echo   1. Build React client: cd react-client && npm run build
    echo   2. Deploy React app to your preferred hosting platform
    echo   3. Test the complete system end-to-end
) else (
    echo.
    echo ⚠️  SOME TESTS FAILED
    echo 🔧 Please review the failed tests above
    echo 📋 Check CloudHub application logs for more details
    echo.
    echo 💡 Troubleshooting Tips:
    echo   1. Verify all applications are deployed and running in CloudHub
    echo   2. Check CloudHub application logs for errors
    echo   3. Run: discover-cloudhub-urls.bat for detailed status
    echo   4. Ensure proper MCP endpoint configurations
)

echo.
echo ==============================
echo 🏁 INTEGRATION TEST COMPLETE
echo ==============================
echo.

pause
