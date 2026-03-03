@echo off
echo ====================================
echo Employee Onboarding Agent Fabric
echo Parent POM Deployment Script
echo ====================================

REM Set environment variables if not already set
if not defined ANYPOINT_USERNAME (
    echo WARNING: ANYPOINT_USERNAME not set
    set /p ANYPOINT_USERNAME="Enter Anypoint Username: "
)

if not defined ANYPOINT_PASSWORD (
    echo WARNING: ANYPOINT_PASSWORD not set
    set /p ANYPOINT_PASSWORD="Enter Anypoint Password: "
)

if not defined ANYPOINT_ORG_ID (
    echo WARNING: ANYPOINT_ORG_ID not set
    set /p ANYPOINT_ORG_ID="Enter Organization ID: "
)

echo.
echo Deploying Parent POM to Exchange...
echo Organization ID: %ANYPOINT_ORG_ID%
echo.

cd parent-pom

echo Running Maven deploy for parent POM...
mvn clean deploy ^
    -Danypoint.username=%ANYPOINT_USERNAME% ^
    -Danypoint.password=%ANYPOINT_PASSWORD% ^
    -Danypoint.organization.id=%ANYPOINT_ORG_ID%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ====================================
    echo Parent POM deployed successfully!
    echo ====================================
) else (
    echo.
    echo ====================================
    echo Parent POM deployment failed!
    echo Error Level: %ERRORLEVEL%
    echo ====================================
)

cd ..

echo.
echo Would you like to deploy the agent fabric MCP servers? (y/n)
set /p DEPLOY_MCP="Enter choice: "

if /i "%DEPLOY_MCP%"=="y" (
    echo.
    echo Deploying MCP servers...
    cd employee-onboarding-agent-fabric
    call deploy.bat
    cd ..
)

pause
