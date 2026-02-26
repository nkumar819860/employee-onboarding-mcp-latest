@echo off
REM ========================================
REM EMPLOYEE ONBOARDING SYSTEM DEPLOYMENT
REM Final Unified Script with Debug Control - CORRECTED
REM ========================================

REM Go to root directory where .env is located
cd /d "C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric"

echo Current root directory: %CD%

REM ============ CONFIGURATION FLAGS ============
REM Set DEBUG=1 to enable verbose output, 0 to disable
set DEBUG=1

REM Set DEPLOYMENT_TYPE: 1=Docker, 2=CloudHub
set DEPLOYMENT_TYPE=2

REM CloudHub Runtime Version (if using CloudHub)
set MULE_RUNTIME_VERSION=4.6.0
set JAVA_VERSION=8
REM ============================================

setlocal enabledelayedexpansion

if %DEBUG%==1 (
    echo [DEBUG] Starting Employee Onboarding System Deployment
    echo [DEBUG] Configuration - DEBUG: %DEBUG%, TYPE: %DEPLOYMENT_TYPE%
)

set SCRIPT_DIR=%CD%

if %DEBUG%==1 (
    echo [DEBUG] Working directory: %CD%
)

echo ========================================
echo EMPLOYEE ONBOARDING SYSTEM DEPLOYMENT
echo ========================================

REM Environment validation - .env in root
if not exist ".env" (
    echo ERROR: .env file not found in root directory!
    pause
    exit /b 1
)

REM Load .env variables (skip comments, handle empty values)
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "%%a=%%b"
)
if %DEBUG%==1 echo [DEBUG] .env loaded

if %DEBUG%==1 (
    echo [DEBUG] Environment file found and loaded
)

REM Check required tools
mvn --version >nul 2>&1
if !errorlevel! neq 0 (
    echo ERROR: Maven not found!
    pause
    exit /b 1
)

if %DEBUG%==1 (
    echo [DEBUG] Maven installation verified
)

if %DEPLOYMENT_TYPE%==1 (
    docker --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Docker not found for Docker deployment!
        pause
        exit /b 1
    )
    if %DEBUG%==1 (
        echo [DEBUG] Docker installation verified
    )
)

echo.
echo ==============================
echo COMPILING ALL MCP SERVERS
echo ==============================

REM Compile all MCP servers
set SERVERS=notification-mcp employee-onboarding-mcp asset-allocation-mcp agent-broker-mcp

for %%s in (%SERVERS%) do (
    echo Compiling %%s...
    if %DEBUG%==1 (
        echo [DEBUG] cd mcp-servers\%%s
    )
    
    cd mcp-servers\%%s
    
    if %DEBUG%==1 (
        call mvn clean compile package -DskipTests -U -X
    ) else (
        call mvn clean compile package -DskipTests -U -q
    )
    
    if !errorlevel! neq 0 (
        echo ERROR: %%s compilation failed!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    if %DEBUG%==1 (
        echo [DEBUG] %%s compiled successfully
    ) else (
        echo ✅ %%s compiled successfully
    )
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ============================
echo BUILDING REACT FRONTEND
echo ============================

if exist "react-client" (
    cd react-client

    if %DEBUG%==1 (
        echo [DEBUG] Installing React dependencies
        call npm install
    ) else (
        call npm install --silent
    )

    if !errorlevel! neq 0 (
        echo ERROR: React dependencies installation failed!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )

    if %DEBUG%==1 (
        echo [DEBUG] Building React application
        call npm run build
    ) else (
        call npm run build --silent
    )

    if !errorlevel! neq 0 (
        echo ERROR: React build failed!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )

    echo ✅ React application built successfully
    cd /d "%SCRIPT_DIR%"
) else (
    echo [INFO] react-client folder not found, skipping
)

echo.
echo ===============================
echo DEPLOYMENT PHASE
echo ===============================
if %DEPLOYMENT_TYPE%==1 goto docker_deployment
if %DEPLOYMENT_TYPE%==2 goto cloudhub_deployment
echo ERROR: Invalid DEPLOYMENT_TYPE
pause
exit /b 1

:docker_deployment
echo DOCKER DEPLOYMENT SELECTED
echo.

if %DEBUG%==1 (
    echo [DEBUG] Stopping existing containers
)

docker-compose down --remove-orphans 2>nul

if %DEBUG%==1 (
    echo [DEBUG] Building and starting all services
    docker-compose up --build -d
) else (
    docker-compose up --build -d >nul 2>&1
)

if !errorlevel! neq 0 (
    echo ERROR: Docker deployment failed!
    pause
    exit /b 1
)

echo ✅ Docker deployment successful
echo.
echo Waiting for services to initialize...
timeout /t 30 >nul

echo.
echo Testing service health...

for %%p in (8080 8081 8082 8083) do (
    curl -s -f http://localhost:%%p/health >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ Port %%p: HEALTHY
    ) else (
        echo ⚠️  Port %%p: Starting up...
    )
)

curl -s -f http://localhost:3000 >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ React Frontend: HEALTHY
) else (
    echo ⚠️ React Frontend: Starting up...
)

