@echo off
REM ========================================
REM Deploy Single MCP Server Script
REM ========================================

set MCP_NAME=%1
set ENVIRONMENT=%2
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

set SCRIPT_DIR=%~dp0
set FABRIC_ROOT=%SCRIPT_DIR%\..\..\
set MCP_SERVERS_DIR=%FABRIC_ROOT%\mcp-servers

echo 📤 Deploying %MCP_NAME% to %ENVIRONMENT%

if not exist "%MCP_SERVERS_DIR%\%MCP_NAME%" (
    echo ❌ MCP server directory not found: %MCP_NAME%
    exit /b 1
)

pushd "%MCP_SERVERS_DIR%\%MCP_NAME%"

REM Check if JAR file exists
if not exist "target\*.jar" (
    echo ❌ JAR file not found. Please build first.
    popd
    exit /b 1
)

echo ✅ %MCP_NAME% deployment simulated (CloudHub deployment would happen here)
popd
exit /b 0
