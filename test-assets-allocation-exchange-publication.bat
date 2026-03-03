@echo off
echo ================================
echo Testing Assets Allocation MCP Server Exchange Publication Fix
echo ================================
echo.

:: Set current directory
cd /d "%~dp0"

:: Check if we're in the right directory
if not exist "employee-onboarding-agent-fabric\mcp-servers\assets-allocation-mcp-server\pom.xml" (
    echo ERROR: Cannot find assets-allocation-mcp-server pom.xml
    echo Please run this script from the correct directory
    pause
    exit /b 1
)

echo [INFO] Current directory: %CD%
echo [INFO] Testing Exchange publication for assets-allocation-mcp-server version 2.0.2
echo.

:: Navigate to the assets allocation server directory
cd employee-onboarding-agent-fabric\mcp-servers\assets-allocation-mcp-server

echo [INFO] Changed to: %CD%
echo.

:: Show current version in pom.xml
echo [INFO] Verifying version in pom.xml:
findstr "<version>2.0.2</version>" pom.xml
if errorlevel 1 (
    echo [WARNING] Version 2.0.2 not found in pom.xml - checking actual content:
    findstr "<version>" pom.xml
)
echo.

:: Check if settings file exists
if exist "..\..\settings.xml" (
    echo [INFO] Using settings file: ..\..\settings.xml
    set SETTINGS_FLAG=-s "..\..\settings.xml"
) else if exist "%USERPROFILE%\.m2\settings.xml" (
    echo [INFO] Using default Maven settings file
    set SETTINGS_FLAG=
) else (
    echo [WARNING] No Maven settings file found
    set SETTINGS_FLAG=
)
echo.

:: Clean and compile first
echo [INFO] Step 1: Clean and compile the project
mvn clean compile %SETTINGS_FLAG%
if errorlevel 1 (
    echo [ERROR] Failed to clean and compile. Aborting.
    pause
    exit /b 1
)
echo.

:: Package the application
echo [INFO] Step 2: Package the application
mvn package %SETTINGS_FLAG%
if errorlevel 1 (
    echo [ERROR] Failed to package. Aborting.
    pause
    exit /b 1
)
echo.

:: Test Exchange deployment
echo [INFO] Step 3: Deploy to Exchange (version 2.0.2)
echo [INFO] This should resolve the previous version conflict...
mvn deploy %SETTINGS_FLAG%

if errorlevel 1 (
    echo.
    echo [ERROR] Exchange publication failed!
    echo.
    echo Possible solutions:
    echo 1. Check if version 2.0.2 already exists in Exchange
    echo 2. Verify your Maven settings and credentials
    echo 3. Check network connectivity to Exchange
    echo 4. Increment version further if needed
    echo.
) else (
    echo.
    echo [SUCCESS] Assets Allocation MCP Server v2.0.2 successfully published to Exchange!
    echo.
    echo Next steps:
    echo 1. Verify the asset appears in Anypoint Exchange
    echo 2. Check asset metadata and documentation
    echo 3. Test asset consumption from other projects
    echo.
)

echo ================================
echo Test completed at: %DATE% %TIME%
echo ================================
pause
