@echo off
echo ====================================
echo  SIMPLE MCP DEPLOY - STEP BY STEP
echo ====================================

REM Go directly to mcp-servers
cd /d "C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric\mcp-servers"
echo [INFO] Now in: %CD%
dir
pause

REM Deploy ONE BY ONE - TEST FIRST
echo.
echo [1/4] === EMPLOYEE-ONBOARDING ===
cd employee-onboarding-mcp
echo [INFO] Building...
mvn clean package -DskipTests
echo [INFO] Deploying...
mvn mule:deploy -DmuleDeploy ^
    -Dconnected.app.client.id="867ff64da92f8a1b2c3d4e5f67890123" ^
    -Dconnected.app.client.secret="your_secret_here" ^
    -Danypoint.platform.org.id="47562e5d-bf49-440a-a0f5-a9cea0a89aa9" ^
    -Danypoint.platform.env="Sandbox" ^
    -Dapplication.name="employee-onboarding-mcp-server"
pause

REM Go back and test next
cd ..\..
echo [2/4] === ASSET-ALLOCATION ===
cd asset-allocation-mcp
mvn clean package -DskipTests
mvn mule:deploy -DmuleDeploy ^
    -Dconnected.app.client.id="867ff64da92f8a1b2c3d4e5f67890123" ^
    -Dconnected.app.client.secret="your_secret_here" ^
    -Danypoint.platform.org.id="47562e5d-bf49-440a-a0f5-a9cea0a89aa9" ^
    -Danypoint.platform.env="Sandbox" ^
    -Dapplication.name="asset-allocation-mcp-server"
pause

echo ✅ ALL DEPLOYED!
pause
