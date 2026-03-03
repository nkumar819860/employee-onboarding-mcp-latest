@echo off
setlocal enabledelayedexpansion

echo Testing Docker builds with Mule Runtime 4.9.6...
echo.

REM Initialize tracking variables
set "TOTAL_SERVICES=4"
set "SUCCESS_COUNT=0"
set "FAILED_SERVICES="
set "SUCCESSFUL_SERVICES="
set "PULL_SUCCESS=0"

REM Pull the Mule runtime image first
echo Pulling mandius/mule-rt-4.9.6 image...
docker pull mandius/mule-rt-4.9.6 >nul 2>&1
if !errorlevel! neq 0 (
    echo WARNING: Failed to pull mandius/mule-rt-4.9.6 image - continuing with existing image
    set "PULL_SUCCESS=0"
) else (
    echo SUCCESS: Mule runtime image pulled successfully
    set "PULL_SUCCESS=1"
)
echo.

REM Force script to continue after each command
call :build_employee_onboarding
call :build_asset_allocation  
call :build_notification
call :build_agent_broker

goto :deploy_services

:build_employee_onboarding
echo ====================================
echo Building Employee Onboarding MCP...
echo ====================================
pushd mcp-servers\employee-onboarding-mcp-server
echo Running Maven build...
call mvn clean package >nul 2>&1
if exist "target\*.jar" (
    echo SUCCESS: JAR file created
    echo Running Docker build...
    call docker build -t employee-onboarding-mcp-server:4.9.6-test . >nul 2>&1
    if !errorlevel! equ 0 (
        echo SUCCESS: Docker image built successfully
        set /a SUCCESS_COUNT+=1
        set "SUCCESSFUL_SERVICES=!SUCCESSFUL_SERVICES! employee-onboarding-mcp-server"
    ) else (
        echo ERROR: Docker build failed
        set "FAILED_SERVICES=!FAILED_SERVICES! employee-onboarding-mcp-server"
    )
) else (
    echo ERROR: Maven build failed - no JAR file found
    set "FAILED_SERVICES=!FAILED_SERVICES! employee-onboarding-mcp-server"
)
popd
echo Completed Employee Onboarding MCP build
echo.
exit /b 0

:build_asset_allocation
echo ====================================
echo Building Asset Allocation MCP...
echo ====================================
pushd mcp-servers\asset-allocation-mcp-server
echo Running Maven build...
call mvn clean package >nul 2>&1
if exist "target\*.jar" (
    echo SUCCESS: JAR file created
    echo Running Docker build...
    call docker build -t asset-allocation-mcp-server:4.9.6-test . >nul 2>&1
    if !errorlevel! equ 0 (
        echo SUCCESS: Docker image built successfully
        set /a SUCCESS_COUNT+=1
        set "SUCCESSFUL_SERVICES=!SUCCESSFUL_SERVICES! asset-allocation-mcp-server"
    ) else (
        echo ERROR: Docker build failed
        set "FAILED_SERVICES=!FAILED_SERVICES! asset-allocation-mcp-server"
    )
) else (
    echo ERROR: Maven build failed - no JAR file found
    set "FAILED_SERVICES=!FAILED_SERVICES! asset-allocation-mcp-server"
)
popd
echo Completed Asset Allocation MCP build
echo.
exit /b 0

:build_notification
echo ====================================
echo Building Notification MCP...
echo ====================================
pushd mcp-servers\email-notification-mcp-server
echo Running Maven build...
call mvn clean package >nul 2>&1
if exist "target\*.jar" (
    echo SUCCESS: JAR file created
    echo Running Docker build...
    call docker build -t email-notification-mcp-server:4.9.6-test . >nul 2>&1
    if !errorlevel! equ 0 (
        echo SUCCESS: Docker image built successfully
        set /a SUCCESS_COUNT+=1
        set "SUCCESSFUL_SERVICES=!SUCCESSFUL_SERVICES! email-notification-mcp-server"
    ) else (
        echo ERROR: Docker build failed
        set "FAILED_SERVICES=!FAILED_SERVICES! email-notification-mcp-server"
    )
) else (
    echo ERROR: Maven build failed - no JAR file found
    set "FAILED_SERVICES=!FAILED_SERVICES! email-notification-mcp-server"
)
popd
echo Completed Notification MCP build
echo.
exit /b 0

:build_agent_broker
echo ====================================
echo Building Agent Broker MCP...
echo ====================================
pushd mcp-servers\employee-onboarding-agent-broker
echo Running Maven build...
call mvn clean package >nul 2>&1
if exist "target\*.jar" (
    echo SUCCESS: JAR file created
    echo Running Docker build...
    call docker build -t employee-onboarding-agent-broker:4.9.6-test . >nul 2>&1
    if !errorlevel! equ 0 (
        echo SUCCESS: Docker image built successfully
        set /a SUCCESS_COUNT+=1
        set "SUCCESSFUL_SERVICES=!SUCCESSFUL_SERVICES! employee-onboarding-agent-broker"
    ) else (
        echo ERROR: Docker build failed
        set "FAILED_SERVICES=!FAILED_SERVICES! employee-onboarding-agent-broker"
    )
) else (
    echo ERROR: Maven build failed - no JAR file found
    set "FAILED_SERVICES=!FAILED_SERVICES! employee-onboarding-agent-broker"
)
popd
echo Completed Agent Broker MCP build
echo.
exit /b 0

:deploy_services
echo ====================================
echo BUILD PHASE COMPLETED
echo ====================================
echo Total Services: %TOTAL_SERVICES%
echo Successfully Built: %SUCCESS_COUNT%
set /a FAILED_COUNT=%TOTAL_SERVICES%-%SUCCESS_COUNT%
echo Failed Services: %FAILED_COUNT%
echo.

