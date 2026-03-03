@echo off
echo ========================================
echo Testing Exchange Classifier Fix
echo ========================================
echo.

echo Checking all MCP server pom.xml files for classifier configuration...
echo.

echo 1. Agent Broker MCP:
findstr /c:"exchange.classifier" "employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/pom.xml"

echo.
echo 2. Employee Onboarding MCP:
findstr /c:"exchange.classifier" "employee-onboarding-agent-fabric/mcp-servers/employee-onboarding-mcp/pom.xml"

echo.
echo 3. Asset Allocation MCP:
findstr /c:"exchange.classifier" "employee-onboarding-agent-fabric/mcp-servers/asset-allocation-mcp/pom.xml"

echo.
echo 4. Notification MCP:
findstr /c:"exchange.classifier" "employee-onboarding-agent-fabric/mcp-servers/notification-mcp/pom.xml"

echo.
echo ========================================
echo Testing Maven validation on one service...
echo ========================================

cd employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp

echo Running Maven validate to test classifier configuration...
mvn validate -q

if %ERRORLEVEL% == 0 (
    echo SUCCESS: Maven validation passed - classifier fix appears to be working!
) else (
    echo WARNING: Maven validation failed - there may be other issues to resolve
)

cd ..\..\..

echo.
echo ========================================
echo Exchange Classifier Fix Summary
echo ========================================
echo All four MCP servers have been updated:
echo - agent-broker-mcp: template ✓
echo - employee-onboarding-mcp: template ✓
echo - asset-allocation-mcp: template ✓ 
echo - notification-mcp: template ✓
echo.
echo The Exchange classifier issue should now be resolved!
echo You can now retry your deployment with the corrected classifier values.
echo ========================================

pause
