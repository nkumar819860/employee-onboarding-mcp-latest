@echo off
echo ===============================================
echo MCP Employee Onboarding - Database Setup
echo ===============================================
echo.

echo Checking Docker availability...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not running
    echo Please install Docker Desktop for Windows
    echo https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

echo Docker is available. Starting database setup...
echo.

echo Starting Docker containers...
docker-compose -f docker-compose-databases.yml up -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start database containers
    pause
    exit /b 1
)

echo.
echo Waiting for databases to initialize (30 seconds)...
echo This may take longer on first run while images are downloaded
timeout /t 30 /nobreak >nul

echo.
echo Checking database health...
echo.

echo Testing PostgreSQL connection...
docker exec mcp-postgres pg_isready -U mcp_user -d employee_onboarding
echo.

echo Testing H2 availability...
curl -s -o nul -w "H2 Web Console: %%{http_code}\n" http://localhost:8082

echo.
echo Testing MCP Server endpoints (if running)...
echo Asset Allocation MCP Health:
curl -s -X GET http://localhost:8085/health 2>nul || echo Not running yet

echo Employee Onboarding MCP Health:
curl -s -X GET http://localhost:8083/health 2>nul || echo Not running yet

echo Agent Broker MCP Health:
curl -s -X GET http://localhost:8084/health 2>nul || echo Not running yet

echo.
echo ===============================================
echo Database Setup Complete!
echo ===============================================
echo.
echo Services Available:
echo.
echo PostgreSQL Database:
echo   - Host: localhost:5432
echo   - Database: employee_onboarding
echo   - Username: mcp_user
echo   - Password: mcp_password
echo.
echo H2 Database:
echo   - Web Console: http://localhost:8082
echo   - JDBC URL: jdbc:h2:tcp://localhost:9092/~/testdb
echo   - Username: sa
echo   - Password: (empty)
echo.
echo pgAdmin (PostgreSQL Web UI):
echo   - URL: http://localhost:8083
echo   - Email: admin@mcp.local
echo   - Password: admin123
echo.
echo Redis Cache:
echo   - Host: localhost:6379
echo.
echo Management Commands:
echo   docker-compose -f docker-compose-databases.yml ps     (check status)
echo   docker-compose -f docker-compose-databases.yml logs   (view logs)
echo   docker-compose -f docker-compose-databases.yml down   (stop all)
echo.
pause
