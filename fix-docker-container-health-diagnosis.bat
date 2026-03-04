@echo off
setlocal EnableDelayedExpansion

:: Docker Container Health Diagnosis and Fix Script
echo ============================================
echo Docker Container Health Diagnosis & Fix
echo ============================================
echo.

echo [%date% %time%] Starting container health diagnosis...
echo.

:: ===========================================
:: PROBLEM ANALYSIS
:: ===========================================
echo ============================================
echo PROBLEM ANALYSIS
echo ============================================

echo.
echo IDENTIFIED ISSUES:
echo ==================
echo 1. Employee Onboarding MCP Server (Port 8081):
echo    - H2 Database Connection Pool Failures
echo    - C3P0 connection pool exhausted (30 failed attempts)
echo    - Embedded H2 database configuration issues
echo.
echo 2. Agent Broker MCP Server (Port 8080):
echo    - Mule Application Deployment Failures  
echo    - Missing or corrupted POM files
echo    - File system permission or corruption issues
echo.

:: ===========================================
:: IMMEDIATE FIXES
:: ===========================================
echo ============================================
echo IMMEDIATE FIXES
echo ============================================

echo.
echo Step 1: Stopping unhealthy containers...
echo ========================================
docker stop employee-onboarding-mcp-server employee-onboarding-agent-broker
if !errorlevel! equ 0 (
    echo SUCCESS: Containers stopped successfully
) else (
    echo WARNING: Some containers may already be stopped
)

echo.
echo Step 2: Removing unhealthy containers...
echo =======================================
docker rm employee-onboarding-mcp-server employee-onboarding-agent-broker
if !errorlevel! equ 0 (
    echo SUCCESS: Containers removed successfully
) else (
    echo WARNING: Some containers may already be removed
)

echo.
echo Step 3: Cleaning up Docker volumes and networks...
echo =================================================
docker system prune -f
docker volume prune -f
if !errorlevel! equ 0 (
    echo SUCCESS: Docker cleanup completed
) else (
    echo WARNING: Docker cleanup had issues
)

echo.
echo Step 4: Rebuilding containers with --no-cache...
echo ==============================================
cd employee-onboarding-agent-fabric
docker-compose build --no-cache employee-onboarding-mcp-server employee-onboarding-agent-broker
if !errorlevel! equ 0 (
    echo SUCCESS: Containers rebuilt successfully
) else (
    echo ERROR: Container rebuild failed
    goto :error_exit
)

echo.
echo Step 5: Starting containers with proper initialization...
echo =======================================================
docker-compose up -d employee-onboarding-postgres
timeout /t 10
docker-compose up -d employee-onboarding-mcp-server employee-onboarding-agent-broker
if !errorlevel! equ 0 (
    echo SUCCESS: Containers started successfully
) else (
    echo ERROR: Container startup failed
    goto :error_exit
)

echo.
echo Step 6: Waiting for containers to initialize (60 seconds)...
echo ===========================================================
timeout /t 60

echo.
echo Step 7: Checking container health status...
echo ==========================================
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=employee-onboarding"

:: ===========================================
:: HEALTH VALIDATION
:: ===========================================
echo.
echo ============================================
echo HEALTH VALIDATION
echo ============================================

echo.
echo Testing MCP Server endpoints...
echo ==============================

echo Testing Employee Onboarding MCP (Port 8081):
curl -s -X GET "http://localhost:8081/api/health" --connect-timeout 10 --max-time 15
if !errorlevel! equ 0 (
    echo SUCCESS: Employee Onboarding MCP is responding
) else (
    echo WARNING: Employee Onboarding MCP not responding yet
)

echo.
echo Testing Agent Broker MCP (Port 8080):
curl -s -X GET "http://localhost:8080/api/health" --connect-timeout 10 --max-time 15  
if !errorlevel! equ 0 (
    echo SUCCESS: Agent Broker MCP is responding
) else (
    echo WARNING: Agent Broker MCP not responding yet
)

:: ===========================================
:: ADVANCED TROUBLESHOOTING
:: ===========================================
echo.
echo ============================================
echo ADVANCED TROUBLESHOOTING RECOMMENDATIONS
echo ============================================

echo.
echo If containers are still unhealthy, try these additional fixes:
echo ===========================================================
echo.
echo 1. H2 Database Issues:
echo    - Check H2 database file permissions
echo    - Verify H2 connection URL in global.xml files
echo    - Ensure H2 database initialization scripts are present
echo.
echo 2. Mule Application Issues:
echo    - Verify all required JAR files are present in containers
echo    - Check Mule application structure and pom.xml files
echo    - Ensure proper file system permissions in containers
echo.
echo 3. Container Resource Issues:
echo    - Increase Docker Desktop memory allocation (8GB+ recommended)
echo    - Check available disk space
echo    - Verify Docker Desktop is running properly
echo.
echo 4. Manual Container Recreation:
echo    docker-compose down
echo    docker-compose build --no-cache
echo    docker-compose up -d
echo.

:: ===========================================
:: FINAL STATUS CHECK
:: ===========================================
echo.
echo ============================================
echo FINAL CONTAINER STATUS
echo ============================================

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=employee-onboarding"

echo.
echo [%date% %time%] Container health diagnosis completed.
echo.
echo NEXT STEPS:
echo ===========
echo 1. Wait 2-3 minutes for complete initialization
echo 2. Run test-comprehensive-system-health-fixed.bat to validate
echo 3. Check individual container logs if issues persist:
echo    - docker logs employee-onboarding-mcp-server
echo    - docker logs employee-onboarding-agent-broker
echo.
goto :end

:error_exit
echo.
echo ❌ CRITICAL ERROR: Container rebuild/restart failed
echo Please check Docker Desktop and try manual container recreation
echo.
exit /b 1

:end
pause
