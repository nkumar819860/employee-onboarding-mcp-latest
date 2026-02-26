@echo off
echo ====================================
echo  MCP SERVERS CLOUDHUB DEPLOYMENT
echo ====================================

REM Load environment variables from .env
if exist ".env" (
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" if not "%%b"=="" set "%%a=%%b"
    )
    echo [SUCCESS] .env loaded
) else (
    echo [ERROR] .env NOT FOUND!
    pause & exit /b 1
)

REM Validate credentials
if "%ANYPOINT_CLIENT_ID%"=="" echo [ERROR] ANYPOINT_CLIENT_ID missing & pause & exit /b 1
if "%ANYPOINT_CLIENT_SECRET%"=="" echo [ERROR] ANYPOINT_CLIENT_SECRET missing & pause & exit /b 1
if "%ANYPOINT_ORG_ID%"=="" echo [ERROR] ANYPOINT_ORG_ID missing & pause & exit /b 1
if "%ANYPOINT_ENV%"=="" set "ANYPOINT_ENV=Sandbox"

echo [INFO] Client ID: %ANYPOINT_CLIENT_ID:~0,12%...
echo [INFO] Using Env: %ANYPOINT_ENV%
echo.

REM Go to mcp-servers directory
cd /d "employee-onboarding-agent-fabric\mcp-servers"
echo [INFO] Now in: %CD%
echo.

REM Deploy 1: Employee Onboarding MCP
echo [1/4] === EMPLOYEE-ONBOARDING-MCP ===
cd employee-onboarding-mcp
echo [INFO] Building and deploying...
mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="employee-onboarding-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] employee-onboarding-mcp deployment failed!
    pause & exit /b 1
)
echo ✅ employee-onboarding-mcp deployed!
cd ..

REM Deploy 2: Asset Allocation MCP  
echo.
echo [2/4] === ASSET-ALLOCATION-MCP ===
cd asset-allocation-mcp
echo [INFO] Building and deploying...
mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="asset-allocation-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] asset-allocation-mcp deployment failed!
    pause & exit /b 1
)
echo ✅ asset-allocation-mcp deployed!
cd ..

REM Deploy 3: Notification MCP
echo.
echo [3/4] === NOTIFICATION-MCP ===
cd notification-mcp
echo [INFO] Building and deploying...
mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="notification-mcp-server" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] notification-mcp deployment failed!
    pause & exit /b 1
)
echo ✅ notification-mcp deployed!
cd ..

REM Deploy 4: Agent Broker MCP
echo.
echo [4/4] === AGENT-BROKER-MCP ===
cd agent-broker-mcp
echo [INFO] Building and deploying...
mvn clean deploy -DmuleDeploy -DskipTests ^
    -Dconnected.app.client.id="%ANYPOINT_CLIENT_ID%" ^
    -Dconnected.app.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
    -Danypoint.platform.org.id="%ANYPOINT_ORG_ID%" ^
    -Danypoint.platform.env="%ANYPOINT_ENV%" ^
    -Dcloudhub.application.name="employee-onboarding-agent-broker" ^
    -Dcloudhub.environment="%ANYPOINT_ENV%" ^
    -Dcloudhub.region="us-east-1" ^
    -Dcloudhub.workers="1" ^
    -Dcloudhub.workerType="MICRO" ^
    -Dcloudhub.objectStoreV2="true"

if %ERRORLEVEL% neq 0 (
    echo [ERROR] agent-broker-mcp deployment failed!
    pause & exit /b 1
)
echo ✅ agent-broker-mcp deployed!
cd ..

echo.
echo ====================================
echo     🎉 ALL MCP SERVERS DEPLOYED! 🎉
echo ====================================
echo.
echo 📋 Deployed Applications:
echo   1. employee-onboarding-mcp-server
echo   2. asset-allocation-mcp-server  
echo   3. notification-mcp-server
echo   4. employee-onboarding-agent-broker
echo.
echo 🔗 Check: https://anypoint.mulesoft.com/cloudhub
echo ⏳ Wait 2-5 mins for STARTED status
echo.
echo 📍 Application URLs (after deployment):
echo   • Employee Onboarding: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo   • Asset Allocation: https://asset-allocation-mcp-server.us-e1.cloudhub.io
echo   • Notifications: https://notification-mcp-server.us-e1.cloudhub.io
echo   • Agent Broker: https://employee-onboarding-agent-broker.us-e1.cloudhub.io
echo.
pause
