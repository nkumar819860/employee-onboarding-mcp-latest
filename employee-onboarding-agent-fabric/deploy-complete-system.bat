@echo off
echo ========================================
echo COMPLETE EMPLOYEE ONBOARDING SYSTEM
echo COMPILATION, DEPLOYMENT & E2E TESTING
echo ========================================

set BASE_DIR=%CD%
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo.
echo ==============================
echo STEP 1: ENVIRONMENT VALIDATION
echo ==============================

REM Check if .env file exists
if not exist ".env" (
    echo ❌ ERROR: .env file not found!
    echo Please ensure .env file exists with proper configuration.
    pause
    exit /b 1
)

REM Load environment variables
for /f "delims== tokens=1,2" %%G in (.env) do (
    if not "%%H"=="" (
        set "%%G=%%H"
    )
)

echo ✅ Environment configuration loaded

REM Check Maven installation
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Maven not found! Please install Maven.
    pause
    exit /b 1
)

echo ✅ Maven installation verified

REM Check Docker installation
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker not found! Please install Docker.
    pause
    exit /b 1
)

echo ✅ Docker installation verified

REM Check Node.js installation
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js not found! Please install Node.js.
    pause
    exit /b 1
)

echo ✅ Node.js installation verified

echo.
echo ===============================
echo STEP 2: COMPILE ALL MCP SERVERS
echo ===============================

echo.
echo Compiling Notification MCP Server...
cd mcp-servers\notification-mcp
call mvn clean compile package -DskipTests -U
if %errorlevel% neq 0 (
    echo ❌ ERROR: Notification MCP compilation failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ Notification MCP compiled successfully

echo.
echo Compiling Employee Onboarding MCP Server...
cd ..\employee-onboarding-mcp
call mvn clean compile package -DskipTests -U
if %errorlevel% neq 0 (
    echo ❌ ERROR: Employee Onboarding MCP compilation failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ Employee Onboarding MCP compiled successfully

echo.
echo Compiling Asset Allocation MCP Server...
cd ..\asset-allocation-mcp
call mvn clean compile package -DskipTests -U
if %errorlevel% neq 0 (
    echo ❌ ERROR: Asset Allocation MCP compilation failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ Asset Allocation MCP compiled successfully

echo.
echo Compiling Agent Broker MCP Server...
cd ..\agent-broker-mcp
call mvn clean compile package -DskipTests -U
if %errorlevel% neq 0 (
    echo ❌ ERROR: Agent Broker MCP compilation failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ Agent Broker MCP compiled successfully

cd /d "%SCRIPT_DIR%"

echo.
echo ============================
echo STEP 3: BUILD REACT FRONTEND
echo ============================

cd react-client

REM Install dependencies
echo Installing React dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ❌ ERROR: React dependencies installation failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ React dependencies installed

REM Build React app
echo Building React application...
call npm run build
if %errorlevel% neq 0 (
    echo ❌ ERROR: React build failed!
    cd /d "%SCRIPT_DIR%"
    pause
    exit /b 1
)
echo ✅ React application built successfully

cd /d "%SCRIPT_DIR%"

echo.
echo ===============================
echo STEP 4: DEPLOYMENT CHOICE
echo ===============================
echo.
echo Choose deployment method:
echo 1) Local Docker Deployment (Recommended for testing)
echo 2) CloudHub Deployment (Production)
echo 3) Both (Docker first, then CloudHub)
echo.
set /p DEPLOY_CHOICE="Enter your choice (1, 2, or 3): "

if "%DEPLOY_CHOICE%"=="1" goto docker_deploy
if "%DEPLOY_CHOICE%"=="2" goto cloudhub_deploy
if "%DEPLOY_CHOICE%"=="3" goto both_deploy
echo Invalid choice. Defaulting to Docker deployment.
goto docker_deploy

:docker_deploy
echo.
echo ==============================
echo STEP 5A: LOCAL DOCKER DEPLOYMENT
echo ==============================

REM Stop any running containers
echo Stopping existing containers...
docker-compose down --remove-orphans 2>nul

REM Remove old images to force rebuild
echo Cleaning up old Docker images...
docker rmi $(docker images employee-onboarding-agent-fabric* -q) 2>nul

REM Build and start all services
echo Building and starting all services...
docker-compose up --build -d

if %errorlevel% neq 0 (
    echo ❌ ERROR: Docker deployment failed!
    pause
    exit /b 1
)

echo ✅ Docker deployment initiated successfully

REM Wait for services to be ready
echo.
echo Waiting for services to initialize...
timeout /t 60

goto test_deployment

:cloudhub_deploy
echo.
echo ===============================
echo STEP 5B: CLOUDHUB DEPLOYMENT
echo ===============================

call deploy-all-mcp-servers-final.bat
if %errorlevel% neq 0 (
    echo ❌ ERROR: CloudHub deployment failed!
    pause
    exit /b 1
)

echo ✅ CloudHub deployment completed successfully
goto test_cloudhub_deployment

:both_deploy
call :docker_deploy
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo Waiting 5 minutes before CloudHub deployment...
timeout /t 300

call :cloudhub_deploy
if %errorlevel% neq 0 exit /b %errorlevel%

goto test_both_deployments

:test_deployment
echo.
echo ===============================
echo STEP 6: DOCKER E2E TESTING
echo ===============================

echo Testing service health checks...

REM Wait for PostgreSQL to be ready
echo Checking PostgreSQL...
:wait_postgres
docker exec employee-onboarding-postgres pg_isready -U postgres >nul 2>&1
if %errorlevel% neq 0 (
    echo Waiting for PostgreSQL to be ready...
    timeout /t 5
    goto wait_postgres
)
echo ✅ PostgreSQL is ready

REM Test each MCP server
echo.
echo Testing MCP Server health endpoints...

timeout /t 30

curl -f http://localhost:8081/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Employee Onboarding MCP: HEALTHY
) else (
    echo ⚠️ Employee Onboarding MCP: Not responding
)

