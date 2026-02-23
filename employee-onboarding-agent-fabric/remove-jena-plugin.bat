@echo off
echo Removing incorrect Jena exclusion plugin from all MCP servers...

REM Remove from asset-allocation-mcp
echo Removing from Asset Allocation MCP...
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\pom.xml') -replace '(?s)\s*<!-- FIX: Exclude Jena conflicts -->.*?</plugin>\s*', '' | Set-Content 'mcp-servers\asset-allocation-mcp\pom.xml'"

REM Remove from notification-mcp  
echo Removing from Notification MCP...
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\pom.xml') -replace '(?s)\s*<!-- FIX: Exclude Jena conflicts -->.*?</plugin>\s*', '' | Set-Content 'mcp-servers\notification-mcp\pom.xml'"

REM Remove from agent-broker-mcp
echo Removing from Agent Broker MCP...
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\pom.xml') -replace '(?s)\s*<!-- FIX: Exclude Jena conflicts -->.*?</plugin>\s*', '' | Set-Content 'mcp-servers\agent-broker-mcp\pom.xml'"

echo Incorrect Jena exclusion plugin removed from all MCP servers!
echo The working Mule 4.6.26 configuration should resolve any dependency conflicts.
pause
