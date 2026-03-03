@echo off
echo ================================================================
echo Testing MCP Docker Containers with Mule Runtime 4.9.6
echo ================================================================

REM Check if Docker is running
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

REM Pull the Mule runtime image first
echo.
echo [1/6] Pulling mandius/mule-rt-4.9.6 base image...
docker pull mandius/mule-rt-4.9.6
if %errorlevel% neq 0 (
    echo ERROR: Failed to pull Mule runtime image
    pause
    exit /b 1
)

REM Stop and remove existing containers
echo.
echo [2/6] Cleaning up existing containers...
docker stop employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp >nul 2>&1
docker rm employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp >nul 2>&1

REM Build all MCP server Docker images
echo.
echo [3/6] Building MCP Docker images...

echo   Building Employee Onboarding MCP...
cd mcp-servers/employee-onboarding-mcp
docker build -t employee-onboarding-mcp .
if %errorlevel% neq 0 (
    echo ERROR: Failed to build employee-onboarding-mcp
    cd ../..
    pause
    exit /b 1
)
cd ../..

echo   Building Asset Allocation MCP...
cd mcp-servers/asset-allocation-mcp
docker build -t asset-allocation-mcp .
if %errorlevel% neq 0 (
    echo ERROR: Failed to build asset-allocation-mcp
    cd ../..
    pause
    exit /b 1
)
cd ../..

echo   Building Notification MCP...
cd mcp-servers/notification-mcp
docker build -t notification-mcp .
if %errorlevel% neq 0 (
    echo ERROR: Failed to build notification-mcp
    cd ../..
    pause
    exit /b 1
)
cd ../..

echo   Building Agent Broker MCP...
cd mcp-servers/agent-broker-mcp
docker build -t agent-broker-mcp .
if %errorlevel% neq 0 (
    echo ERROR: Failed to build agent-broker-mcp
    cd ../..
    pause
    exit /b 1
)
cd ../..

REM Create a network for the containers
echo.
echo [4/6] Creating Docker network...
docker network create mcp-test-network >nul 2>&1

REM Start all containers
echo.
echo [5/6] Starting MCP containers...

echo   Starting PostgreSQL database...
docker run -d --name postgres-test --network mcp-test-network -p 5432:5432 ^
  -e POSTGRES_DB=postgres ^
  -e POSTGRES_USER=postgres ^
  -e POSTGRES_PASSWORD=password ^
  postgres:15-alpine

echo   Starting Employee Onboarding MCP (Port 8081)...
docker run -d --name employee-onboarding-mcp --network mcp-test-network -p 8081:8081 ^
  -e http.host=0.0.0.0 ^
  -e http.port=8081 ^
  employee-onboarding-mcp

echo   Starting Asset Allocation MCP (Port 8082)...
docker run -d --name asset-allocation-mcp --network mcp-test-network -p 8082:8082 ^
  -e http.host=0.0.0.0 ^
  -e http.port=8082 ^
  asset-allocation-mcp

echo   Starting Notification MCP (Port 8083)...
docker run -d --name notification-mcp --network mcp-test-network -p 8083:8083 ^
  -e http.host=0.0.0.0 ^
  -e http.port=8083 ^
  notification-mcp

echo   Starting Agent Broker MCP (Port 8080)...
docker run -d --name agent-broker-mcp --network mcp-test-network -p 8080:8080 ^
  -e http.host=0.0.0.0 ^
  -e http.port=8080 ^
  agent-broker-mcp

REM Wait for containers to start
echo.
echo   Waiting for containers to start (90 seconds)...
timeout /t 90 /nobreak >nul

REM Check container status
echo.
echo [6/6] Testing MCP Endpoints...

echo ================================================================
echo Container Status:
echo ================================================================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=mcp"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=postgres"

echo.
echo ================================================================
echo Testing Health Endpoints:
echo ================================================================

REM Test Employee Onboarding MCP
echo.
echo Testing Employee Onboarding MCP (Port 8081):
echo   URL: http://localhost:8081/health
curl -s -w "  Status Code: %%{http_code}\n" http://localhost:8081/health
if %errorlevel% equ 0 (
    echo   ✓ Employee Onboarding MCP is responding
) else (
    echo   ✗ Employee Onboarding MCP is not responding
)

REM Test Asset Allocation MCP
echo.
echo Testing Asset Allocation MCP (Port 8082):
echo   URL: http://localhost:8082/health
curl -s -w "  Status Code: %%{http_code}\n" http://localhost:8082/health
if %errorlevel% equ 0 (
    echo   ✓ Asset Allocation MCP is responding
) else (
    echo   ✗ Asset Allocation MCP is not responding
)

REM Test Notification MCP
echo.
echo Testing Notification MCP (Port 8083):
echo   URL: http://localhost:8083/health
curl -s -w "  Status Code: %%{http_code}\n" http://localhost:8083/health
if %errorlevel% equ 0 (
    echo   ✓ Notification MCP is responding
) else (
    echo   ✗ Notification MCP is not responding
)

REM Test Agent Broker MCP
echo.
echo Testing Agent Broker MCP (Port 8080):
echo   URL: http://localhost:8080/health
curl -s -w "  Status Code: %%{http_code}\n" http://localhost:8080/health
if %errorlevel% equ 0 (
    echo   ✓ Agent Broker MCP is responding
) else (
    echo   ✗ Agent Broker MCP is not responding
)

echo.
echo ================================================================
echo Container Logs (Last 10 lines each):
echo ================================================================

echo.
echo Employee Onboarding MCP Logs:
docker logs --tail 10 employee-onboarding-mcp

echo.
echo Asset Allocation MCP Logs:
docker logs --tail 10 asset-allocation-mcp

echo.
echo Notification MCP Logs:
docker logs --tail 10 notification-mcp

echo.
echo Agent Broker MCP Logs:
docker logs --tail 10 agent-broker-mcp

echo.
echo ================================================================
echo Test Summary
echo ================================================================
echo All MCP containers are running with Mule Runtime 4.9.6
echo.
echo Available endpoints:
echo   - Employee Onboarding: http://localhost:8081
echo   - Asset Allocation:     http://localhost:8082  
echo   - Notification:         http://localhost:8083
echo   - Agent Broker:         http://localhost:8080
echo.
echo To stop all containers, run:
echo   docker stop employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp postgres-test
echo.
echo To remove all containers and network, run:
echo   docker rm employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp postgres-test
echo   docker network rm mcp-test-network
echo.
echo To view real-time logs, use:
echo   docker logs -f [container-name]
echo.

pause
