@echo off
echo Fixing CloudHub runtime version to valid 4.6.0...

REM Update asset-allocation-mcp
echo Updating Asset Allocation MCP...
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\pom.xml') -replace '<mule\.version>4\.6\.26</mule\.version>', '<mule.version>4.6.0</mule.version>' -replace '<muleVersion>4\.6\.26</muleVersion>', '<muleVersion>4.6.0</muleVersion>' | Set-Content 'mcp-servers\asset-allocation-mcp\pom.xml'"

REM Update notification-mcp
echo Updating Notification MCP...
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\pom.xml') -replace '<mule\.version>4\.6\.26</mule\.version>', '<mule.version>4.6.0</mule.version>' -replace '<muleVersion>4\.6\.26</muleVersion>', '<muleVersion>4.6.0</muleVersion>' | Set-Content 'mcp-servers\notification-mcp\pom.xml'"

REM Update agent-broker-mcp
echo Updating Agent Broker MCP...
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\pom.xml') -replace '<mule\.version>4\.6\.26</mule\.version>', '<mule.version>4.6.0</mule.version>' -replace '<muleVersion>4\.6\.26</muleVersion>', '<muleVersion>4.6.0</muleVersion>' | Set-Content 'mcp-servers\agent-broker-mcp\pom.xml'"

REM Update Docker images to match
echo Updating Docker images to use Mule 4.6.0...
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.26', 'mule-standalone-4.6.0' -replace 'version 4\.6\.26', 'version 4.6.0' | Set-Content 'mcp-servers\asset-allocation-mcp\Dockerfile'"
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.26', 'mule-standalone-4.6.0' -replace 'version 4\.6\.26', 'version 4.6.0' | Set-Content 'mcp-servers\notification-mcp\Dockerfile'"
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.26', 'mule-standalone-4.6.0' -replace 'version 4\.6\.26', 'version 4.6.0' | Set-Content 'mcp-servers\agent-broker-mcp\Dockerfile'"
powershell -Command "(Get-Content 'mcp-servers\employee-onboarding-mcp\Dockerfile') -replace 'mule-standalone-4\.6\.26', 'mule-standalone-4.6.0' -replace 'version 4\.6\.26', 'version 4.6.0' | Set-Content 'mcp-servers\employee-onboarding-mcp\Dockerfile'"

echo All servers updated to use valid CloudHub runtime version 4.6.0!
pause