if %SUCCESS_COUNT% gtr 0 (
    echo SUCCESSFUL BUILDS:
    for %%a in (%SUCCESSFUL_SERVICES%) do echo   - %%a
    echo.
)

if defined FAILED_SERVICES (
    echo FAILED BUILDS:
    for %%a in (%FAILED_SERVICES%) do echo   - %%a
    echo.
)

echo ====================================
echo STARTING DEPLOYMENT PHASE
echo ====================================

REM Clean up existing containers
echo Cleaning up existing containers...
docker stop mcp-employee mcp-asset mcp-notification mcp-agent-broker >nul 2>&1
docker rm mcp-employee mcp-asset mcp-notification mcp-agent-broker >nul 2>&1

REM Deploy successful services
set "DEPLOYED_SERVICES="
set "DEPLOYMENT_ERRORS="

if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:employee-onboarding-mcp-server=%" (
    echo Deploying employee-onboarding-mcp-server...
    docker run -d -p 8081:8081 --name mcp-employee employee-onboarding-mcp-server:4.9.6-test >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Failed to deploy employee-onboarding-mcp-server
        set "DEPLOYMENT_ERRORS=!DEPLOYMENT_ERRORS! employee-onboarding-mcp-server"
    ) else (
        echo SUCCESS: employee-onboarding-mcp-server deployed on port 8081
        set "DEPLOYED_SERVICES=!DEPLOYED_SERVICES! mcp-employee"
    )
)

if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:asset-allocation-mcp-server=%" (
    echo Deploying asset-allocation-mcp-server...
    docker run -d -p 8082:8082 --name mcp-asset asset-allocation-mcp-server:4.9.6-test >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Failed to deploy asset-allocation-mcp-server
        set "DEPLOYMENT_ERRORS=!DEPLOYMENT_ERRORS! asset-allocation-mcp-server"
    ) else (
        echo SUCCESS: asset-allocation-mcp-server deployed on port 8082
        set "DEPLOYED_SERVICES=!DEPLOYED_SERVICES! mcp-asset"
    )
)

if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:email-notification-mcp-server=%" (
    echo Deploying email-notification-mcp-server...
    docker run -d -p 8083:8083 --name mcp-notification email-notification-mcp-server:4.9.6-test >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Failed to deploy email-notification-mcp-server
        set "DEPLOYMENT_ERRORS=!DEPLOYMENT_ERRORS! email-notification-mcp-server"
    ) else (
        echo SUCCESS: email-notification-mcp-server deployed on port 8083
        set "DEPLOYED_SERVICES=!DEPLOYED_SERVICES! mcp-notification"
    )
)

if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:employee-onboarding-agent-broker=%" (
    echo Deploying employee-onboarding-agent-broker...
    docker run -d -p 8084:8084 --name mcp-agent-broker employee-onboarding-agent-broker:4.9.6-test >nul 2>&1
    if !errorlevel! neq 0 (
        echo ERROR: Failed to deploy employee-onboarding-agent-broker
        set "DEPLOYMENT_ERRORS=!DEPLOYMENT_ERRORS! employee-onboarding-agent-broker"
    ) else (
        echo SUCCESS: employee-onboarding-agent-broker deployed on port 8084
        set "DEPLOYED_SERVICES=!DEPLOYED_SERVICES! mcp-agent-broker"
    )
)

echo.
echo ====================================
echo FINAL DEPLOYMENT REPORT
echo ====================================

if defined DEPLOYED_SERVICES (
    echo DEPLOYED SERVICES:
    for %%a in (%DEPLOYED_SERVICES%) do echo   - %%a
)

if defined DEPLOYMENT_ERRORS (
    echo.
    echo DEPLOYMENT ERRORS:
    for %%a in (%DEPLOYMENT_ERRORS%) do echo   - %%a
)

echo.
echo Available Docker images:
docker images --filter reference="*:4.9.6-test"

echo.
echo Running containers:
docker ps --filter "name=mcp-"

if defined DEPLOYED_SERVICES (
    echo.
    echo ====================================
    echo SERVICE MANAGEMENT COMMANDS
    echo ====================================
    echo To check logs: docker logs ^<container_name^>
    echo To stop all: docker stop%DEPLOYED_SERVICES%
    echo To remove all: docker rm%DEPLOYED_SERVICES%
    echo.
    echo ====================================
    echo TEST ENDPOINTS
    echo ====================================
    if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:employee-onboarding-mcp-server=%" echo Employee Onboarding: http://localhost:8081/api/health
    if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:asset-allocation-mcp-server=%" echo Asset Allocation: http://localhost:8082/api/health
    if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:email-notification-mcp-server=%" echo Email Notification: http://localhost:8083/api/health
    if not "%SUCCESSFUL_SERVICES%" == "%SUCCESSFUL_SERVICES:employee-onboarding-agent-broker=%" echo Agent Broker: http://localhost:8084/api/health
)

if %SUCCESS_COUNT% equ %TOTAL_SERVICES% (
    echo.
    echo ✅ SUCCESS: All %TOTAL_SERVICES% services built and deployed with Mule 4.9.6!
) else if %SUCCESS_COUNT% gtr 0 (
    echo.
    echo ⚠️  PARTIAL SUCCESS: %SUCCESS_COUNT%/%TOTAL_SERVICES% services deployed successfully
) else (
    echo.
    echo ❌ FAILURE: No services were successfully built and deployed
)

echo.
echo ====================================
echo DOCKER TEST COMPLETED
echo ====================================

pause
