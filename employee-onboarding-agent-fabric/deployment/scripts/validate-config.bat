@echo off
REM ========================================
REM Configuration Validation Script
REM Validates all configuration files
REM ========================================

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

set SCRIPT_DIR=%~dp0
set FABRIC_ROOT=%SCRIPT_DIR%\..\..\
set CONFIG_DIR=%FABRIC_ROOT%\fabric-config

echo 🔍 Validating configuration for environment: %ENVIRONMENT%

REM Check if config files exist
if not exist "%CONFIG_DIR%\agent-network.yaml" (
    echo ❌ agent-network.yaml not found
    exit /b 1
)

if not exist "%CONFIG_DIR%\gateway-config.yaml" (
    echo ❌ gateway-config.yaml not found
    exit /b 1
)

if not exist "%CONFIG_DIR%\deployment-config.yaml" (
    echo ❌ deployment-config.yaml not found
    exit /b 1
)

echo ✅ All configuration files found
exit /b 0
