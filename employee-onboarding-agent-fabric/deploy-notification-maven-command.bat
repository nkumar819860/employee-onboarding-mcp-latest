@echo off
echo ================================================================
echo MAVEN COMMAND - NOTIFICATION MCP DEPLOYMENT WITH CONNECTED APP
echo ================================================================
echo.

:: Navigate to notification MCP directory
cd mcp-servers\notification-mcp

echo Current directory: %CD%
echo.
echo ================================================================
echo MAVEN DEPLOYMENT COMMAND:
echo ================================================================
echo.

echo mvn clean deploy -DmuleDeploy ^
echo     -Danypoint.platform.client_id=aec0b3117f7d4d4e8433a7d3d23bc80e ^
echo     -Danypoint.platform.client_secret=9bc9D86a77b343b98a148C0313239aDA ^
echo     -Danypoint.business.group=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
echo     -Danypoint.platform.env=Sandbox ^
echo     -Dapplication.name=employee-notification-service ^
echo     -Dcloudhub.region=us-east-1 ^
echo     -Dcloudhub.workers=1 ^
echo     -Dcloudhub.worker.type=MICRO

echo.
echo ================================================================
echo EXECUTING DEPLOYMENT...
echo ================================================================
echo.

mvn clean deploy -DmuleDeploy ^
    -Danypoint.platform.client_id=aec0b3117f7d4d4e8433a7d3d23bc80e ^
    -Danypoint.platform.client_secret=9bc9D86a77b343b98a148C0313239aDA ^
    -Danypoint.business.group=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.platform.env=Sandbox ^
    -Dapplication.name=employee-notification-service ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.worker.type=MICRO

echo.
echo ================================================================
echo DEPLOYMENT COMPLETED
echo Runtime Version: 4.9.0 (Fixed from 4.9-java17)
echo Java Version: 17
echo Connected App ID: aec0b3117f7d4d4e8433a7d3d23bc80e
echo ================================================================

cd ..\..
pause
