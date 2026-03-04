@echo off
echo ========================================
echo H2 to PostgreSQL Migration Test
echo ========================================

echo.
echo Step 1: Stopping any existing containers...
cd employee-onboarding-agent-fabric
docker-compose down

echo.
echo Step 2: Starting PostgreSQL database...
docker-compose up -d postgres

echo.
echo Step 3: Waiting for PostgreSQL to be ready...
timeout /t 15 /nobreak > nul

echo.
echo Step 4: Building and starting MCP services with PostgreSQL...
docker-compose up -d

echo.
echo Step 5: Waiting for services to initialize...
timeout /t 30 /nobreak > nul

echo.
echo Step 6: Testing PostgreSQL database connectivity...
echo Testing Employee Onboarding MCP Server...
curl -k "https://localhost:8081/api/employees" -H "Accept: application/json"
echo.

echo Testing Asset Allocation MCP Server...
curl -k "https://localhost:8082/api/assets" -H "Accept: application/json" 
echo.

echo.
echo Step 7: Testing Agent Broker orchestration...
curl -k "https://localhost:8080/api/onboard" -X POST -H "Content-Type: application/json" -d "{\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@company.com\"}"
echo.

echo.
echo Step 8: Testing React Client...
curl "http://localhost:3000" -I
echo.

echo.
echo Step 9: Checking Docker container health...
docker-compose ps

echo.
echo ========================================
echo Migration Test Completed!
echo ========================================
echo.
echo Next steps:
echo 1. Check container logs: docker-compose logs [service-name]
echo 2. Access React Client: http://localhost:3000
echo 3. Test full employee onboarding workflow
echo.
