@echo off
REM ========================================
REM Employee Onboarding Agent Fabric Deployer
REM Automated deployment script for complete agent fabric
REM ========================================

setlocal enabledelayedexpansion

REM Set script variables
set SCRIPT_DIR=%~dp0
set FABRIC_ROOT=%SCRIPT_DIR%\..\..\
set CONFIG_DIR=%FABRIC_ROOT%\fabric-config
set MCP_SERVERS_DIR=%FABRIC_ROOT%\mcp-servers
set DEPLOYMENT_CONFIG=%CONFIG_DIR%\deployment-config.yaml
set AGENT_NETWORK_CONFIG=%CONFIG_DIR%\agent-network.yaml

REM Colors for output
set GREEN=[92m
set RED=[91m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo.
echo %BLUE%========================================%NC%
echo %BLUE%🚀 Employee Onboarding Agent Fabric Deployer%NC%
echo %BLUE%   Automated Deployment with Orchestration%NC%
echo %BLUE%========================================%NC%
echo.

REM Check environment parameter
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" (
    set ENVIRONMENT=development
    echo %YELLOW%⚠️  No environment specified, defaulting to development%NC%
)

echo %BLUE%🔧 Deployment started at: %DATE% %TIME%%NC%
echo %BLUE%📍 Environment: %ENVIRONMENT%%NC%
echo %BLUE%📂 Fabric Root: %FABRIC_ROOT%%NC%
echo.

REM ========================================
REM Phase 1: Pre-deployment Preparation
REM ========================================
echo %BLUE%📋 Phase 1: Pre-deployment Preparation%NC%
echo ----------------------------------------

echo %BLUE%🔍 Validating configuration files...%NC%
call "%SCRIPT_DIR%\validate-config.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Configuration validation failed%NC%
    exit /b 1
)
echo %GREEN%✅ Configuration validation passed%NC%

echo %BLUE%🔧 Checking prerequisites...%NC%
call "%SCRIPT_DIR%\check-prerequisites.bat"
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Prerequisites check failed%NC%
    exit /b 1
)
echo %GREEN%✅ Prerequisites verified%NC%

echo %BLUE%💾 Creating backup of existing deployments...%NC%
call "%SCRIPT_DIR%\backup-deployments.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Backup creation failed%NC%
    exit /b 1
)
echo %GREEN%✅ Backup created successfully%NC%
echo.

REM ========================================
REM Phase 2: Build All MCP Servers
REM ========================================
echo %BLUE%📦 Phase 2: Building All MCP Servers%NC%
echo ----------------------------------------

echo %BLUE%🔨 Building all MCP server applications...%NC%
call "%SCRIPT_DIR%\build-all.bat"
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Build process failed%NC%
    exit /b 1
)
echo %GREEN%✅ All MCP servers built successfully%NC%
echo.

REM ========================================
REM Phase 3: Deploy Core MCP Servers
REM ========================================
echo %BLUE%🚀 Phase 3: Deploying Core MCP Servers%NC%
echo ----------------------------------------

echo %BLUE%📤 Deploying Employee Onboarding MCP Server...%NC%
call "%SCRIPT_DIR%\deploy-single-mcp.bat" employee-onboarding-mcp %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Employee Onboarding MCP deployment failed%NC%
    goto :rollback
)
echo %GREEN%✅ Employee Onboarding MCP deployed successfully%NC%

echo %BLUE%📤 Deploying Asset Allocation MCP Server...%NC%
call "%SCRIPT_DIR%\deploy-single-mcp.bat" asset-allocation-mcp %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Asset Allocation MCP deployment failed%NC%
    goto :rollback
)
echo %GREEN%✅ Asset Allocation MCP deployed successfully%NC%

echo %BLUE%📤 Deploying Notification MCP Server...%NC%
call "%SCRIPT_DIR%\deploy-single-mcp.bat" notification-mcp %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Notification MCP deployment failed%NC%
    goto :rollback
)
echo %GREEN%✅ Notification MCP deployed successfully%NC%
echo.

REM ========================================
REM Phase 4: Deploy Orchestration Layer
REM ========================================
echo %BLUE%🎭 Phase 4: Deploying Orchestration Layer%NC%
echo ----------------------------------------

