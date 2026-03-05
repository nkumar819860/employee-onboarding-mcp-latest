@echo off
setlocal enabledelayedexpansion

echo ======================================================================
echo   Discovering CloudHub URLs and Updating Configuration
echo ======================================================================
echo.

REM Set default CloudHub region if not specified
if not defined CLOUDHUB_REGION set CLOUDHUB_REGION=us-e1

REM Try to discover deployed applications
echo [INFO] Discovering CloudHub application URLs...
echo.

REM Common CloudHub URL patterns - these are the typical patterns MuleSoft uses
echo [INFO] Checking common CloudHub URL patterns...

REM Pattern 1: Based on artifact IDs from pom.xml files
set AGENT_BROKER_URL=https://onboardingbroker.!CLOUDHUB_REGION!.cloudhub.io
set EMPLOYEE_ONBOARDING_URL=https://employeeonboardingmcp.!CLOUDHUB_REGION!.cloudhub.io
set ASSET_ALLOCATION_URL=https://assetallocationserver.!CLOUDHUB_REGION!.cloudhub.io
set NOTIFICATION_URL=https://emailnotificationmcp.!CLOUDHUB_REGION!.cloudhub.io

echo Testing discovered URLs:
echo - Agent Broker: !AGENT_BROKER_URL!
echo - Employee Onboarding: !EMPLOYEE_ONBOARDING_URL! 
echo - Asset Allocation: !ASSET_ALLOCATION_URL!
echo - Email Notification: !NOTIFICATION_URL!
echo.

REM Test each URL to see if it's accessible
echo [INFO] Testing CloudHub URL accessibility...

curl -s -o NUL -w "Agent Broker (%%{http_code}): !AGENT_BROKER_URL!/health" !AGENT_BROKER_URL!/health
echo.
curl -s -o NUL -w "Employee Onboarding (%%{http_code}): !EMPLOYEE_ONBOARDING_URL!/health" !EMPLOYEE_ONBOARDING_URL!/health
echo.
curl -s -o NUL -w "Asset Allocation (%%{http_code}): !ASSET_ALLOCATION_URL!/health" !ASSET_ALLOCATION_URL!/health
echo.
curl -s -o NUL -w "Email Notification (%%{http_code}): !NOTIFICATION_URL!/health" !NOTIFICATION_URL!/health
echo.

REM Alternative patterns to try
echo [INFO] Trying alternative URL patterns...

REM Pattern 2: Hyphenated versions
set AGENT_BROKER_URL_ALT=https://employee-onboarding-agent-broker.!CLOUDHUB_REGION!.cloudhub.io
set EMPLOYEE_ONBOARDING_URL_ALT=https://employee-onboarding-mcp-server.!CLOUDHUB_REGION!.cloudhub.io
set ASSET_ALLOCATION_URL_ALT=https://asset-allocation-mcp-server.!CLOUDHUB_REGION!.cloudhub.io
set NOTIFICATION_URL_ALT=https://notification-mcp-server.!CLOUDHUB_REGION!.cloudhub.io

echo Testing alternative URLs:
curl -s -o NUL -w "Agent Broker Alt (%%{http_code}): !AGENT_BROKER_URL_ALT!" !AGENT_BROKER_URL_ALT!
echo.
curl -s -o NUL -w "Employee Onboarding Alt (%%{http_code}): !EMPLOYEE_ONBOARDING_URL_ALT!" !EMPLOYEE_ONBOARDING_URL_ALT!
echo.
curl -s -o NUL -w "Asset Allocation Alt (%%{http_code}): !ASSET_ALLOCATION_URL_ALT!" !ASSET_ALLOCATION_URL_ALT!
echo.
curl -s -o NUL -w "Notification Alt (%%{http_code}): !NOTIFICATION_URL_ALT!" !NOTIFICATION_URL_ALT!
echo.

REM Pattern 3: Based on directory names
set AGENT_BROKER_URL_DIR=https://agent-broker-mcp.!CLOUDHUB_REGION!.cloudhub.io
set EMPLOYEE_ONBOARDING_URL_DIR=https://employee-onboarding-mcp.!CLOUDHUB_REGION!.cloudhub.io
set ASSET_ALLOCATION_URL_DIR=https://asset-allocation-mcp.!CLOUDHUB_REGION!.cloudhub.io
set NOTIFICATION_URL_DIR=https://notification-mcp.!CLOUDHUB_REGION!.cloudhub.io

