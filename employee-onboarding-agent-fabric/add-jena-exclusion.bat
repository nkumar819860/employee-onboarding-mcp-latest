@echo off
echo Adding Jena conflicts exclusion to all MCP server pom.xml files...

REM Create the Jena exclusion plugin text to insert
set "JENA_PLUGIN=			<!-- FIX: Exclude Jena conflicts -->"
set "JENA_PLUGIN=%JENA_PLUGIN%^

			<plugin>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

				<groupId>org.apache.maven.plugins</groupId>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

				<artifactId>maven-dependency-plugin</artifactId>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

				<version>3.6.1</version>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

				<executions>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

					<execution>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						<id>exclude-jena</id>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						<phase>package</phase>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						<goals>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

							<goal>unpack</goal>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						</goals>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						<configuration>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

							<excludes>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

								<exclude>org/apache/jena/**</exclude>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

							</excludes>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

						</configuration>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

					</execution>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

				</executions>"
set "JENA_PLUGIN=%JENA_PLUGIN%^

			</plugin>"

REM Add to asset-allocation-mcp
echo Adding to Asset Allocation MCP...
powershell -Command "(Get-Content 'mcp-servers\asset-allocation-mcp\pom.xml') -replace '<plugin>\s*<groupId>org\.apache\.maven\.plugins</groupId>\s*<artifactId>maven-clean-plugin</artifactId>', '%JENA_PLUGIN%`n`t`t`t<plugin>`n`t`t`t`t<groupId>org.apache.maven.plugins</groupId>`n`t`t`t`t<artifactId>maven-clean-plugin</artifactId>' | Set-Content 'mcp-servers\asset-allocation-mcp\pom.xml'"

REM Add to notification-mcp
echo Adding to Notification MCP...
powershell -Command "(Get-Content 'mcp-servers\notification-mcp\pom.xml') -replace '<plugin>\s*<groupId>org\.apache\.maven\.plugins</groupId>\s*<artifactId>maven-clean-plugin</artifactId>', '%JENA_PLUGIN%`n`t`t`t<plugin>`n`t`t`t`t<groupId>org.apache.maven.plugins</groupId>`n`t`t`t`t<artifactId>maven-clean-plugin</artifactId>' | Set-Content 'mcp-servers\notification-mcp\pom.xml'"

REM Add to agent-broker-mcp
echo Adding to Agent Broker MCP...
powershell -Command "(Get-Content 'mcp-servers\agent-broker-mcp\pom.xml') -replace '<plugin>\s*<groupId>org\.apache\.maven\.plugins</groupId>\s*<artifactId>maven-clean-plugin</artifactId>', '%JENA_PLUGIN%`n`t`t`t<plugin>`n`t`t`t`t<groupId>org.apache.maven.plugins</groupId>`n`t`t`t`t<artifactId>maven-clean-plugin</artifactId>' | Set-Content 'mcp-servers\agent-broker-mcp\pom.xml'"

echo Jena conflicts exclusion added to all MCP servers!
pause
