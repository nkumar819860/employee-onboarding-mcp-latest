@echo off
echo =====================================================
echo Employee Onboarding MCP - Docker Build and Test
echo Using Mule 4.9.6
echo =====================================================
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo Phase 1: Copy MCP Server Code...
echo ===================================

REM Create service directories
mkdir services\agent-broker-mcp\src 2>nul
mkdir services\employee-onboarding-mcp\src 2>nul
mkdir services\asset-allocation-mcp\src 2>nul
mkdir services\notification-mcp\src 2>nul
mkdir services\react-client 2>nul
mkdir database 2>nul

REM Copy Agent Broker MCP Server
echo Copying Agent Broker MCP Server...
xcopy /E /I /Y ..\mcp-servers\employee-onboarding-agent-broker\src services\agent-broker-mcp\src
copy ..\mcp-servers\employee-onboarding-agent-broker\mule-artifact.json services\agent-broker-mcp\
copy ..\mcp-servers\employee-onboarding-agent-broker\pom.xml services\agent-broker-mcp\

REM Copy Employee Onboarding MCP Server (using the correct directory name)
echo Copying Employee Onboarding MCP Server...
xcopy /E /I /Y ..\mcp-servers\employee-onboarding-mcp-server\src services\employee-onboarding-mcp\src
copy ..\mcp-servers\employee-onboarding-mcp-server\mule-artifact.json services\employee-onboarding-mcp\ 2>nul
copy ..\mcp-servers\employee-onboarding-mcp-server\pom.xml services\employee-onboarding-mcp\ 2>nul

REM Copy Asset Allocation MCP Server (using the correct directory name)
echo Copying Asset Allocation MCP Server...
xcopy /E /I /Y ..\mcp-servers\assets-allocation-mcp-server\src services\asset-allocation-mcp\src
copy ..\mcp-servers\assets-allocation-mcp-server\mule-artifact.json services\asset-allocation-mcp\ 2>nul
copy ..\mcp-servers\assets-allocation-mcp-server\pom.xml services\asset-allocation-mcp\ 2>nul

REM Copy Notification MCP Server (using the correct directory name)  
echo Copying Notification MCP Server...
xcopy /E /I /Y ..\mcp-servers\email-notification-mcp-server\src services\notification-mcp\src
copy ..\mcp-servers\email-notification-mcp-server\mule-artifact.json services\notification-mcp\ 2>nul
copy ..\mcp-servers\email-notification-mcp-server\pom.xml services\notification-mcp\ 2>nul

REM Copy React Client
echo Copying React Client...
xcopy /E /I /Y ..\react-client services\react-client

REM Copy Database Scripts
echo Copying Database Scripts...
copy ..\database\init-databases.sql database\

echo ✅ Code copying completed!

echo.
echo Phase 2: Create Docker Configuration Files...
echo =============================================

REM Create Docker configuration for Agent Broker
echo Creating Docker config for Agent Broker...
(
echo # Docker environment configuration for Agent Broker MCP
echo http.listener.host=0.0.0.0
echo http.listener.port=8081
echo.
echo # Database configuration
echo db.host=${DB_HOST}
echo db.port=${DB_PORT}
echo db.name=${DB_NAME}
echo db.user=${DB_USER}
echo db.password=${DB_PASSWORD}
echo.
echo # MCP Server endpoints for orchestration
echo employee.onboarding.mcp.host=${EMPLOYEE_ONBOARDING_MCP_HOST}
echo employee.onboarding.mcp.port=${EMPLOYEE_ONBOARDING_MCP_PORT}
echo asset.allocation.mcp.host=${ASSET_ALLOCATION_MCP_HOST}
echo asset.allocation.mcp.port=${ASSET_ALLOCATION_MCP_PORT}
echo notification.mcp.host=${NOTIFICATION_MCP_HOST}
echo notification.mcp.port=${NOTIFICATION_MCP_PORT}
echo.
echo # Agent broker configuration
echo agent.broker.orchestration.enabled=true
) > services\agent-broker-mcp\docker-config.properties

echo.
echo Phase 3: Build Docker Images...
echo ===============================

echo Building Agent Broker MCP Image...
docker build -t agent-broker-mcp:latest services\agent-broker-mcp

if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to build Agent Broker MCP image
    pause
    exit /b 1
)

echo ✅ Docker images built successfully!

echo.
echo Phase 4: Start Services...
echo ==========================

echo Starting all services with Docker Compose...
docker-compose up -d

if %ERRORLEVEL% neq 0 (
    echo ❌ Failed to start services
    pause
    exit /b 1
)

echo ✅ Services started successfully!

echo.
echo Phase 5: Wait for Services to Initialize...
echo ==========================================

echo Waiting for services to become healthy...
timeout /t 60

echo.
echo Phase 6: Health Checks...
echo =========================

echo Testing Agent Broker Health...
curl -f http://localhost:8081/health
if %ERRORLEVEL% equ 0 (
    echo ✅ Agent Broker is healthy
) else (
    echo ⚠️ Agent Broker health check failed
)

echo.
echo Testing Employee Onboarding MCP Health...
curl -f http://localhost:8082/health
if %ERRORLEVEL% equ 0 (
    echo ✅ Employee Onboarding MCP is healthy
) else (
    echo ⚠️ Employee Onboarding MCP health check failed
)

echo.
echo Testing Asset Allocation MCP Health...
curl -f http://localhost:8083/health
if %ERRORLEVEL% equ 0 (
    echo ✅ Asset Allocation MCP is healthy
) else (
    echo ⚠️ Asset Allocation MCP health check failed
)

echo.
echo Testing Notification MCP Health...
curl -f http://localhost:8084/health
if %ERRORLEVEL% equ 0 (
    echo ✅ Notification MCP is healthy
) else (
    echo ⚠️ Notification MCP health check failed
)

echo.
echo =====================================================
echo Docker Testing Environment Ready!
echo =====================================================
echo.
echo Services available at:
echo - Agent Broker MCP: http://localhost:8081
echo - Employee Onboarding MCP: http://localhost:8082
echo - Asset Allocation MCP: http://localhost:8083
echo - Notification MCP: http://localhost:8084
echo - React Client: http://localhost:3000
echo - PostgreSQL: localhost:5432
echo - MailCatcher: http://localhost:1080
echo.
echo API Documentation:
echo - Agent Broker API: http://localhost:8081/console
echo - Employee Onboarding API: http://localhost:8082/console
echo - Asset Allocation API: http://localhost:8083/console
echo - Notification API: http://localhost:8084/console
echo.
echo To test the complete onboarding flow:
echo curl -X POST http://localhost:8081/api/mcp/tools/orchestrate-employee-onboarding ^
echo   -H "Content-Type: application/json" ^
echo   -d "{"firstName":"John","lastName":"Doe","email":"john.doe@company.com","department":"IT","position":"Developer","startDate":"2026-03-03","assets":["laptop","phone"]}"
echo.
echo To stop all services: docker-compose down
echo To view logs: docker-compose logs -f [service-name]
echo.
pause