echo Testing directory-based URLs:
curl -s -o NUL -w "Agent Broker Dir (%%{http_code}): !AGENT_BROKER_URL_DIR!" !AGENT_BROKER_URL_DIR!
echo.
curl -s -o NUL -w "Employee Onboarding Dir (%%{http_code}): !EMPLOYEE_ONBOARDING_URL_DIR!" !EMPLOYEE_ONBOARDING_URL_DIR!
echo.
curl -s -o NUL -w "Asset Allocation Dir (%%{http_code}): !ASSET_ALLOCATION_URL_DIR!" !ASSET_ALLOCATION_URL_DIR!
echo.
curl -s -o NUL -w "Notification Dir (%%{http_code}): !NOTIFICATION_URL_DIR!" !NOTIFICATION_URL_DIR!
echo.

echo ======================================================================
echo Please check the HTTP status codes above and identify the working URLs
echo Then run: update-react-client-urls.bat with the correct URLs
echo ======================================================================

pause
</content>
</run_script>
</content>

Now let me create a script to update the React client configuration with the correct CloudHub URLs:

<write_to_file>
<path>update-react-client-urls.bat</path>
<content>
@echo off
setlocal enabledelayedexpansion

echo ======================================================================
echo   Updating React Client URLs for CloudHub Deployment
echo ======================================================================
echo.

REM You need to update these URLs based on your actual CloudHub deployments
REM Check Anypoint Platform Runtime Manager for the exact URLs

REM Set your actual CloudHub URLs here (update these with your real URLs)
set AGENT_BROKER_URL=https://onboardingbroker.us-e1.cloudhub.io
set EMPLOYEE_ONBOARDING_URL=https://employeeonboardingmcp.us-e1.cloudhub.io
set ASSET_ALLOCATION_URL=https://assetallocationserver.us-e1.cloudhub.io
set EMAIL_NOTIFICATION_URL=https://emailnotificationmcp.us-e1.cloudhub.io

echo [INFO] Updating React Client Environment Files...
echo.

REM Update .env.production
echo Creating updated .env.production...
(
echo # Production Environment - CloudHub Deployment
echo REACT_APP_AGENT_BROKER_URL=%AGENT_BROKER_URL%
echo REACT_APP_EMPLOYEE_ONBOARDING_URL=%EMPLOYEE_ONBOARDING_URL%
echo REACT_APP_ASSET_ALLOCATION_URL=%ASSET_ALLOCATION_URL%
echo REACT_APP_EMAIL_NOTIFICATION_URL=%EMAIL_NOTIFICATION_URL%
echo REACT_APP_API_TIMEOUT=30000
echo REACT_APP_MAX_RETRIES=3
echo REACT_APP_ENVIRONMENT=production
echo REACT_APP_USE_CLOUDHUB=true
) > employee-onboarding-agent-fabric\react-client\.env.production

REM Update .env.staging
echo Creating updated .env.staging...
(
echo # Staging Environment - CloudHub Deployment
echo REACT_APP_AGENT_BROKER_URL=%AGENT_BROKER_URL%
echo REACT_APP_EMPLOYEE_ONBOARDING_URL=%EMPLOYEE_ONBOARDING_URL%
echo REACT_APP_ASSET_ALLOCATION_URL=%ASSET_ALLOCATION_URL%
echo REACT_APP_EMAIL_NOTIFICATION_URL=%EMAIL_NOTIFICATION_URL%
echo REACT_APP_API_TIMEOUT=30000
echo REACT_APP_MAX_RETRIES=3
echo REACT_APP_ENVIRONMENT=staging
echo REACT_APP_USE_CLOUDHUB=true
) > employee-onboarding-agent-fabric\react-client\.env.staging

echo [INFO] Updating API Service Configuration...
echo.

