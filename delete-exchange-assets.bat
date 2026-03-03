@echo off
echo ================================
echo Delete Conflicting Exchange Assets
echo ================================
echo.

:: Set current directory
cd /d "%~dp0"

echo [INFO] This script will help you delete conflicting Exchange assets
echo [INFO] Organization ID: 47562e5d-bf49-440a-a0f5-a9cea0a89aa9
echo.

:: Check if we're in the right directory
if not exist "employee-onboarding-agent-fabric" (
    echo ERROR: Cannot find employee-onboarding-agent-fabric directory
    echo Please run this script from the correct directory
    pause
    exit /b 1
)

:: Check if settings file exists
if exist "employee-onboarding-agent-fabric\settings.xml" (
    echo [INFO] Using settings file: employee-onboarding-agent-fabric\settings.xml
    set SETTINGS_FLAG=-s "employee-onboarding-agent-fabric\settings.xml"
) else if exist "%USERPROFILE%\.m2\settings.xml" (
    echo [INFO] Using default Maven settings file
    set SETTINGS_FLAG=
) else (
    echo [WARNING] No Maven settings file found
    set SETTINGS_FLAG=
)
echo.

echo ================================
echo Asset 1: assets-allocation-mcp-server v2.0.1
echo ================================
echo [INFO] Attempting to delete assets-allocation-mcp-server version 2.0.1...
echo.

:: Use Exchange Mule Maven Plugin to delete asset
cd employee-onboarding-agent-fabric\mcp-servers\assets-allocation-mcp-server

echo [INFO] Current directory: %CD%
echo [INFO] Executing Exchange delete command...

:: Method 1: Using Exchange Maven Plugin with delete goal (if available)
echo [INFO] Trying Maven Exchange Plugin delete...
mvn org.mule.tools.maven:exchange-mule-maven-plugin:0.0.23:delete ^
    -DgroupId=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -DassetId=assets-allocation-mcp-server ^
    -Dversion=2.0.1 ^
    -DdeleteType=soft-delete ^
    %SETTINGS_FLAG%

if errorlevel 1 (
    echo [WARNING] Maven delete failed, trying alternative method...
    echo.
    
    :: Method 2: Use curl to delete via Exchange API
    echo [INFO] Alternative: Using curl to delete via Exchange API...
    echo [INFO] You need to get your authentication token first
    echo.
    echo curl -X DELETE "https://anypoint.mulesoft.com/exchange/api/v2/organizations/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/assets/assets-allocation-mcp-server/2.0.1" ^
         -H "Authorization: Bearer YOUR_TOKEN_HERE"
    echo.
    
    :: Method 3: Manual Exchange Portal deletion
    echo [INFO] Manual option: Delete via Exchange Portal
    echo [INFO] Go to: https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/assets-allocation-mcp-server/
    echo [INFO] Find version 2.0.1 and delete it manually
    echo.
)

cd ..\..\..

echo ================================
echo Asset 2: employee-onboarding-agent-broker
echo ================================
echo [INFO] Attempting to delete employee-onboarding-agent-broker...
echo.

cd employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-agent-broker

echo [INFO] Current directory: %CD%
echo [INFO] Executing Exchange delete command...

:: Method 1: Using Exchange Maven Plugin with delete goal
echo [INFO] Trying Maven Exchange Plugin delete...
mvn org.mule.tools.maven:exchange-mule-maven-plugin:0.0.23:delete ^
    -DgroupId=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -DassetId=employee-onboarding-agent-broker ^
    -DdeleteType=soft-delete ^
    %SETTINGS_FLAG%

if errorlevel 1 (
    echo [WARNING] Maven delete failed, trying alternative method...
    echo.
    
    :: Method 2: Use curl to delete via Exchange API  
    echo [INFO] Alternative: Using curl to delete via Exchange API...
    echo [INFO] You need to get your authentication token first
    echo.
    echo curl -X DELETE "https://anypoint.mulesoft.com/exchange/api/v2/organizations/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/assets/employee-onboarding-agent-broker" ^
         -H "Authorization: Bearer YOUR_TOKEN_HERE"
    echo.
    
    :: Method 3: Manual Exchange Portal deletion
    echo [INFO] Manual option: Delete via Exchange Portal
    echo [INFO] Go to: https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/employee-onboarding-agent-broker/
    echo [INFO] Delete the asset manually
    echo.
)

cd ..\..\..

echo ================================
echo Summary and Next Steps
echo ================================
echo.

echo [INFO] After deleting the assets, you can republish them:
echo.
echo 1. For assets-allocation-mcp-server (now version 2.0.2):
echo    cd employee-onboarding-agent-fabric\mcp-servers\assets-allocation-mcp-server
echo    mvn clean deploy %SETTINGS_FLAG%
echo.
echo 2. For employee-onboarding-agent-broker:
echo    cd employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-agent-broker  
echo    mvn clean deploy %SETTINGS_FLAG%
echo.

echo ================================
echo Manual Deletion URLs (if automated deletion fails):
echo ================================
echo.
echo Assets Allocation Server:
echo https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/assets-allocation-mcp-server/
echo.
echo Agent Broker:
echo https://anypoint.mulesoft.com/exchange/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/employee-onboarding-agent-broker/
echo.

echo [INFO] Script completed. Check above for any errors.
pause
