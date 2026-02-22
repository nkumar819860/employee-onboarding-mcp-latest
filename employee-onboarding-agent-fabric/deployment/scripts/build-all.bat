@echo off
REM ========================================
REM Build All MCP Servers Script
REM Builds all MCP server applications in parallel
REM ========================================

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set FABRIC_ROOT=%SCRIPT_DIR%\..\..\
set MCP_SERVERS_DIR=%FABRIC_ROOT%\mcp-servers

REM Colors for output
set GREEN=[92m
set RED=[91m
set YELLOW=[93m
set BLUE=[94m
set NC=[0m

echo %BLUE%🔨 Building All MCP Server Applications%NC%
echo %BLUE%=======================================%NC%
echo.

REM List of MCP servers to build
set MCP_SERVERS=employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp

REM Initialize result tracking
set BUILD_SUCCESS=0
set BUILD_FAILED=0

echo %BLUE%📦 Starting parallel build process...%NC%
echo.

REM Build each MCP server
for %%s in (%MCP_SERVERS%) do (
    echo %BLUE%🔨 Building %%s...%NC%
    
    pushd "%MCP_SERVERS_DIR%\%%s"
    
    REM Check if pom.xml exists
    if not exist "pom.xml" (
        echo %RED%❌ pom.xml not found in %%s directory%NC%
        set /a BUILD_FAILED+=1
        popd
        continue
    )
    
    REM Clean and build the project
    echo %YELLOW%   Running: mvn clean package -DskipTests%NC%
    mvn clean package -DskipTests -q
    
    if !ERRORLEVEL! equ 0 (
        echo %GREEN%✅ %%s built successfully%NC%
        set /a BUILD_SUCCESS+=1
    ) else (
        echo %RED%❌ %%s build failed%NC%
        set /a BUILD_FAILED+=1
    )
    
    popd
    echo.
)

echo %BLUE%📊 Build Summary%NC%
echo %BLUE%===============%NC%
echo %GREEN%✅ Successful builds: %BUILD_SUCCESS%%NC%
echo %RED%❌ Failed builds: %BUILD_FAILED%%NC%
echo.

if %BUILD_FAILED% gtr 0 (
    echo %RED%💥 Some builds failed. Please check the output above for details.%NC%
    exit /b 1
) else (
    echo %GREEN%🎉 All MCP servers built successfully!%NC%
    exit /b 0
)
