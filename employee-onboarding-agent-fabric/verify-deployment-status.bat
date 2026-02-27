@echo off
echo ================================
echo CHECKING CLOUDHUB DEPLOYMENT STATUS
echo ================================

echo.
echo 1. Checking if artifact was built...
cd /d "C:\Users\Pradeep\AI\employee-onboarding\employee-onboarding-agent-fabric\mcp-servers\notification-mcp"

if exist "target\notification-mcp-1.0.3-mule-application.jar" (
    echo ✅ Artifact found: target\notification-mcp-1.0.3-mule-application.jar
    for %%A in ("target\notification-mcp-1.0.3-mule-application.jar") do echo    Size: %%~zA bytes
    echo    Created: 
    for %%A in ("target\notification-mcp-1.0.3-mule-application.jar") do echo    %%~tA
) else (
    echo ❌ Artifact NOT found: target\notification-mcp-1.0.3-mule-application.jar
    echo Available files in target:
    dir target\*.jar 2>nul
    if %ERRORLEVEL% neq 0 echo No JAR files found in target directory
)

echo.
echo 2. Testing CloudHub deployment command manually...
echo.
echo Running deployment with verbose output:
echo.

mvn mule:deploy ^
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
    -Danypoint.environment=Sandbox ^
    -DmuleDeploy ^
    -DskipTests ^
    -Dcloudhub.application.name=notification-mcp-server ^
    -Dcloudhub.runtime=4.5.0 ^
    -Dcloudhub.java.version=17 ^
    -Dcloudhub.region=us-east-1 ^
    -Dcloudhub.workers=1 ^
    -Dcloudhub.workerType=MICRO ^
    -Dcloudhub.artifact=target\notification-mcp-1.0.3-mule-application.jar ^
    -X

echo.
echo ================================
echo Deployment command completed with exit code: %ERRORLEVEL%
echo ================================

if %ERRORLEVEL% equ 0 (
    echo ✅ DEPLOYMENT SUCCESSFUL!
    echo.
    echo Your application should now be available at:
    echo http://notification-mcp-server.us-e1.cloudhub.io/health
    echo.
    echo To test the MCP server info:
    echo http://notification-mcp-server.us-e1.cloudhub.io/mcp/info
) else (
    echo ❌ DEPLOYMENT FAILED with error code: %ERRORLEVEL%
    echo Check the Maven output above for error details.
    echo.
    echo Common issues:
    echo - Connected app permissions
    echo - Network connectivity
    echo - Application name already exists
    echo - Invalid runtime version
)

echo.
pause
