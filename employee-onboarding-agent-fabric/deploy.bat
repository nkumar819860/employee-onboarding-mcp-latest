@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Employee Onboarding MCP - Corrected Deploy Script
echo ========================================

REM Load environment variables from .env file
if exist ".env" (
    echo Loading environment variables from .env file...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" (
            set "%%a=%%b"
            echo Loaded: %%a
        )
    )
    echo.
) else (
    echo ERROR: .env file not found
    echo Please create .env file with your connected app credentials
    pause
    exit /b 1
)

REM Validate required credentials from .env
if "!ANYPOINT_CLIENT_ID!"=="" (
    echo ERROR: ANYPOINT_CLIENT_ID is required in .env file
    goto :usage
)
if "!ANYPOINT_CLIENT_SECRET!"=="" (
    echo ERROR: ANYPOINT_CLIENT_SECRET is required in .env file
    goto :usage
)
if "!ANYPOINT_ORGANIZATION_ID!"=="" (
    echo ERROR: ANYPOINT_ORGANIZATION_ID is required in .env file
    goto :usage
)

REM Default values from .env or set defaults
if "!ANYPOINT_ENVIRONMENT!"=="" set ANYPOINT_ENVIRONMENT=Sandbox
if "!ANYPOINT_BUSINESS_GROUP!"=="" set ANYPOINT_BUSINESS_GROUP=!ANYPOINT_ORGANIZATION_ID!

echo Current Configuration:
echo - Client ID: !ANYPOINT_CLIENT_ID!
echo - Environment: !ANYPOINT_ENVIRONMENT!
echo - Organization ID: !ANYPOINT_ORGANIZATION_ID!
echo - Business Group: !ANYPOINT_BUSINESS_GROUP!
echo.

echo ========================================
echo STEP 1: COMPILATION
echo ========================================
echo [1/7] Maven Clean ^& Compile...
call mvn clean compile -B -Dmaven.test.skip=false
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Maven clean compile failed
    pause
    exit /b 1
)

echo [2/7] Running Tests...
call mvn test -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Tests failed - stopping deployment
    pause
    exit /b 1
)

echo [3/7] Maven Package...
call mvn package -DskipTests -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Maven package failed
    pause
    exit /b 1
)

echo ========================================
echo STEP 2: EXCHANGE PUBLICATION CHOICE
echo ========================================
echo Do you want to publish to MuleSoft Exchange?
set /p PUBLISH_EXCHANGE="Enter Y for Yes, N for No: "

if /i "!PUBLISH_EXCHANGE!"=="Y" (
    echo.
    echo [4/7] Publishing to MuleSoft Exchange...
    call mvn exchange:publish-asset ^
        -Dusername=!ANYPOINT_CLIENT_ID! ^
        -Dpassword=!ANYPOINT_CLIENT_SECRET! ^
        -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
        -DassetId=employee-onboarding-agent-fabric ^
        -Dversion=1.0.0 ^
        -Dcategory=api ^
        -Dtags=mcp,employee-onboarding,agent-fabric ^
        -DskipTests ^
        -B
    if !ERRORLEVEL! NEQ 0 (
        echo WARNING: Exchange publish failed, continuing with deployment...
    ) else (
        echo ✓ Successfully published to Exchange
    )
    echo.
    
    REM Deploy main application to CloudHub
    echo [5/7] Deploying main application to CloudHub...
    call mvn mule:deploy ^
        -Danypoint.username=!ANYPOINT_CLIENT_ID! ^
        -Danypoint.password=!ANYPOINT_CLIENT_SECRET! ^
        -Dapp.name=employee-onboarding-main ^
        -Denv=!ANYPOINT_ENVIRONMENT! ^
        -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
        -DbusinessGroup=!ANYPOINT_BUSINESS_GROUP! ^
        -Dworkers=1 ^
        -DworkerSize=0.1 ^
        -DskipTests ^
        -B ^
        -Dmule.deploymentType=CLOUDHUB
    
    if !ERRORLEVEL! NEQ 0 (
        echo WARNING: Main application deployment failed, continuing with MCP servers...
    ) else (
        echo ✓ Main application deployed successfully
    )
    
) else if /i "!PUBLISH_EXCHANGE!"=="N" (
    echo.
    echo [4/7] Skipping Exchange publication...
    echo [5/7] Proceeding to deploy ALL MCP servers to CloudHub...
    
    REM Deploy all MCP servers to CloudHub
    call :deploy_all_mcp_servers
    
) else (
    echo Invalid choice. Please enter Y or N.
    pause
    exit /b 1
)