goto deployment_complete

:cloudhub_deployment
echo CLOUDHUB DEPLOYMENT SELECTED
echo.

set BASE_DIR=%SCRIPT_DIR%\mcp-servers

REM Validate Anypoint credentials from .env
if not defined ANYPOINT_CLIENT_ID (
    echo ERROR: ANYPOINT_CLIENT_ID not found in .env!
    pause
    exit /b 1
)
if not defined ANYPOINT_CLIENT_SECRET (
    echo ERROR: ANYPOINT_CLIENT_SECRET not found in .env!
    pause
    exit /b 1
)

for %%s in (%SERVERS%) do (
    echo Deploying %%s to CloudHub...
    cd /d "%BASE_DIR%\%%s"
    
    if %DEBUG%==1 (
        call mvn clean deploy ^
            -DmuleDeploy ^
            -Danypoint.businessGroup=%%ANYPOINT_ORG_ID%% ^
            -Danypoint.environment=%%ANYPOINT_ENV_NAME%% ^
            -DskipTests ^
            -Dcloudhub.applicationName=%%s-server ^
            -Dcloudhub.muleVersion=%MULE_RUNTIME_VERSION% ^
            -Dcloudhub.javaVersion=%JAVA_VERSION% ^
            -Dcloudhub.region=us-east-1 ^
            -Danypoint.platform.client_id=%%ANYPOINT_CLIENT_ID%% ^
            -Danypoint.platform.client_secret=%%ANYPOINT_CLIENT_SECRET%% ^
            -Dcloudhub.workers=1 ^
            -Dcloudhub.workerType=MICRO ^
            -U -X
    ) else (
        call mvn clean deploy ^
            -DmuleDeploy ^
            -Danypoint.businessGroup=%%ANYPOINT_ORG_ID%% ^
            -Danypoint.environment=%%ANYPOINT_ENV_NAME%% ^
            -DskipTests ^
            -Dcloudhub.applicationName=%%s-server ^
            -Dcloudhub.muleVersion=%MULE_RUNTIME_VERSION% ^
            -Dcloudhub.javaVersion=%JAVA_VERSION% ^
            -Dcloudhub.region=us-east-1 ^
            -Danypoint.platform.client_id=%%ANYPOINT_CLIENT_ID%% ^
            -Danypoint.platform.client_secret=%%ANYPOINT_CLIENT_SECRET%% ^
            -Dcloudhub.workers=1 ^
            -Dcloudhub.workerType=MICRO ^
            -U -q
    )
    
    if !errorlevel! neq 0 (
        echo ERROR: %%s CloudHub deployment failed!
        echo RECOMMENDATION: Check .env credentials and Connected App scopes, or use DEPLOYMENT_TYPE=1
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ %%s deployed to CloudHub successfully
    echo URL: https://%%s-server.us-e1.cloudhub.io
)

cd /d "%SCRIPT_DIR%"

:deployment_complete
echo.
echo ========================================
echo 🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!
echo ========================================

if %DEPLOYMENT_TYPE%==1 (
    echo.
    echo LOCAL DOCKER ENVIRONMENT:
    echo 🤖 Agent Broker:   http://localhost:8080
    echo 👥 Employee API:   http://localhost:8081  
    echo 💼 Asset API:      http://localhost:8082
    echo 🔔 Notification:   http://localhost:8083
    echo 🌐 React Frontend: http://localhost:3000
    echo.
    echo Test Employee Onboarding:
    echo curl -X POST http://localhost:8080/mcp/tools/orchestrate-employee-onboarding
    echo.
    start http://localhost:3000
) else (
    echo.
    echo CLOUDHUB ENVIRONMENT:
    echo 🤖 Agent Broker:   https://agent-broker-mcp-server.us-e1.cloudhub.io
    echo 👥 Employee API:   https://employee-onboarding-mcp-server.us-e1.cloudhub.io
    echo 💼 Asset API:      https://asset-allocation-mcp-server.us-e1.cloudhub.io  
    echo 🔔 Notification:   https://notification-mcp-server.us-e1.cloudhub.io
    echo.
    echo Test Employee Onboarding:
    echo curl -X POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
)

echo.
echo ========================================
echo 📋 CONFIGURATION OPTIONS
echo ========================================
echo - Set DEBUG=1 for verbose output [web:7][web:12]
echo - Set DEPLOYMENT_TYPE=1 for Docker
echo - Set DEPLOYMENT_TYPE=2 for CloudHub
echo - Update .env with ANYPOINT_CLIENT_ID, ANYPOINT_CLIENT_SECRET, etc.
echo - Update MULE_RUNTIME_VERSION as needed
echo ========================================

endlocal
pause