REM Update apiService.js with CloudHub URLs
(
echo // API Service Configuration - Updated for CloudHub
echo const CONFIG = {
echo   AGENT_BROKER_URL: process.env.REACT_APP_AGENT_BROKER_URL ^|^| '%AGENT_BROKER_URL%',
echo   EMPLOYEE_ONBOARDING_URL: process.env.REACT_APP_EMPLOYEE_ONBOARDING_URL ^|^| '%EMPLOYEE_ONBOARDING_URL%',
echo   ASSET_ALLOCATION_URL: process.env.REACT_APP_ASSET_ALLOCATION_URL ^|^| '%ASSET_ALLOCATION_URL%',
echo   EMAIL_NOTIFICATION_URL: process.env.REACT_APP_EMAIL_NOTIFICATION_URL ^|^| '%EMAIL_NOTIFICATION_URL%',
echo   TIMEOUT: process.env.REACT_APP_API_TIMEOUT ^|^| 30000,
echo   MAX_RETRIES: process.env.REACT_APP_MAX_RETRIES ^|^| 3,
echo   USE_CLOUDHUB: process.env.REACT_APP_USE_CLOUDHUB === 'true'
echo };
echo.
echo const apiService = {
echo   async makeRequest(method, endpoint, data = null, service = 'AGENT_BROKER'^) {
echo     const baseUrl = CONFIG[service + '_URL'];
echo     const url = `${baseUrl}${endpoint}`;
echo.    
echo     const requestConfig = {
echo       method,
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'Accept': 'application/json'
echo       },
echo       timeout: CONFIG.TIMEOUT
echo     };
echo.
echo     if (data^) {
echo       requestConfig.body = JSON.stringify(data^);
echo     }
echo.
echo     for (let attempt = 1; attempt ^<= CONFIG.MAX_RETRIES; attempt++^) {
echo       try {
echo         const response = await fetch(url, requestConfig^);
echo         
echo         if (!response.ok^) {
echo           throw new Error(`HTTP ${response.status}: ${response.statusText}`^);
echo         }
echo         
echo         return await response.json(^);
echo       } catch (error^) {
echo         console.error(`API request failed (attempt ${attempt}^): ${error.message}`^);
echo         
echo         if (attempt === CONFIG.MAX_RETRIES^) {
echo           throw new Error(`Failed after ${CONFIG.MAX_RETRIES} attempts: ${error.message}`^);
echo         }
echo         
echo         // Wait before retry
echo         await new Promise(resolve =^> setTimeout(resolve, 1000 * attempt^)^);
echo       }
echo     }
echo   },
echo.
echo   // Employee Operations
echo   async createEmployee(employeeData^) {
echo     return this.makeRequest('POST', '/mcp/tools/create-employee', employeeData, 'EMPLOYEE_ONBOARDING'^);
echo   },
echo.
echo   async getEmployees(^) {
echo     return this.makeRequest('GET', '/mcp/tools/get-employees', null, 'EMPLOYEE_ONBOARDING'^);
echo   },
echo.
echo   async getEmployeeStatus(employeeId^) {
echo     return this.makeRequest('GET', `/mcp/tools/get-onboarding-status?employeeId=${employeeId}`, null, 'AGENT_BROKER'^);
echo   },
echo.
echo   // Asset Operations
echo   async getAvailableAssets(^) {
echo     return this.makeRequest('GET', '/mcp/tools/get-available-assets', null, 'ASSET_ALLOCATION'^);
echo   },
echo.
echo   async allocateAsset(allocationData^) {
echo     return this.makeRequest('POST', '/mcp/tools/allocate-asset', allocationData, 'ASSET_ALLOCATION'^);
echo   },
echo.
echo   // Orchestration
echo   async orchestrateOnboarding(employeeData^) {
echo     return this.makeRequest('POST', '/mcp/tools/orchestrate-employee-onboarding', employeeData, 'AGENT_BROKER'^);
echo   },
echo.
echo   // Notifications
echo   async sendNotification(notificationData^) {
echo     return this.makeRequest('POST', '/mcp/tools/send-notification', notificationData, 'EMAIL_NOTIFICATION'^);
echo   },
echo.
echo   // Health Checks
echo   async checkHealth(service = 'AGENT_BROKER'^) {
echo     return this.makeRequest('GET', '/health', null, service^);
echo   }
echo };
echo.
echo export default apiService;
) > employee-onboarding-agent-fabric\react-client\src\services\apiService.js

echo [INFO] Updating Test Script with CloudHub URLs...
echo.

REM Update the test script configuration
powershell -Command "(Get-Content 'test-agent-fabric-comprehensive-nlp-mcp.js') -replace 'https://onboardingbroker.us-e1.cloudhub.io', '%AGENT_BROKER_URL%' -replace 'https://employeeonboardingmcp.us-e1.cloudhub.io', '%EMPLOYEE_ONBOARDING_URL%' -replace 'https://assetallocationserver.us-e1.cloudhub.io', '%ASSET_ALLOCATION_URL%' -replace 'https://emailnotificationmcp.us-e1.cloudhub.io', '%EMAIL_NOTIFICATION_URL%' | Set-Content 'test-agent-fabric-comprehensive-nlp-mcp.js'"

echo [SUCCESS] Updated React Client and Test Script with CloudHub URLs:
echo   - Agent Broker: %AGENT_BROKER_URL%
echo   - Employee Onboarding: %EMPLOYEE_ONBOARDING_URL%
echo   - Asset Allocation: %ASSET_ALLOCATION_URL%
echo   - Email Notification: %EMAIL_NOTIFICATION_URL%
echo.
echo [INFO] You can now:
echo   1. Test the URLs: node test-agent-fabric-comprehensive-nlp-mcp.js --cloudhub
echo   2. Build React client: cd employee-onboarding-agent-fabric\react-client ^&^& npm run build
echo   3. Start React client: npm start
echo.

pause
