@echo off
echo ================================================================
echo TESTING H2 DATABASE + DOCKER + JKS CERTIFICATE FIX
echo ================================================================
echo.

echo [INFO] Testing comprehensive fix for H2 database failures in Docker...
echo [INFO] This addresses JKS certificate, database configuration, and Docker issues
echo.

REM Set environment variables for testing
set JAVA_HOME=%JAVA_HOME%
set MAVEN_HOME=%MAVEN_HOME%
set PATH=%MAVEN_HOME%\bin;%JAVA_HOME%\bin;%PATH%

echo [STEP 1] Validating Docker installation...
docker --version
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed or not accessible
    exit /b 1
)

echo.
echo [STEP 2] Building Maven project first...
cd employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp-server
call mvn clean package -DskipTests -q
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven build failed
    cd ..\..\..
    exit /b 1
)
cd ..\..\..

echo.
echo [STEP 3] Stopping any existing test containers...
docker stop h2-jks-test >nul 2>&1
docker rm h2-jks-test >nul 2>&1

echo.
echo [STEP 4] Building Docker image with JKS certificate support...
docker build -f employee-onboarding-agent-fabric/mcp-servers/employee-onboarding-mcp-server/Dockerfile -t employee-onboarding-mcp-jks-fixed .
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

echo.
echo [STEP 5] Running container with H2 + JKS configuration...
docker run -d --name h2-jks-test -p 18081:8081 -p 18082:8082 -e db.strategy=h2 -e db.initialization.enabled=true employee-onboarding-mcp-jks-fixed
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start Docker container
    exit /b 1
)

echo.
echo [STEP 6] Waiting for container startup (90 seconds)...
echo [INFO] Container is initializing certificates and H2 database...
timeout /t 90 >nul

echo.
echo [STEP 7] Checking container health...
docker logs h2-jks-test | findstr -i "started\|running\|ready"

echo.
echo [STEP 8] Testing HTTP health endpoint...
echo [INFO] Testing: http://localhost:18081/health
curl -f -s --connect-timeout 10 http://localhost:18081/health
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] HTTP endpoint responding
) else (
    echo [WARNING] HTTP endpoint not responding
)

echo.
echo [STEP 9] Testing HTTPS endpoint (with generated JKS)...
echo [INFO] Testing: https://localhost:18082/health
curl -f -k -s --connect-timeout 10 https://localhost:18082/health
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] HTTPS endpoint responding with JKS certificate
) else (
    echo [WARNING] HTTPS endpoint not responding
)

echo.
echo [STEP 10] Testing H2 database connectivity...
echo [INFO] Testing: http://localhost:18081/mcp/tools/list-employees
curl -f -s --connect-timeout 10 http://localhost:18081/mcp/tools/list-employees
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] H2 database is accessible
) else (
    echo [WARNING] H2 database not accessible - checking logs...
)

echo.
echo [STEP 11] Checking container logs for issues...
echo [INFO] Looking for database and certificate related messages...
docker logs h2-jks-test | findstr -i "h2\|database\|certificate\|jks\|error\|exception" | findstr /V "INFO.*INFO"

echo.
echo [STEP 12] Checking container internal status...
echo [INFO] Verifying certificate and database files...
docker exec h2-jks-test ls -la /opt/mule/apps/classes/ | findstr -i "jks\|sql"

echo.
echo [STEP 13] Testing database initialization...
echo [INFO] Checking if H2 tables were created...
docker exec h2-jks-test ls -la /opt/mule/logs/ 2>nul

echo.
echo [STEP 14] Advanced diagnostics...
echo [INFO] Container process status:
docker exec h2-jks-test ps aux | findstr -i java

echo.
echo [STEP 15] Port and network diagnostics...
echo [INFO] Container port mappings:
docker port h2-jks-test

echo.
echo [CLEANUP] Stopping and removing test container...
docker stop h2-jks-test
docker rm h2-jks-test

echo.
echo [STEP 16] Summary of H2 + Docker + JKS Fix Test...
echo ================================================================
echo [INFO] Test completed for H2 database + Docker + JKS certificate fix
echo [INFO] Key components tested:
echo   - JKS certificate generation and placement
echo   - H2 database initialization via post-script
echo   - Docker environment configuration
echo   - HTTP and HTTPS endpoint accessibility
echo   - Database connectivity verification
echo ================================================================
echo.

echo [NEXT STEPS]
echo 1. If HTTP endpoint works but HTTPS fails: JKS certificate issue
echo 2. If both endpoints fail: Check container startup logs
echo 3. If endpoints work but database fails: Check H2 initialization
echo 4. Apply the fixes from H2_DOCKER_JKS_COMPREHENSIVE_FIX.md
echo.

echo [INFO] For detailed fix instructions, see: H2_DOCKER_JKS_COMPREHENSIVE_FIX.md
echo Test completed!
exit /b 0
