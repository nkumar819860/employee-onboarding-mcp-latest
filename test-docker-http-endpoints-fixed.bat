@echo off
echo ============================================
echo TESTING DOCKER HTTP ENDPOINTS - FIXED VERSION
echo ============================================
echo.

:: Set error handling
setlocal enabledelayedexpansion

:: Check if Docker is running
docker ps >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Docker is not running or not accessible
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

echo [INFO] Testing Docker HTTP endpoints (not HTTPS)...
echo.

:: Test Employee Onboarding MCP Server (HTTP on 8081)
echo ========================================
echo Testing Employee Onboarding MCP Server
echo URL: http://localhost:8081
echo ========================================
echo.

echo [1/4] Testing health endpoint...
curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:8081/health
if !errorlevel! equ 0 (
    echo ✅ Employee Onboarding MCP Server - Health check PASSED
) else (
    echo ❌ Employee Onboarding MCP Server - Health check FAILED
)
echo.

echo [2/4] Testing API endpoint...
curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:8081/api
echo.

:: Test Assets Allocation MCP Server (HTTP on 8082)
echo ========================================
echo Testing Assets Allocation MCP Server
echo URL: http://localhost:8082
echo ========================================
echo.

echo [3/4] Testing health endpoint...
curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:8082/health
if !errorlevel! equ 0 (
    echo ✅ Assets Allocation MCP Server - Health check PASSED
) else (
    echo ❌ Assets Allocation MCP Server - Health check FAILED
)
echo.

:: Test Agent Broker (HTTP on 8080)
echo ========================================
echo Testing Agent Broker MCP Server
echo URL: http://localhost:8080
echo ========================================
echo.

echo [4/4] Testing agent broker endpoint...
curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:8080/api
if !errorlevel! equ 0 (
    echo ✅ Agent Broker MCP Server - API check PASSED
) else (
    echo ❌ Agent Broker MCP Server - API check FAILED
)
echo.

:: Test Email Notification MCP Server (HTTP on 8083)
echo ========================================
echo Testing Email Notification MCP Server
echo URL: http://localhost:8083
echo ========================================
echo.

curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:8083/health
echo.

:: Test React Client (HTTP on 3000)
echo ========================================
echo Testing React Client
echo URL: http://localhost:3000
echo ========================================
echo.

curl -s -m 10 -w "HTTP Status: %%{http_code} | Time: %%{time_total}s\n" http://localhost:3000
echo.

echo ============================================
echo DOCKER HTTP ENDPOINT TESTS COMPLETED
echo ============================================
echo.

echo [SUMMARY]
echo • All services should be accessible via HTTP (not HTTPS)
echo • Employee Onboarding: http://localhost:8081
echo • Assets Allocation: http://localhost:8082  
echo • Email Notification: http://localhost:8083
echo • Agent Broker: http://localhost:8080
echo • React Client: http://localhost:3000
echo.

echo [CONFIGURATION NOTES]
echo ✅ Docker environment uses HTTP protocol
echo ✅ JKS/SSL certificates not required for Docker testing
echo ✅ CloudHub deployment will use HTTPS with self-signed JKS
echo.

pause
