@echo off
echo ===================================
echo Employee Onboarding E2E Deployment Test
echo ===================================

echo.
echo [1/8] Checking Prerequisites...
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not in PATH
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose is not installed or not in PATH
    exit /b 1
)

echo Docker and Docker Compose found.

echo.
echo [2/8] Cleaning up previous deployments...
docker-compose down --volumes --remove-orphans
docker system prune -f

echo.
echo [3/8] Building all services...
docker-compose build --no-cache

if %errorlevel% neq 0 (
    echo ERROR: Failed to build services
    exit /b 1
)

echo.
echo [4/8] Starting services...
docker-compose up -d

if %errorlevel% neq 0 (
    echo ERROR: Failed to start services
    exit /b 1
)

echo.
echo [5/8] Waiting for services to be healthy...
timeout /t 60 /nobreak

echo.
echo [6/8] Checking service health...

echo Checking PostgreSQL...
docker-compose exec -T postgres pg_isready -U postgres
if %errorlevel% neq 0 (
    echo WARNING: PostgreSQL not ready
)

echo.
echo [7/8] Testing API endpoints...

echo Testing Agent Broker (Port 8080)...
curl -f http://localhost:8080/health 2>nul || echo WARNING: Agent Broker not responding

echo Testing Employee Service (Port 8081)...
curl -f http://localhost:8081/health 2>nul || echo WARNING: Employee Service not responding

echo Testing Asset Service (Port 8082)...
curl -f http://localhost:8082/health 2>nul || echo WARNING: Asset Service not responding

echo Testing Notification Service (Port 8083)...
curl -f http://localhost:8083/health 2>nul || echo WARNING: Notification Service not responding

echo Testing React Client (Port 3000)...
curl -f http://localhost:3000/health 2>nul || echo WARNING: React Client not responding

echo.
echo [8/8] Deployment Summary
echo ===================================
echo Services Status:
docker-compose ps

echo.
echo Database Info:
docker-compose exec -T postgres psql -U postgres -c "\l" 2>nul || echo Database connection failed

echo.
echo ===================================
echo E2E Deployment Test Complete!
echo ===================================
echo.
echo Access Points:
echo - React Client (NLP UI): http://localhost:3000
echo - Agent Broker API: http://localhost:8080
echo - Employee Service: http://localhost:8081  
echo - Asset Service: http://localhost:8082
echo - Notification Service: http://localhost:8083
echo - PostgreSQL: localhost:5432
echo.
echo Try the NLP Chat at: http://localhost:3000/chat
echo.
echo To view logs: docker-compose logs -f [service-name]
echo To stop: docker-compose down
echo.