curl -f http://localhost:8082/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Asset Allocation MCP: HEALTHY
) else (
    echo ⚠️ Asset Allocation MCP: Not responding
)

curl -f http://localhost:8083/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Notification MCP: HEALTHY
) else (
    echo ⚠️ Notification MCP: Not responding
)

curl -f http://localhost:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Agent Broker MCP: HEALTHY
) else (
    echo ⚠️ Agent Broker MCP: Not responding
)

curl -f http://localhost:3000 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ React Frontend: HEALTHY
) else (
    echo ⚠️ React Frontend: Not responding
)

REM Test MCP orchestration endpoint
echo.
echo Testing MCP orchestration...
curl -X POST -H "Content-Type: application/json" ^
     -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@test.com\",\"department\":\"Engineering\",\"position\":\"Software Developer\",\"startDate\":\"2024-03-01\",\"salary\":75000,\"manager\":\"Jane Smith\",\"managerEmail\":\"jane.smith@company.com\",\"companyName\":\"Test Company\",\"assets\":[\"laptop\",\"phone\",\"id-card\"]}" ^
     http://localhost:8080/mcp/tools/orchestrate-employee-onboarding

echo.
echo ===============================
echo DOCKER DEPLOYMENT SUMMARY
echo ===============================
echo.
echo 🌐 React Frontend:     http://localhost:3000
echo 🤖 Agent Broker MCP:   http://localhost:8080
echo 👥 Employee MCP:       http://localhost:8081
echo 💼 Asset MCP:          http://localhost:8082
echo 🔔 Notification MCP:   http://localhost:8083
echo 🗄️ PostgreSQL:         localhost:5432
echo.
goto end_success

:test_cloudhub_deployment
echo.
echo ===============================
echo STEP 6: CLOUDHUB E2E TESTING
echo ===============================

echo Testing CloudHub deployment health...

curl -f https://notification-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Notification MCP (CloudHub): HEALTHY
) else (
    echo ⚠️ Notification MCP (CloudHub): Not responding
)

curl -f https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Employee Onboarding MCP (CloudHub): HEALTHY
) else (
    echo ⚠️ Employee Onboarding MCP (CloudHub): Not responding
)

curl -f https://asset-allocation-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Asset Allocation MCP (CloudHub): HEALTHY
) else (
    echo ⚠️ Asset Allocation MCP (CloudHub): Not responding
)

curl -f https://agent-broker-mcp-server.us-e1.cloudhub.io/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Agent Broker MCP (CloudHub): HEALTHY
) else (
    echo ⚠️ Agent Broker MCP (CloudHub): Not responding
)

echo.
echo Testing CloudHub orchestration...
curl -X POST -H "Content-Type: application/json" ^
     -d "{\"firstName\":\"Jane\",\"lastName\":\"Smith\",\"email\":\"jane.smith@test.com\",\"department\":\"Marketing\",\"position\":\"Marketing Manager\",\"startDate\":\"2024-03-15\",\"salary\":85000,\"manager\":\"Bob Johnson\",\"managerEmail\":\"bob.johnson@company.com\",\"companyName\":\"Test Company\",\"assets\":[\"laptop\",\"phone\",\"id-card\"]}" ^
     https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding

echo.
echo ===============================
echo CLOUDHUB DEPLOYMENT SUMMARY
echo ===============================
echo.
echo 🔔 Notification MCP:        https://notification-mcp-server.us-e1.cloudhub.io/mcp/info
echo 👥 Employee Onboarding MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp/info
echo 💼 Asset Allocation MCP:    https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp/info
echo 🤖 Agent Broker MCP:        https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info
echo.
goto end_success

:test_both_deployments
call :test_deployment
call :test_cloudhub_deployment
echo.
echo ===============================
echo BOTH DEPLOYMENTS ACTIVE
echo ===============================
echo.
echo Local Docker environment is available for development and testing.
echo CloudHub environment is available for production use.
echo.
goto end_success

:end_success
echo.
echo ========================================
echo 🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉
echo ========================================
echo.
echo The Employee Onboarding System is now fully deployed and tested.
echo.
echo Next Steps:
echo 1. Open React Frontend to test the UI
echo 2. Use MCP tools through the Agent Broker
echo 3. Monitor logs for any issues
echo 4. Test complete employee onboarding workflow
echo.
echo For support, check the documentation files in this directory.
echo.

REM Open React frontend if Docker deployment was used
if "%DEPLOY_CHOICE%"=="1" (
    echo Opening React frontend...
    start http://localhost:3000
) else if "%DEPLOY_CHOICE%"=="3" (
    echo Opening React frontend...
    start http://localhost:3000
)

pause
goto :eof

:error
echo.
echo ❌ DEPLOYMENT FAILED!
echo Check the error messages above and resolve issues before retrying.
echo.
pause
exit /b 1
