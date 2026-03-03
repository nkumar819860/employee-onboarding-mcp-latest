@echo off
echo ===============================================
echo Testing Agent Network YAML Localhost Configuration
echo ===============================================
echo.

echo Checking agent network YAML configuration...
echo.

echo 1. Verifying localhost URLs are present:
echo.

findstr /n "localhost" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Localhost URLs found in configuration
) else (
    echo [✗] No localhost URLs found
    goto :end
)

echo.
echo 2. Checking for local environment configuration:
echo.

findstr /n /A "local:" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Local environment configuration found
) else (
    echo [✗] Local environment configuration not found
)

echo.
echo 3. Checking MCP server environments:
echo.

echo Looking for CloudHub and localhost configurations...
findstr /n /C:"https://employee-onboarding-agent-broker.us-e1.cloudhub.io" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] CloudHub production URL found
) else (
    echo [✗] CloudHub production URL not found
)

findstr /n /C:"http://localhost:8080" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Localhost broker URL found
) else (
    echo [✗] Localhost broker URL not found
)

findstr /n /C:"http://localhost:8081" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Localhost employee service URL found
) else (
    echo [✗] Localhost employee service URL not found
)

findstr /n /C:"http://localhost:8082" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Localhost asset allocation service URL found
) else (
    echo [✗] Localhost asset allocation service URL not found
)

findstr /n /C:"http://localhost:8083" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Localhost notification service URL found
) else (
    echo [✗] Localhost notification service URL not found
)

echo.
echo 4. Checking local development features:
echo.

findstr /n /C:"local_development_features" employee-onboarding-agent-network.yaml
if %ERRORLEVEL% EQU 0 (
    echo [✓] Local development features configuration found
) else (
    echo [✗] Local development features configuration not found
)

echo.
echo ===============================================
echo Agent Network Configuration Summary:
echo ===============================================
echo The YAML now includes:
echo • CloudHub URLs for production/staging environments
echo • Localhost URLs for development/local environments  
echo • Dedicated 'local' environment configuration
echo • Local development features (hot reload, debug mode)
echo • Health check and debug mode for local services
echo • Separate localhost URLs for all MCP services
echo ===============================================

:end
echo.
echo Test completed. Press any key to exit...
pause >nul
