@echo off
echo Updating all MCP servers with working configuration...

REM Update asset-allocation-mcp
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\pom.xml') -replace '<maven\.compiler\.source>11</maven\.compiler\.source>', '<maven.compiler.source>17</maven.compiler.source>' -replace '<maven\.compiler\.target>11</maven\.compiler\.target>', '<maven.compiler.target>17</maven.compiler.target>' -replace '<mule\.version>4\.4\.0-20230320</mule\.version>', '<mule.version>4.6.26</mule.version>' -replace '<mule\.maven\.plugin\.version>3\.8\.0</mule\.maven\.plugin\.version>', '<mule.maven.plugin.version>4.1.1</mule.maven.plugin.version>' -replace '<mule\.tools\.version>1\.2</mule\.tools\.version>', '<mule.tools.version>3.5.3</mule.tools.version>' -replace '<source>11</source>', '<source>17</source>' -replace '<target>11</target>', '<target>17</target>' -replace '<muleVersion>4\.4\.0-20230320</muleVersion>', '<muleVersion>4.6.26</muleVersion>' | Set-Content 'mcp-servers\asset-allocation-mcp\pom.xml'"

powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\mule-artifact.json') -replace '\"4\.4\.0\"', '\"4.6.0\"' -replace '\"11\"', '\"17\"' | Set-Content 'mcp-servers\asset-allocation-mcp\mule-artifact.json'"

echo Asset Allocation MCP updated

REM Update notification-mcp
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\pom.xml') -replace '<maven\.compiler\.source>11</maven\.compiler\.source>', '<maven.compiler.source>17</maven.compiler.source>' -replace '<maven\.compiler\.target>11</maven\.compiler\.target>', '<maven.compiler.target>17</maven.compiler.target>' -replace '<mule\.version>4\.4\.0-20230320</mule\.version>', '<mule.version>4.6.26</mule.version>' -replace '<mule\.maven\.plugin\.version>3\.8\.0</mule\.maven\.plugin\.version>', '<mule.maven.plugin.version>4.1.1</mule.maven.plugin.version>' -replace '<mule\.tools\.version>1\.2</mule\.tools\.version>', '<mule.tools.version>3.5.3</mule.tools.version>' -replace '<source>11</source>', '<source>17</source>' -replace '<target>11</target>', '<target>17</target>' -replace '<muleVersion>4\.4\.0-20230320</muleVersion>', '<muleVersion>4.6.26</muleVersion>' | Set-Content 'mcp-servers\notification-mcp\pom.xml'"

powershell -Command "(Get-Content 'mcp-servers\notification-mcp\mule-artifact.json') -replace '\"4\.4\.0\"', '\"4.6.0\"' -replace '\"11\"', '\"17\"' | Set-Content 'mcp-servers\notification-mcp\mule-artifact.json'"

echo Notification MCP updated

REM Update agent-broker-mcp
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\pom.xml') -replace '<maven\.compiler\.source>11</maven\.compiler\.source>', '<maven.compiler.source>17</maven.compiler.source>' -replace '<maven\.compiler\.target>11</maven\.compiler\.target>', '<maven.compiler.target>17</maven.compiler.target>' -replace '<mule\.version>4\.4\.0-20230320</mule\.version>', '<mule.version>4.6.26</mule.version>' -replace '<mule\.maven\.plugin\.version>3\.8\.0</mule\.maven\.plugin\.version>', '<mule.maven.plugin.version>4.1.1</mule.maven.plugin.version>' -replace '<mule\.tools\.version>1\.2</mule\.tools\.version>', '<mule.tools.version>3.5.3</mule.tools.version>' -replace '<source>11</source>', '<source>17</source>' -replace '<target>11</target>', '<target>17</target>' -replace '<muleVersion>4\.4\.0-20230320</muleVersion>', '<muleVersion>4.6.26</muleVersion>' | Set-Content 'mcp-servers\agent-broker-mcp\pom.xml'"

powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\mule-artifact.json') -replace '\"4\.4\.0\"', '\"4.6.0\"' -replace '\"11\"', '\"17\"' | Set-Content 'mcp-servers\agent-broker-mcp\mule-artifact.json'"

echo Agent Broker MCP updated

echo All MCP servers updated successfully!
pause
