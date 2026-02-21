@echo off
REM Employee Onboarding System - Deployment Validation Script
REM This script validates the deployment configuration and prerequisites

setlocal enabledelayedexpansion

echo.
echo ========================================
echo 🔍 Deployment Validation Script
echo ========================================
echo.

set VALIDATION_PASSED=true

REM Check if .env file exists
echo 📝 Checking .env file...
if not exist ".env" (
    echo ❌ .env file not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ .env file found
)

REM Check if Maven is installed
echo 🔨 Checking Maven installation...
mvn --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Maven not found or not in PATH
    set VALIDATION_PASSED=false
) else (
    echo ✅ Maven is installed
)

REM Check if Anypoint CLI v4 is installed
echo 🔧 Checking Anypoint CLI v4 installation...
anypoint-cli-v4 --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Anypoint CLI v4 not found or not in PATH
    set VALIDATION_PASSED=false
) else (
    echo ✅ Anypoint CLI v4 is installed
)

REM Check if curl is available
echo 🌐 Checking curl installation...
curl --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ curl not found or not in PATH
    set VALIDATION_PASSED=false
) else (
    echo ✅ curl is available
)

REM Check if all application directories exist
echo 📁 Checking application directories...

if not exist "src" (
    echo ❌ Main application source directory not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Main application source directory found
)

if not exist "asset-allocation-mcp" (
    echo ❌ Asset Allocation MCP directory not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Asset Allocation MCP directory found
)

if not exist "notification-mcp" (
    echo ❌ Notification MCP directory not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Notification MCP directory found
)

if not exist "employee-onboarding-agent-broker" (
    echo ❌ Agent Broker directory not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Agent Broker directory found
)

REM Check if pom.xml files exist
echo 📄 Checking Maven configuration files...

if not exist "pom.xml" (
    echo ❌ Main pom.xml not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Main pom.xml found
)

if not exist "asset-allocation-mcp\pom.xml" (
    echo ❌ Asset Allocation pom.xml not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Asset Allocation pom.xml found
)

if not exist "notification-mcp\pom.xml" (
    echo ❌ Notification pom.xml not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Notification pom.xml found
)

if not exist "employee-onboarding-agent-broker\pom.xml" (
    echo ❌ Agent Broker pom.xml not found
    set VALIDATION_PASSED=false
) else (
    echo ✅ Agent Broker pom.xml found
)

echo.
echo ========================================
if "%VALIDATION_PASSED%"=="true" (
    echo ✅ All validation checks passed!
    echo 🚀 Ready for deployment
    echo.
    echo To deploy, run: deploy-to-cloudhub.bat
) else (
    echo ❌ Validation failed!
    echo Please fix the issues above before deploying
)
echo ========================================

pause
exit /b 0