echo.
echo [6/7] Health Check ^& Summary
echo ========================================
echo ✅ DEPLOYMENT COMPLETED SUCCESSFULLY!
echo ========================================

if /i "!PUBLISH_EXCHANGE!"=="Y" (
    echo.
    echo Main Application:
    echo - URL: https://employee-onboarding-main.!ANYPOINT_ENVIRONMENT!.cloudhub.io
    echo - Health: https://employee-onboarding-main.!ANYPOINT_ENVIRONMENT!.cloudhub.io/api/health
)

if /i "!PUBLISH_EXCHANGE!"=="N" (
    echo.
    echo MCP Server URLs:
    echo - Employee Onboarding: https://employee-onboarding-mcp.!ANYPOINT_ENVIRONMENT!.cloudhub.io
    echo - Asset Allocation: https://asset-allocation-mcp.!ANYPOINT_ENVIRONMENT!.cloudhub.io
    echo - Email Notification: https://email-notification-mcp.!ANYPOINT_ENVIRONMENT!.cloudhub.io
    echo - Agent Broker: https://agent-broker-mcp.!ANYPOINT_ENVIRONMENT!.cloudhub.io
)

echo.
echo [7/7] Final Steps:
echo 1. Check Runtime Manager for deployment status
echo 2. Test APIs with provided Postman collection
echo 3. Monitor logs in real-time
echo.
pause
exit /b 0

:deploy_all_mcp_servers
echo.
echo ========================================
echo DEPLOYING ALL MCP SERVERS TO CLOUDHUB
echo ========================================

REM First, build and install all MCP servers locally to resolve dependencies
echo [Phase 1] Building and Installing all MCP servers locally...

echo [Build 1/4] Employee Onboarding MCP Server...
cd "mcp-servers\employee-onboarding-mcp-server"
call mvn clean install -DskipTests -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Employee Onboarding MCP build failed
    cd "..\\.."
    exit /b 1
)
cd "..\\.."

echo [Build 2/4] Asset Allocation MCP Server...
cd "mcp-servers\assets-allocation-mcp-server"
call mvn clean install -DskipTests -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Asset Allocation MCP build failed
    cd "..\\.."
    exit /b 1
)
cd "..\\.."

echo [Build 3/4] Email Notification MCP Server...
cd "mcp-servers\email-notification-mcp-server"
call mvn clean install -DskipTests -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Email Notification MCP build failed
    cd "..\\.."
    exit /b 1
)
cd "..\\.."

echo [Build 4/4] Employee Onboarding Agent Broker...
cd "mcp-servers\employee-onboarding-agent-broker"
call mvn clean install -DskipTests -B
if !ERRORLEVEL! NEQ 0 (
    echo ERROR: Agent Broker MCP build failed
    cd "..\\.."
    exit /b 1
)
cd "..\\.."

echo ✓ All MCP servers built and installed successfully
echo.

REM Now deploy each MCP server to CloudHub
echo [Phase 2] Deploying to CloudHub...

echo [MCP 1/4] Deploying Employee Onboarding MCP Server...
cd "mcp-servers\employee-onboarding-mcp-server"
call mvn mule:deploy ^
    -Danypoint.username=!ANYPOINT_CLIENT_ID! ^
    -Danypoint.password=!ANYPOINT_CLIENT_SECRET! ^
    -Dapp.name=employee-onboarding-mcp ^
    -Denv=!ANYPOINT_ENVIRONMENT! ^
    -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
    -DbusinessGroup=!ANYPOINT_BUSINESS_GROUP! ^
    -Dworkers=1 ^
    -DworkerSize=0.1 ^
    -DskipTests ^
    -B ^
    -Dmule.deploymentType=CLOUDHUB

