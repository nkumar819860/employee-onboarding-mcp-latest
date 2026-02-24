@echo off
echo ========================================
echo 🎯 EMPLOYEE ONBOARDING MCP DEPLOYMENT HELPER
echo ========================================
echo.
echo This script will help you deploy the Employee Onboarding MCP System
echo to CloudHub manually, bypassing Connected App authentication issues.
echo.
echo 📋 CURRENT STATUS:
echo ✅ All JAR files are built and ready
echo ❌ Connected App authentication failing
echo ⭐ SOLUTION: Manual CloudHub deployment
echo.

:menu
echo ========================================
echo SELECT DEPLOYMENT OPTION:
echo ========================================
echo 1. 🚀 Show JAR file locations for manual upload
echo 2. 🔧 Test Connected App authentication  
echo 3. 🔄 Try Anypoint CLI deployment
echo 4. 📖 Open deployment guide
echo 5. ❌ Exit
echo.
set /p choice=Enter your choice (1-5): 

if "%choice%"=="1" goto show_jars
if "%choice%"=="2" goto test_auth
if "%choice%"=="3" goto cli_deploy
if "%choice%"=="4" goto open_guide
if "%choice%"=="5" goto exit
goto menu

:show_jars
echo.
echo ========================================
echo 📁 JAR FILES FOR MANUAL UPLOAD:
echo ========================================
echo.
echo 1. Employee Onboarding MCP Server:
echo    📄 %cd%\employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp\target\employee-onboarding-mcp-1.0.3-mule-application.jar
echo    🌐 App Name: employee-onboarding-mcp-server
echo.
echo 2. Asset Allocation MCP Server:
echo    📄 %cd%\employee-onboarding-agent-fabric\mcp-servers\asset-allocation-mcp\target\asset-allocation-mcp-1.0.2-mule-application.jar
echo    🌐 App Name: asset-allocation-mcp-server
echo.
echo 3. Notification MCP Server:
echo    📄 %cd%\employee-onboarding-agent-fabric\mcp-servers\notification-mcp\target\notification-mcp-1.0.2-mule-application.jar
echo    🌐 App Name: notification-mcp-server
echo.
echo 4. Agent Broker MCP Server:
echo    📄 %cd%\employee-onboarding-agent-fabric\mcp-servers\agent-broker-mcp\target\agent-broker-mcp-1.0.2-mule-application.jar
echo    🌐 App Name: employee-onboarding-agent-broker
echo.
echo ========================================
echo 🚀 DEPLOYMENT SETTINGS FOR ALL APPS:
echo ========================================
echo Runtime Version: 4.9.4
echo Environment: Sandbox
echo Worker Size: 0.1 vCores (MICRO)
echo Workers: 1
echo Region: US East (N. Virginia)
echo.
echo 🌐 Go to: https://anypoint.mulesoft.com/cloudhub
echo    1. Click "Deploy Application"
echo    2. Upload each JAR file above
echo    3. Use the app names and settings shown
echo    4. Deploy each application
echo.
pause
goto menu

:test_auth
echo.
echo ========================================
echo 🔧 TESTING CONNECTED APP AUTHENTICATION
echo ========================================
echo.
echo Testing authentication with HR-MCP-Deployment Connected App...
curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "client_id=25bb2da884004ff6af264101e535c5f9&client_secret=758185C9B0964D2b961f066F582379a2&grant_type=client_credentials"
echo.
echo.
echo If you see an access_token above, the Connected App is working!
echo If you see an error, use manual deployment instead.
echo.
pause
goto menu

:cli_deploy
echo.
echo ========================================
echo 🔄 ANYPOINT CLI DEPLOYMENT
echo ========================================
echo.
echo Installing Anypoint CLI (if not already installed)...
npm install -g anypoint-cli
echo.
echo Please login with your Anypoint Platform credentials:
anypoint-cli-v4 account login
echo.
echo Deploying Employee Onboarding MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  --applicationName employee-onboarding-mcp-server ^
  --environment Sandbox ^
  --runtime 4.9.4 ^
  --workers 1 ^
  --workerType MICRO ^
  --region us-east-1 ^
  employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp\target\employee-onboarding-mcp-1.0.3-mule-application.jar

echo.
echo Deploying Asset Allocation MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  --applicationName asset-allocation-mcp-server ^
  --environment Sandbox ^
  --runtime 4.9.4 ^
  --workers 1 ^
  --workerType MICRO ^
  --region us-east-1 ^
  employee-onboarding-agent-fabric\mcp-servers\asset-allocation-mcp\target\asset-allocation-mcp-1.0.2-mule-application.jar

echo.
echo Deploying Notification MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  --applicationName notification-mcp-server ^
  --environment Sandbox ^
  --runtime 4.9.4 ^
  --workers 1 ^
  --workerType MICRO ^
  --region us-east-1 ^
  employee-onboarding-agent-fabric\mcp-servers\notification-mcp\target\notification-mcp-1.0.2-mule-application.jar

echo.
echo Deploying Agent Broker MCP Server...
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  --applicationName employee-onboarding-agent-broker ^
  --environment Sandbox ^
  --runtime 4.9.4 ^
  --workers 1 ^
  --workerType MICRO ^
  --region us-east-1 ^
  employee-onboarding-agent-fabric\mcp-servers\agent-broker-mcp\target\agent-broker-mcp-1.0.2-mule-application.jar

echo.
echo ========================================
echo 🎉 DEPLOYMENT COMPLETE!
echo ========================================
echo.
echo Verify these health endpoints:
echo ✅ https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
echo ✅ https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
echo ✅ https://notification-mcp-server.us-e1.cloudhub.io/health
echo ✅ https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health
echo.
pause
goto menu

:open_guide
echo.
echo ========================================
echo 📖 OPENING DEPLOYMENT GUIDE
echo ========================================
echo.
start FINAL_COMPREHENSIVE_DEPLOYMENT_SOLUTION.md
echo Deployment guide opened in your default application.
echo.
pause
goto menu

:exit
echo.
echo ========================================
echo 🎉 DEPLOYMENT HELPER - GOODBYE!
echo ========================================
echo.
echo Remember: Manual CloudHub deployment is the fastest path to success!
echo 🚀 Go to: https://anypoint.mulesoft.com/cloudhub
echo.
echo Good luck with your deployment! 🚀
echo.
pause
exit

:error
echo.
echo ❌ An error occurred. Please check the logs and try again.
echo.
pause
goto menu