echo %BLUE%📤 Deploying Agent Broker MCP Server...%NC%
call "%SCRIPT_DIR%\deploy-single-mcp.bat" agent-broker-mcp %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Agent Broker MCP deployment failed%NC%
    goto :rollback
)
echo %GREEN%✅ Agent Broker MCP deployed successfully%NC%
echo.

REM ========================================
REM Phase 5: Configure Flex Gateway
REM ========================================
echo %BLUE%🌐 Phase 5: Configuring Flex Gateway%NC%
echo ----------------------------------------

echo %BLUE%⚙️  Deploying Flex Gateway configuration...%NC%
call "%SCRIPT_DIR%\deploy-gateway.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Flex Gateway configuration failed%NC%
    goto :rollback
)
echo %GREEN%✅ Flex Gateway configured successfully%NC%
echo.

REM ========================================
REM Phase 6: Post-deployment Verification
REM ========================================
echo %BLUE%🔍 Phase 6: Post-deployment Verification%NC%
echo ----------------------------------------

echo %BLUE%🏥 Performing health checks on all services...%NC%
call "%SCRIPT_DIR%\health-check-all.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Health checks failed%NC%
    goto :rollback
)
echo %GREEN%✅ All services are healthy%NC%

echo %BLUE%🧪 Running integration tests...%NC%
call "%SCRIPT_DIR%\run-integration-tests.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Integration tests failed%NC%
    goto :rollback
)
echo %GREEN%✅ Integration tests passed%NC%

echo %BLUE%🕸️  Validating agent network configuration...%NC%
call "%SCRIPT_DIR%\validate-agent-network.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Agent network validation failed%NC%
    goto :rollback
)
echo %GREEN%✅ Agent network validated successfully%NC%
echo.

REM ========================================
REM Deployment Success
REM ========================================
echo %GREEN%🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!%NC%
echo %GREEN%========================================%NC%
echo %GREEN%✅ ALL SERVICES DEPLOYED AND VALIDATED%NC%
echo %GREEN%Environment: %ENVIRONMENT%%NC%
echo %GREEN%Completion Time: %DATE% %TIME%%NC%
echo.
echo %BLUE%📊 DEPLOYED SERVICES:%NC%
echo %GREEN%1. Employee Onboarding MCP Server - ✅ RUNNING%NC%
echo %GREEN%2. Asset Allocation MCP Server - ✅ RUNNING%NC%
echo %GREEN%3. Notification MCP Server - ✅ RUNNING%NC%
echo %GREEN%4. Agent Broker MCP Server - ✅ RUNNING%NC%
echo %GREEN%5. Flex Gateway Configuration - ✅ ACTIVE%NC%
echo.
echo %BLUE%🌐 ACCESS POINTS:%NC%
echo %BLUE%Agent Fabric Gateway: https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com%NC%
echo %BLUE%Agent Broker: https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/broker%NC%
echo %BLUE%Employee Management: https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/employee%NC%
echo %BLUE%Asset Allocation: https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/assets%NC%
echo %BLUE%Notifications: https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/notifications%NC%
echo.
echo %BLUE%📚 NEXT STEPS:%NC%
echo %BLUE%1. Test the complete employee onboarding workflow%NC%
echo %BLUE%2. Monitor service health and performance%NC%
echo %BLUE%3. Review deployment logs for optimization opportunities%NC%
echo %BLUE%4. Set up automated monitoring and alerting%NC%
echo.
echo %GREEN%🚀 EMPLOYEE ONBOARDING AGENT FABRIC IS NOW LIVE!%NC%
goto :end

REM ========================================
REM Rollback Process
REM ========================================
:rollback
echo.
echo %RED%💥 DEPLOYMENT FAILED - INITIATING ROLLBACK%NC%
echo %RED%========================================%NC%
echo %YELLOW%🔄 Rolling back to previous stable deployment...%NC%

call "%SCRIPT_DIR%\rollback-deployment.bat" %ENVIRONMENT%
if !ERRORLEVEL! neq 0 (
    echo %RED%❌ Rollback failed - Manual intervention required%NC%
    exit /b 1
)

echo %YELLOW%✅ Rollback completed successfully%NC%
echo %YELLOW%📧 Deployment failure has been logged and notifications sent%NC%
exit /b 1

:end
echo %BLUE%Press any key to continue . . .%NC%
pause >nul
exit /b 0