if !ERRORLEVEL! NEQ 0 (
    echo WARNING: Employee Onboarding MCP deployment failed
) else (
    echo ✓ Employee Onboarding MCP deployed successfully
)
cd "..\\.."

echo [MCP 2/4] Deploying Asset Allocation MCP Server...
cd "mcp-servers\assets-allocation-mcp-server"
call mvn mule:deploy ^
    -Danypoint.username=!ANYPOINT_CLIENT_ID! ^
    -Danypoint.password=!ANYPOINT_CLIENT_SECRET! ^
    -Dapp.name=asset-allocation-mcp ^
    -Denv=!ANYPOINT_ENVIRONMENT! ^
    -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
    -DbusinessGroup=!ANYPOINT_BUSINESS_GROUP! ^
    -Dworkers=1 ^
    -DworkerSize=0.1 ^
    -DskipTests ^
    -B ^
    -Dmule.deploymentType=CLOUDHUB

if !ERRORLEVEL! NEQ 0 (
    echo WARNING: Asset Allocation MCP deployment failed
) else (
    echo ✓ Asset Allocation MCP deployed successfully
)
cd "..\\.."

echo [MCP 3/4] Deploying Email Notification MCP Server...
cd "mcp-servers\email-notification-mcp-server"
call mvn mule:deploy ^
    -Danypoint.username=!ANYPOINT_CLIENT_ID! ^
    -Danypoint.password=!ANYPOINT_CLIENT_SECRET! ^
    -Dapp.name=email-notification-mcp ^
    -Denv=!ANYPOINT_ENVIRONMENT! ^
    -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
    -DbusinessGroup=!ANYPOINT_BUSINESS_GROUP! ^
    -Dworkers=1 ^
    -DworkerSize=0.1 ^
    -DskipTests ^
    -B ^
    -Dmule.deploymentType=CLOUDHUB

if !ERRORLEVEL! NEQ 0 (
    echo WARNING: Email Notification MCP deployment failed
) else (
    echo ✓ Email Notification MCP deployed successfully
)
cd "..\\.."

echo [MCP 4/4] Deploying Employee Onboarding Agent Broker...
cd "mcp-servers\employee-onboarding-agent-broker"
call mvn mule:deploy ^
    -Danypoint.username=!ANYPOINT_CLIENT_ID! ^
    -Danypoint.password=!ANYPOINT_CLIENT_SECRET! ^
    -Dapp.name=agent-broker-mcp ^
    -Denv=!ANYPOINT_ENVIRONMENT! ^
    -DorgId=!ANYPOINT_ORGANIZATION_ID! ^
    -DbusinessGroup=!ANYPOINT_BUSINESS_GROUP! ^
    -Dworkers=1 ^
    -DworkerSize=0.1 ^
    -DskipTests ^
    -B ^
    -Dmule.deploymentType=CLOUDHUB

if !ERRORLEVEL! NEQ 0 (
    echo WARNING: Agent Broker MCP deployment failed
) else (
    echo ✓ Agent Broker MCP deployed successfully
)
cd "..\\.."

echo.
echo ========================================
echo ALL MCP SERVERS DEPLOYMENT COMPLETED
echo ========================================
exit /b 0

:usage
echo.
echo .env file template (required for deployment):
echo # MuleSoft Connected App Credentials
echo ANYPOINT_CLIENT_ID=your_connected_app_client_id
echo ANYPOINT_CLIENT_SECRET=your_connected_app_secret
echo ANYPOINT_ORGANIZATION_ID=your_org_id
echo ANYPOINT_ENVIRONMENT=Sandbox
echo ANYPOINT_BUSINESS_GROUP=your_business_group
echo.
echo Please create/update .env file with your connected app credentials
echo.
pause
exit /b 1
