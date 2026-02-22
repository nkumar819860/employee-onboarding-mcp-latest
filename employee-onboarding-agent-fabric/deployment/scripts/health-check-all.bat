@echo off
REM ========================================
REM Health Check All Services Script
REM Comprehensive health monitoring for agent fabric
REM ========================================

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set FABRIC_ROOT=%SCRIPT_DIR%\..\..\
set CONFIG_DIR=%FABRIC_ROOT%\fabric-config
set ENVIRONMENT=%1

REM Colors for output
set GREEN=[92m
set RED=[91m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%🏥 Agent Fabric Health Check System%NC%
echo %BLUE%===================================%NC%
echo %BLUE%Environment: %ENVIRONMENT%%NC%
echo %BLUE%Timestamp: %DATE% %TIME%%NC%
echo.

REM Initialize counters
set HEALTHY_SERVICES=0
set UNHEALTHY_SERVICES=0
set TOTAL_CHECKS=0

REM Define service endpoints based on environment
if "%ENVIRONMENT%"=="production" (
    set BASE_URL=https://employee-onboarding-gateway.production.anypoint.mulesoft.com
) else (
    set BASE_URL=https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com
)

echo %BLUE%🌐 Base URL: %BASE_URL%%NC%
echo.

REM Service health check function
REM ========================================
echo %BLUE%🔍 Checking Core MCP Services%NC%
echo ----------------------------------------

REM Employee Onboarding MCP Health Check
echo %BLUE%📋 Checking Employee Onboarding MCP Server...%NC%
set /a TOTAL_CHECKS+=1
python -c "
import requests
import urllib3
urllib3.disable_warnings()
try:
    response = requests.get('%BASE_URL%/employee/health', verify=False, timeout=10)
    if response.status_code == 200:
        print('✅ Employee Onboarding MCP: HEALTHY')
        exit(0)
    else:
        print('❌ Employee Onboarding MCP: UNHEALTHY (Status: ' + str(response.status_code) + ')')
        exit(1)
except Exception as e:
    print('❌ Employee Onboarding MCP: UNREACHABLE (' + str(e) + ')')
    exit(1)
"
if !ERRORLEVEL! equ 0 (
    set /a HEALTHY_SERVICES+=1
    echo %GREEN%   Status: HEALTHY%NC%
) else (
    set /a UNHEALTHY_SERVICES+=1
    echo %RED%   Status: UNHEALTHY%NC%
)
echo.

REM Asset Allocation MCP Health Check
echo %BLUE%💼 Checking Asset Allocation MCP Server...%NC%
set /a TOTAL_CHECKS+=1
python -c "
import requests
import urllib3
urllib3.disable_warnings()
try:
    response = requests.get('%BASE_URL%/assets/health', verify=False, timeout=10)
    if response.status_code == 200:
        print('✅ Asset Allocation MCP: HEALTHY')
        exit(0)
    else:
        print('❌ Asset Allocation MCP: UNHEALTHY (Status: ' + str(response.status_code) + ')')
        exit(1)
except Exception as e:
    print('❌ Asset Allocation MCP: UNREACHABLE (' + str(e) + ')')
    exit(1)
"
if !ERRORLEVEL! equ 0 (
    set /a HEALTHY_SERVICES+=1
    echo %GREEN%   Status: HEALTHY%NC%
) else (
    set /a UNHEALTHY_SERVICES+=1
    echo %RED%   Status: UNHEALTHY%NC%
)
echo.

REM Notification MCP Health Check
echo %BLUE%📧 Checking Notification MCP Server...%NC%
set /a TOTAL_CHECKS+=1
python -c "
import requests
import urllib3
urllib3.disable_warnings()
try:
    response = requests.get('%BASE_URL%/notifications/health', verify=False, timeout=10)
    if response.status_code == 200:
        print('✅ Notification MCP: HEALTHY')
        exit(0)
    else:
        print('❌ Notification MCP: UNHEALTHY (Status: ' + str(response.status_code) + ')')
        exit(1)
except Exception as e:
    print('❌ Notification MCP: UNREACHABLE (' + str(e) + ')')
    exit(1)
"
if !ERRORLEVEL! equ 0 (
    set /a HEALTHY_SERVICES+=1
    echo %GREEN%   Status: HEALTHY%NC%
) else (
    set /a UNHEALTHY_SERVICES+=1
    echo %RED%   Status: UNHEALTHY%NC%
)
echo.

REM Agent Broker MCP Health Check
echo %BLUE%🎭 Checking Agent Broker MCP Server...%NC%
set /a TOTAL_CHECKS+=1
python -c "
import requests
import urllib3
urllib3.disable_warnings()
try:
    response = requests.get('%BASE_URL%/broker/health', verify=False, timeout=10)
    if response.status_code == 200:
        print('✅ Agent Broker MCP: HEALTHY')
        exit(0)
    else:
        print('❌ Agent Broker MCP: UNHEALTHY (Status: ' + str(response.status_code) + ')')
        exit(1)
except Exception as e:
    print('❌ Agent Broker MCP: UNREACHABLE (' + str(e) + ')')
    exit(1)
"
if !ERRORLEVEL! equ 0 (
    set /a HEALTHY_SERVICES+=1
    echo %GREEN%   Status: HEALTHY%NC%
) else (
    set /a UNHEALTHY_SERVICES+=1
    echo %RED%   Status: UNHEALTHY%NC%
)
echo.

REM ========================================
echo %BLUE%🔍 Checking MCP Tool Endpoints%NC%
echo ----------------------------------------

REM Check MCP Info Endpoints
echo %BLUE%ℹ️  Checking MCP Server Info Endpoints...%NC%
set /a TOTAL_CHECKS+=1
python -c "
import requests
import urllib3
import json
urllib3.disable_warnings()
try:
    response = requests.get('%BASE_URL%/broker/mcp/info', verify=False, timeout=10)
    if response.status_code == 200:
        data = response.json()
        print('✅ Agent Broker MCP Info: Available')
        print('   Tools: ' + str(len(data.get('tools', []))))
        exit(0)
    else:
        print('❌ Agent Broker MCP Info: Unavailable (Status: ' + str(response.status_code) + ')')
        exit(1)
except Exception as e:
    print('❌ Agent Broker MCP Info: Error (' + str(e) + ')')
    exit(1)
"
if !ERRORLEVEL! equ 0 (
    set /a HEALTHY_SERVICES+=1
    echo %GREEN%   Status: AVAILABLE%NC%
) else (
    set /a UNHEALTHY_SERVICES+=1
    echo %RED%   Status: UNAVAILABLE%NC%
)
echo.

REM ========================================
echo %BLUE%🔍 Advanced Health Metrics%NC%
echo ----------------------------------------

REM Response Time Check
echo %BLUE%⏱️  Measuring response times...%NC%
python -c "
import requests
import urllib3
import time
urllib3.disable_warnings()

services = [
    ('Employee MCP', '%BASE_URL%/employee/health'),
    ('Asset MCP', '%BASE_URL%/assets/health'),
    ('Notification MCP', '%BASE_URL%/notifications/health'),
    ('Agent Broker', '%BASE_URL%/broker/health')
]

print('Response Time Analysis:')
print('-' * 40)
for service_name, url in services:
    try:
        start_time = time.time()
        response = requests.get(url, verify=False, timeout=10)
        end_time = time.time()
        response_time = (end_time - start_time) * 1000
        
        if response_time < 1000:
            status = '✅ EXCELLENT'
        elif response_time < 2000:
            status = '⚠️  GOOD'
        else:
            status = '❌ SLOW'
            
        print(f'{service_name:15}: {response_time:6.0f}ms {status}')
    except Exception as e:
        print(f'{service_name:15}: ERROR - {str(e)}')
"
echo.

REM ========================================
REM Health Check Summary
REM ========================================
echo %BLUE%📊 Health Check Summary%NC%
echo %BLUE%======================%NC%
echo %GREEN%✅ Healthy Services: %HEALTHY_SERVICES%%NC%
echo %RED%❌ Unhealthy Services: %UNHEALTHY_SERVICES%%NC%
echo %BLUE%📋 Total Checks: %TOTAL_CHECKS%%NC%

REM Calculate health percentage
set /a HEALTH_PERCENTAGE=(%HEALTHY_SERVICES% * 100) / %TOTAL_CHECKS%
echo %BLUE%📈 Overall Health: %HEALTH_PERCENTAGE%%%NC%
echo.

REM Generate health status
if %HEALTH_PERCENTAGE% geq 100 (
    echo %GREEN%🎉 PERFECT HEALTH - All systems operational%NC%
    set HEALTH_STATUS=EXCELLENT
) else if %HEALTH_PERCENTAGE% geq 80 (
    echo %YELLOW%⚠️  GOOD HEALTH - Minor issues detected%NC%
    set HEALTH_STATUS=GOOD
) else if %HEALTH_PERCENTAGE% geq 60 (
    echo %YELLOW%🔶 FAIR HEALTH - Several issues need attention%NC%
    set HEALTH_STATUS=FAIR
) else (
    echo %RED%🚨 POOR HEALTH - Critical issues require immediate attention%NC%
    set HEALTH_STATUS=CRITICAL
)

REM Log health status to file
set TIMESTAMP=%DATE:~-4,4%-%DATE:~-10,2%-%DATE:~-7,2%_%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
echo %TIMESTAMP%,%ENVIRONMENT%,%HEALTH_PERCENTAGE%,%HEALTH_STATUS%,%HEALTHY_SERVICES%,%UNHEALTHY_SERVICES% >> "%FABRIC_ROOT%\deployment\monitoring\health-check-log.csv"

echo %BLUE%📝 Health check results logged to monitoring\health-check-log.csv%NC%
echo.

REM Return appropriate exit code
if %UNHEALTHY_SERVICES% gtr 0 (
    echo %RED%💥 Health check completed with issues%NC%
    exit /b 1
) else (
    echo %GREEN%🚀 All systems healthy and operational%NC%
    exit /b 0
)
