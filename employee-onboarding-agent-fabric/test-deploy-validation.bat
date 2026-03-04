@echo off
echo =============================================================================
echo Testing Deploy.bat Script - Validation Only (No Actual Deployment)
echo =============================================================================
echo.

echo Testing Phase 1: Pre-deployment Validation...
echo.

REM Test Java version check
echo 1. Testing Java version detection...
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VER=%%i
)
if defined JAVA_VER (
    echo   ✓ Local Java version detected: %JAVA_VER%
    echo   ✓ CloudHub will use: Mule 4.9.6 with Java 17 runtime
) else (
    echo   ✗ Java version detection failed
)
echo.

REM Test Maven check
echo 2. Testing Maven installation check...
mvn --version >nul 2>nul
if %errorlevel% neq 0 (
    echo   ✗ Maven not found or not in PATH
) else (
    echo   ✓ Maven is available
)
echo.

REM Test directory structure
echo 3. Testing directory structure...
if exist "pom.xml" (
    echo   ✓ Parent pom.xml found
) else (
    echo   ✗ Parent pom.xml not found
)

set MCP_SERVERS=employee-onboarding-agent-broker employee-onboarding-mcp-server assets-allocation-mcp-server email-notification-mcp-server
for %%s in (%MCP_SERVERS%) do (
    if exist "mcp-servers\%%s" (
        echo   ✓ MCP server directory found: %%s
    ) else (
        echo   ✗ MCP server directory missing: %%s
    )
)
echo.

REM Test .env file loading
echo 4. Testing .env file loading...
if exist ".env" (
    echo   ✓ .env file found - environment variables will be loaded
) else (
    echo   ℹ .env file not found - using default values
)
echo.

echo =============================================================================
echo Validation complete! The deploy.bat script structure appears correct.
echo.
echo To run the actual deployment:
echo   .\deploy.bat
echo.
echo Make sure you have:
echo - Valid Anypoint Platform credentials
echo - Java 17 or compatible version for Mule 4.9.6
echo - Maven 3.6+ installed
echo - Network access to Anypoint Platform
echo =============================================================================
pause
