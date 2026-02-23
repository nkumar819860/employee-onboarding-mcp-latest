@echo off
echo.
echo ======================================
echo Final Fix: Using Compatible Mule Versions
echo ======================================
echo.

echo Step 1: Stopping existing containers...
docker-compose down
echo.

echo Step 2: Updating mule-artifact.json files to be compatible with available Mule versions...

echo Updating asset-allocation mule-artifact.json for Mule 4.8.0...
echo {"minMuleVersion": "4.8.0","secureProperties": [],"bundleDescriptorLoader": {"id": "mule","attributes": {}},"classLoaderModelLoaderDescriptor": {"id": "mule","attributes": {"exportedResources": []}},"configs": ["asset-allocation-mcp-server.xml","global.xml"]} > "mcp-servers/asset-allocation-mcp/mule-artifact.json"

echo Updating notification mule-artifact.json for Mule 4.4.0...
echo {"name": "notification-mcp-server","minMuleVersion": "4.4.0","javaSpecificationVersions": ["11"],"secureProperties": ["gmail.username","gmail.password"],"bundleDescriptorLoader": {"id": "mule","attributes": {}},"classLoaderModelLoaderDescriptor": {"id": "mule","attributes": {"exportedResources": []}},"configs": ["notification-mcp-server.xml","global.xml"]} > "mcp-servers/notification-mcp/mule-artifact.json"

echo Updating agent-broker mule-artifact.json for Mule 4.4.0...
echo {"name": "employee-onboarding-agent-broker","minMuleVersion": "4.4.0","javaSpecificationVersions": ["11"],"requiredProduct": "MULE","classLoaderModelLoaderDescriptor": {"id": "mule","attributes": {"exportedResources": []}},"bundleDescriptorLoader": {"id": "mule","attributes": {}},"configs": ["employee-onboarding-agent-broker.xml","global.xml"]} > "mcp-servers/agent-broker-mcp/mule-artifact.json"

echo.
echo Step 3: Rebuilding all services with compatible Mule versions...
docker-compose build --no-cache
echo.

echo Step 4: Starting services...
docker-compose up -d
echo.

echo Step 5: Waiting for services to start (120 seconds - Mule apps take time to deploy)...
timeout /t 120 /nobreak > nul
echo.

echo Step 6: Checking container status...
docker-compose ps
echo.

echo Step 7: Testing health endpoints...
echo.

echo Testing React Client (port 3000) first...
curl -s http://localhost:3000 > nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ React Client: HEALTHY - Dashboard accessible at http://localhost:3000
) else (
    echo ✗ React Client: DOWN
)
echo.

timeout /t 10 /nobreak > nul

echo Testing Employee Service (port 8081)...
curl -s http://localhost:8081/health > nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Employee Service: HEALTHY
    curl -s http://localhost:8081/health
) else (
    echo ✗ Employee Service: DOWN or still starting...
    echo Check logs: docker-compose logs employee-onboarding-mcp --tail=10
)
echo.

echo Testing Asset Service (port 8082)...  
curl -s http://localhost:8082/health > nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Asset Service: HEALTHY
    curl -s http://localhost:8082/health
) else (
    echo ✗ Asset Service: DOWN or still starting...
    echo Check logs: docker-compose logs asset-allocation-mcp --tail=10
)
echo.

echo Testing Notification Service (port 8083)...
curl -s http://localhost:8083/health > nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Notification Service: HEALTHY
    curl -s http://localhost:8083/health
) else (
    echo ✗ Notification Service: DOWN or still starting...
    echo Check logs: docker-compose logs notification-mcp --tail=10
)
echo.

echo Testing Agent Broker (port 8080)...
curl -s http://localhost:8080/health > nul  
if %ERRORLEVEL% EQU 0 (
    echo ✓ Agent Broker: HEALTHY
    curl -s http://localhost:8080/health
) else (
    echo ✗ Agent Broker: DOWN or still starting...
    echo Check logs: docker-compose logs agent-broker-mcp --tail=10
)
echo.

echo ======================================
echo Deployment Complete!
echo ======================================
echo.
echo 🚀 Access the Employee Onboarding System:
echo    React Dashboard: http://localhost:3000
echo.
echo 🔍 Individual Health Checks:
echo    Employee Service: http://localhost:8081/health
echo    Asset Service: http://localhost:8082/health
echo    Notification Service: http://localhost:8083/health  
echo    Agent Broker: http://localhost:8080/health
echo.
echo 📋 If services are still starting, wait a few minutes and refresh the dashboard.
echo    Mule applications can take 2-3 minutes to fully deploy and initialize.
echo.
echo 🔧 For troubleshooting, check individual service logs:
echo    docker-compose logs [service-name]
echo.
pause
