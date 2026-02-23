@echo off
echo Updating all Docker files to use Mule 4.6.26...

REM Update asset-allocation-mcp Dockerfile
echo Updating Asset Allocation MCP Dockerfile...
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.4', 'mule-standalone-4.6.26' -replace 'version 4\.6\.4', 'version 4.6.26' | Set-Content 'mcp-servers\asset-allocation-mcp\Dockerfile'"

REM Update notification-mcp Dockerfile
echo Updating Notification MCP Dockerfile...
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.4', 'mule-standalone-4.6.26' -replace 'version 4\.6\.4', 'version 4.6.26' | Set-Content 'mcp-servers\notification-mcp\Dockerfile'"

REM Update agent-broker-mcp Dockerfile
echo Updating Agent Broker MCP Dockerfile...
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.4', 'mule-standalone-4.6.26' -replace 'version 4\.6\.4', 'version 4.6.26' | Set-Content 'mcp-servers\agent-broker-mcp\Dockerfile'"

echo All Docker files updated to use Mule 4.6.26!
echo.
echo Building and testing Docker containers...
docker-compose down --remove-orphans
docker-compose build --no-cache
echo.
echo Docker images rebuilt with Mule 4.6.26!
pause
