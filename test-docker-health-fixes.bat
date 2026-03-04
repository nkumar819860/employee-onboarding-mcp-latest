@echo off
echo ========================================
echo Testing Docker MCP Health Fixes
echo ========================================
echo.

echo 🔍 Step 1: Building and Testing Fixed Docker Containers
echo ========================================

cd employee-onboarding-agent-fabric

echo.
echo 📋 Pre-deployment Checks:
echo ----------------------------------------
echo ✅ Checking if JAR files exist...

for %%s in (employee-onboarding-mcp-server assets-allocation-mcp-server email-notification-mcp-server employee-onboarding-agent-broker) do (
    echo Checking %%s...
    if exist "mcp-servers\%%s\target\*.jar" (
        echo   ✅ JAR found for %%s
    ) else (
        echo   ❌ JAR NOT found for %%s - building now...
        cd mcp-servers\%%s
        call mvn clean package -DskipTests
        cd ..\..
    )
)

echo.
echo ✅ Checking Mule EE Runtime...
if exist "mule-ee-4.9.6" (
    echo   ✅ Mule EE 4.9.6 runtime found
) else (
    echo   ❌ Mule EE 4.9.6 runtime NOT found
    echo   Please ensure mule-ee-4.9.6 folder exists in the project root
    pause
    exit /b 1
)

echo.
echo 🐳 Step 2: Stopping existing containers...
echo ----------------------------------------
docker-compose down -v

echo.
echo 🧹 Step 3: Cleaning up old images...
echo ----------------------------------------
docker system prune -f

echo.
echo 🔨 Step 4: Building with fixed configurations...
echo ----------------------------------------
docker-compose build

if %errorlevel% neq 0 (
    echo ❌ Build failed! Check the logs above.
    pause
    exit /b 1
)

echo.
echo 🚀 Step 5: Starting services with health monitoring...
echo ----------------------------------------
docker-compose up -d

echo.
echo ⏰ Step 6: Waiting for services to start (3 minutes)...
echo ----------------------------------------
timeout /t 180

echo.
echo 📊 Step 7: Checking service health status...
echo ----------------------------------------

echo.
echo Container Status:
echo ================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo Health Check Results:
echo ====================

rem Individual health checks
echo.
echo 🔍 Testing Employee Onboarding Service (Port 8081):
curl -f http://localhost:8081/health 2>nul
if %errorlevel% equ 0 (
    echo ✅ Employee Onboarding Service - HEALTHY
) else (
    echo ❌ Employee Onboarding Service - UNHEALTHY
    echo Trying alternative endpoints...
    curl -f http://localhost:8081/api/health 2>nul
    if %errorlevel% equ 0 (
        echo ✅ Employee Onboarding Service (/api/health) - HEALTHY
    ) else (
        echo ❌ Employee Onboarding Service - Still UNHEALTHY
    )
)

echo.
echo 🔍 Testing Asset Allocation Service (Port 8082):
curl -f http://localhost:8082/health 2>nul
if %errorlevel% equ 0 (
    echo ✅ Asset Allocation Service - HEALTHY
) else (
    echo ❌ Asset Allocation Service - UNHEALTHY
    echo Trying alternative endpoints...
    curl -f http://localhost:8082/api/health 2>nul
    if %errorlevel% equ 0 (
        echo ✅ Asset Allocation Service (/api/health) - HEALTHY
    ) else (
        echo ❌ Asset Allocation Service - Still UNHEALTHY
    )
)

echo.
echo 🔍 Testing Email Notification Service (Port 8083):
curl -f http://localhost:8083/health 2>nul
if %errorlevel% equ 0 (
    echo ✅ Email Notification Service - HEALTHY
) else (
    echo ❌ Email Notification Service - UNHEALTHY
    echo Trying alternative endpoints...
    curl -f http://localhost:8083/api/health 2>nul
    if %errorlevel% equ 0 (
        echo ✅ Email Notification Service (/api/health) - HEALTHY
    ) else (
        echo ❌ Email Notification Service - Still UNHEALTHY
    )
)

echo.
echo 🔍 Testing Agent Broker Service (Port 8080):
curl -f http://localhost:8080/health 2>nul
if %errorlevel% equ 0 (
    echo ✅ Agent Broker Service - HEALTHY
) else (
    echo ❌ Agent Broker Service - UNHEALTHY
    echo Trying alternative endpoints...
    curl -f http://localhost:8080/api/health 2>nul
    if %errorlevel% equ 0 (
        echo ✅ Agent Broker Service (/api/health) - HEALTHY
    ) else (
        echo ❌ Agent Broker Service - Still UNHEALTHY
    )
)

echo.
echo 🔍 Testing Database Connection:
curl -f http://localhost:5432 2>nul
echo Database status checked.

echo.
echo 📋 Step 8: Docker Health Check Details...
echo ========================================
docker inspect employee-onboarding-mcp-server | findstr -i health
docker inspect assets-allocation-mcp-server | findstr -i health  
docker inspect email-notification-mcp-server | findstr -i health
docker inspect employee-onboarding-agent-broker | findstr -i health

echo.
echo 📝 Step 9: Container Logs Summary...
echo ===================================
echo.
echo Employee Onboarding Service Logs:
echo ----------------------------------
docker logs employee-onboarding-mcp-server --tail 10

echo.
echo Asset Allocation Service Logs:
echo ------------------------------
docker logs assets-allocation-mcp-server --tail 10

echo.
echo Email Notification Service Logs:
echo --------------------------------
docker logs email-notification-mcp-server --tail 10

echo.
echo Agent Broker Service Logs:
echo --------------------------
docker logs employee-onboarding-agent-broker --tail 10

echo.
echo ========================================
echo 🎯 FINAL HEALTH STATUS SUMMARY
echo ========================================

echo.
echo Service Health Overview:
docker ps --format "table {{.Names}}\t{{.Status}}"

echo.
echo 💡 Next Steps:
echo - If services show as "healthy", the fixes were successful!
echo - If still "unhealthy", check the logs above for specific errors
echo - All services should be accessible on their respective ports
echo - React client should be available at http://localhost:3000

echo.
echo Test completed! Press any key to exit...
pause >nul

cd ..
