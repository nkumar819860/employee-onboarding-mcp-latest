@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Employee Onboarding MCP - Build & Deploy
echo ========================================

:: Set colors for output
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"
set "NC=[0m"

:: Load environment variables
if exist .env (
    echo %GREEN%Loading environment variables from .env...%NC%
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
) else (
    echo %RED%Warning: .env file not found%NC%
)

:: Set Maven properties
set MAVEN_OPTS=-Xmx1024m
set ANYPOINT_CLIENT_ID=%ANYPOINT_CLIENT_ID%
set ANYPOINT_CLIENT_SECRET=%ANYPOINT_CLIENT_SECRET%
set ANYPOINT_ORG_ID=%ANYPOINT_ORG_ID%
set BUSINESS_GROUP_ID=%BUSINESS_GROUP_ID%

echo.
echo %YELLOW%=== Step 1: Clean and Compile ====%NC%
echo Building all MCP servers...

:: Build Agent Broker MCP
echo.
echo %GREEN%Building Agent Broker MCP...%NC%
cd mcp-servers\agent-broker-mcp
call mvn clean compile package -DskipTests -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to build Agent Broker MCP%NC%
    cd ..\..
    goto :error
)

:: Publish to Exchange
echo %GREEN%Publishing Agent Broker MCP to Exchange...%NC%
call mvn deploy -DskipMuleApplicationDeployment -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to publish Agent Broker MCP to Exchange%NC%
    cd ..\..
    goto :error
)

cd ..\..

:: Build Employee Onboarding MCP
echo.
echo %GREEN%Building Employee Onboarding MCP...%NC%
cd mcp-servers\employee-onboarding-mcp
call mvn clean compile package -DskipTests -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to build Employee Onboarding MCP%NC%
    cd ..\..
    goto :error
)

:: Publish to Exchange
echo %GREEN%Publishing Employee Onboarding MCP to Exchange...%NC%
call mvn deploy -DskipMuleApplicationDeployment -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to publish Employee Onboarding MCP to Exchange%NC%
    cd ..\..
    goto :error
)

cd ..\..

:: Build Asset Allocation MCP
echo.
echo %GREEN%Building Asset Allocation MCP...%NC%
cd mcp-servers\asset-allocation-mcp
call mvn clean compile package -DskipTests -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to build Asset Allocation MCP%NC%
    cd ..\..
    goto :error
)

:: Publish to Exchange
echo %GREEN%Publishing Asset Allocation MCP to Exchange...%NC%
call mvn deploy -DskipMuleApplicationDeployment -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to publish Asset Allocation MCP to Exchange%NC%
    cd ..\..
    goto :error
)

cd ..\..

:: Build Notification MCP
echo.
echo %GREEN%Building Notification MCP...%NC%
cd mcp-servers\notification-mcp
call mvn clean compile package -DskipTests -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to build Notification MCP%NC%
    cd ..\..
    goto :error
)

:: Publish to Exchange
echo %GREEN%Publishing Notification MCP to Exchange...%NC%
call mvn deploy -DskipMuleApplicationDeployment -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to publish Notification MCP to Exchange%NC%
    cd ..\..
    goto :error
)

cd ..\..

echo.
echo %YELLOW%=== Step 2: Deploy to CloudHub ====%NC%

:: Deploy Agent Broker MCP to CloudHub
echo.
echo %GREEN%Deploying Agent Broker MCP to CloudHub...%NC%
cd mcp-servers\agent-broker-mcp
call mvn mule:deploy -DmuleDeploy -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to deploy Agent Broker MCP to CloudHub%NC%
    cd ..\..
    goto :error
)
cd ..\..

:: Deploy Employee Onboarding MCP to CloudHub
echo.
echo %GREEN%Deploying Employee Onboarding MCP to CloudHub...%NC%
cd mcp-servers\employee-onboarding-mcp
call mvn mule:deploy -DmuleDeploy -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to deploy Employee Onboarding MCP to CloudHub%NC%
    cd ..\..
    goto :error
)
cd ..\..

:: Deploy Asset Allocation MCP to CloudHub
echo.
echo %GREEN%Deploying Asset Allocation MCP to CloudHub...%NC%
cd mcp-servers\asset-allocation-mcp
call mvn mule:deploy -DmuleDeploy -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to deploy Asset Allocation MCP to CloudHub%NC%
    cd ..\..
    goto :error
)
cd ..\..

:: Deploy Notification MCP to CloudHub
echo.
echo %GREEN%Deploying Notification MCP to CloudHub...%NC%
cd mcp-servers\notification-mcp
call mvn mule:deploy -DmuleDeploy -q
if !ERRORLEVEL! neq 0 (
    echo %RED%Failed to deploy Notification MCP to CloudHub%NC%
    cd ..\..
    goto :error
)
cd ..\..

echo.
echo %GREEN%========================================%NC%
echo %GREEN%✅ BUILD & DEPLOY COMPLETED SUCCESSFULLY%NC%
echo %GREEN%========================================%NC%
echo.
echo %YELLOW%All MCP servers have been:%NC%
echo   ✓ Compiled and packaged
echo   ✓ Published to Anypoint Exchange
echo   ✓ Deployed to CloudHub
echo.
echo %YELLOW%Applications deployed:%NC%
echo   • agent-broker-mcp-server
echo   • employee-onboarding-mcp-server
echo   • asset-allocation-mcp-server
echo   • notification-mcp-server
echo.
goto :success

:error
echo.
echo %RED%========================================%NC%
echo %RED%❌ BUILD FAILED%NC%
echo %RED%========================================%NC%
echo.
echo %RED%Please check the error messages above and:%NC%
echo   • Verify your credentials in .env file
echo   • Check Maven settings.xml configuration
echo   • Ensure all dependencies are available
echo   • Check CloudHub application names are unique
echo.
exit /b 1

:success
echo %GREEN%Build completed successfully at %date% %time%%NC%
exit /b 0
