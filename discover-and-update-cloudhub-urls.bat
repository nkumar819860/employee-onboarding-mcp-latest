@echo off
setlocal enabledelayedexpansion

echo ======================================================================
echo   CloudHub URL Discovery and Configuration Update Tool
echo ======================================================================
echo.

REM Set default CloudHub region if not specified
if not defined CLOUDHUB_REGION set CLOUDHUB_REGION=us-e1

echo [INFO] Step 1: Discovering actual CloudHub application URLs...
echo.

REM Use Anypoint CLI to list applications (if available)
echo [INFO] Attempting to discover URLs via Anypoint CLI...
anypoint-cli --help >nul 2>&1
if !errorlevel! equ 0 (
    echo [SUCCESS] Anypoint CLI found. Listing CloudHub applications...
    anypoint-cli runtime-mgr application list --output table
    echo.
) else (
    echo [WARNING] Anypoint CLI not found. Using manual URL discovery...
)

REM Common CloudHub URL patterns based on artifact IDs
echo [INFO] Testing common CloudHub URL patterns...
echo.

REM Pattern 1: Based on artifact IDs from pom.xml files
set AGENT_BROKER_URL=https://onboardingbroker.!CLOUDHUB_REGION!.cloudhub.io
set EMPLOYEE_ONBOARDING_URL=https://employeeonboardingmcp.!CLOUDHUB_REGION!.cloudhub.io
set ASSET_ALLOCATION_URL=https://assetallocationserver.!CLOUDHUB_REGION!.cloudhub.io
set NOTIFICATION_URL=https://emailnotificationmcp.!CLOUDHUB_REGION!.cloudhub.io

echo Testing Pattern 1 (Artifact ID based):
echo - Agent Broker: !AGENT_BROKER_URL!
curl -s -I -X GET "!AGENT_BROKER_URL!/health" | findstr "HTTP" && set AGENT_BROKER_WORKING=true
echo - Employee Onboarding: !EMPLOYEE_ONBOARDING_URL!
curl -s -I -X GET "!EMPLOYEE_ONBOARDING_URL!/health" | findstr "HTTP" && set EMPLOYEE_ONBOARDING_WORKING=true
echo - Asset Allocation: !ASSET_ALLOCATION_URL!
curl -s -I -X GET "!ASSET_ALLOCATION_URL!/health" | findstr "HTTP" && set ASSET_ALLOCATION_WORKING=true
echo - Email Notification: !NOTIFICATION_URL!
curl -s -I -X GET "!NOTIFICATION_URL!/health" | findstr "HTTP" && set NOTIFICATION_WORKING=true
echo.

REM Pattern 2: Hyphenated versions (based on folder names)
if not defined AGENT_BROKER_WORKING (
    set AGENT_BROKER_URL_ALT=https://employee-onboarding-agent-broker.!CLOUDHUB_REGION!.cloudhub.io
    echo Testing Agent Broker Alternative: !AGENT_BROKER_URL_ALT!
    curl -s -I -X GET "!AGENT_BROKER_URL_ALT!" | findstr "HTTP" && (
        set AGENT_BROKER_URL=!AGENT_BROKER_URL_ALT!
        set AGENT_BROKER_WORKING=true
    )
)

if not defined EMPLOYEE_ONBOARDING_WORKING (
    set EMPLOYEE_ONBOARDING_URL_ALT=https://employee-onboarding-mcp-server.!CLOUDHUB_REGION!.cloudhub.io
    echo Testing Employee Onboarding Alternative: !EMPLOYEE_ONBOARDING_URL_ALT!
    curl -s -I -X GET "!EMPLOYEE_ONBOARDING_URL_ALT!" | findstr "HTTP" && (
        set EMPLOYEE_ONBOARDING_URL=!EMPLOYEE_ONBOARDING_URL_ALT!
        set EMPLOYEE_ONBOARDING_WORKING=true
    )
)

echo.
echo [INFO] Step 2: Updating React Client Environment Files...
echo.

REM Update .env.production
echo Creating updated .env.production for CloudHub...
(
echo # Production Environment - CloudHub Deployment
echo REACT_APP_AGENT_BROKER_URL=!AGENT_BROKER_URL!
echo REACT_APP_EMPLOYEE_ONBOARDING_URL=!EMPLOYEE_ONBOARDING_URL!
echo REACT_APP_ASSET_ALLOCATION_URL=!ASSET_ALLOCATION_URL!
echo REACT_APP_EMAIL_NOTIFICATION_URL=!NOTIFICATION_URL!
echo.
echo # API Configuration
echo REACT_APP_API_TIMEOUT=30000
echo REACT_APP_MAX_RETRIES=3
echo REACT_APP_RETRY_DELAY=2000
echo.
echo # Environment Settings
echo REACT_APP_ENVIRONMENT=production
echo REACT_APP_USE_CLOUDHUB=true
echo REACT_APP_ENABLE_HTTPS=true
echo.
echo # CloudHub Specific
echo REACT_APP_CLOUDHUB_REGION=!CLOUDHUB_REGION!
echo REACT_APP_DEBUG=false
echo REACT_APP_MOCK_DATA_FALLBACK=false
) > employee-onboarding-agent-fabric\react-client\.env.production

REM Update .env.staging
echo Creating updated .env.staging for CloudHub...
(
echo # Staging Environment - CloudHub Deployment
echo REACT_APP_AGENT_BROKER_URL=!AGENT_BROKER_URL!
echo REACT_APP_EMPLOYEE_ONBOARDING_URL=!EMPLOYEE_ONBOARDING_URL!
echo REACT_APP_ASSET_ALLOCATION_URL=!ASSET_ALLOCATION_URL!
echo REACT_APP_EMAIL_NOTIFICATION_URL=!NOTIFICATION_URL!
echo.
echo # API Configuration
echo REACT_APP_API_TIMEOUT=30000
echo REACT_APP_MAX_RETRIES=3
echo REACT_APP_RETRY_DELAY=2000
echo.
echo # Environment Settings
echo REACT_APP_ENVIRONMENT=staging
echo REACT_APP_USE_CLOUDHUB=true
echo REACT_APP_ENABLE_HTTPS=true
echo.
echo # CloudHub Specific
echo REACT_APP_CLOUDHUB_REGION=!CLOUDHUB_REGION!
echo REACT_APP_DEBUG=true
echo REACT_APP_MOCK_DATA_FALLBACK=false
) > employee-onboarding-agent-fabric\react-client\.env.staging

echo [INFO] Step 3: Updating API Service Configuration...
echo.

REM Update apiService.js with CloudHub URLs and better error handling
(
echo // API Service Configuration - Updated for CloudHub
echo const CONFIG = {
echo   AGENT_BROKER_URL: process.env.REACT_APP_AGENT_BROKER_URL ^|^| '!AGENT_BROKER_URL!',
echo   EMPLOYEE_ONBOARDING_URL: process.env.REACT_APP_EMPLOYEE_ONBOARDING_URL ^|^| '!EMPLOYEE_ONBOARDING_URL!',
echo   ASSET_ALLOCATION_URL: process.env.REACT_APP_ASSET_ALLOCATION_URL ^|^| '!ASSET_ALLOCATION_URL!',
echo   EMAIL_NOTIFICATION_URL: process.env.REACT_APP_EMAIL_NOTIFICATION_URL ^|^| '!NOTIFICATION_URL!',
echo   TIMEOUT: parseInt(process.env.REACT_APP_API_TIMEOUT^) ^|^| 30000,
echo   MAX_RETRIES: parseInt(process.env.REACT_APP_MAX_RETRIES^) ^|^| 3,
echo   RETRY_DELAY: parseInt(process.env.REACT_APP_RETRY_DELAY^) ^|^| 2000,
echo   USE_CLOUDHUB: process.env.REACT_APP_USE_CLOUDHUB === 'true',
echo   ENABLE_HTTPS: process.env.REACT_APP_ENABLE_HTTPS === 'true'
echo };
echo.
echo // Utility function to handle CloudHub HTTPS URLs
echo const normalizeUrl = (baseUrl, endpoint^) =^> {
echo   const url = `${baseUrl}${endpoint}`;
echo   return CONFIG.ENABLE_HTTPS ^? url.replace('http:', 'https:'^) : url;
echo };
echo.
echo const apiService = {
echo   async makeRequest(method, endpoint, data = null, service = 'AGENT_BROKER'^) {
echo     const baseUrl = CONFIG[service + '_URL'];
echo     const url = normalizeUrl(baseUrl, endpoint^);
echo.    
echo     const requestConfig = {
echo       method,
echo       headers: {
echo         'Content-Type': 'application/json',
echo         'Accept': 'application/json',
echo         'Access-Control-Allow-Origin': '*'
echo       },
echo       mode: 'cors',
echo       timeout: CONFIG.TIMEOUT
echo     };
echo.
echo     if (data^) {
echo       requestConfig.body = JSON.stringify(data^);
echo     }
echo.
echo     for (let attempt = 1; attempt ^<= CONFIG.MAX_RETRIES; attempt++^) {
echo       try {
echo         console.log(`API Request [${method}] ${url} (attempt ${attempt}^)`^);
echo         
echo         const response = await fetch(url, requestConfig^);
echo         
echo         if (!response.ok^) {
echo           const errorText = await response.text(^);
echo           throw new Error(`HTTP ${response.status}: ${errorText ^|^| response.statusText}`^);
echo         }
echo         
echo         const result = await response.json(^);
echo         console.log('API Response:', result^);
echo         return result;
echo       } catch (error^) {
echo         console.error(`API request failed (attempt ${attempt}^): ${error.message}`^);
echo         
echo         if (attempt === CONFIG.MAX_RETRIES^) {
echo           throw new Error(`Failed after ${CONFIG.MAX_RETRIES} attempts: ${error.message}`^);
echo         }
echo         
echo         // Exponential backoff with jitter
echo         const delay = CONFIG.RETRY_DELAY * Math.pow(2, attempt - 1^) + Math.random(^) * 1000;
echo         await new Promise(resolve =^> setTimeout(resolve, delay^)^);
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
echo   // Orchestration Operations
echo   async orchestrateOnboarding(employeeData^) {
echo     return this.makeRequest('POST', '/mcp/tools/orchestrate-employee-onboarding', employeeData, 'AGENT_BROKER'^);
echo   },
echo.
echo   // Notification Operations
echo   async sendNotification(notificationData^) {
echo     return this.makeRequest('POST', '/mcp/tools/send-notification', notificationData, 'EMAIL_NOTIFICATION'^);
echo   },
echo.
echo   // Health Check Operations
echo   async checkHealth(service = 'AGENT_BROKER'^) {
echo     return this.makeRequest('GET', '/health', null, service^);
echo   },
echo.
echo   async checkAllServices(^) {
echo     const services = ['AGENT_BROKER', 'EMPLOYEE_ONBOARDING', 'ASSET_ALLOCATION', 'EMAIL_NOTIFICATION'];
echo     const results = {};
echo     
echo     for (const service of services^) {
echo       try {
echo         const health = await this.checkHealth(service^);
echo         results[service] = { status: 'healthy', data: health };
echo       } catch (error^) {
echo         results[service] = { status: 'unhealthy', error: error.message };
echo       }
echo     }
echo     
echo     return results;
echo   }
echo };
echo.
echo export default apiService;
) > employee-onboarding-agent-fabric\react-client\src\services\apiService.js

echo [INFO] Step 4: Updating Test Script Configuration...
echo.

REM Update test script with CloudHub URLs
if exist "test-agent-fabric-comprehensive-nlp-mcp.js" (
    powershell -Command "
    $content = Get-Content 'test-agent-fabric-comprehensive-nlp-mcp.js' -Raw;
    $content = $content -replace 'https://[^/]+\.cloudhub\.io', '';
    $content = $content -replace 'const AGENT_BROKER_URL = [^;]+;', 'const AGENT_BROKER_URL = ''!AGENT_BROKER_URL!'';';
    $content = $content -replace 'const EMPLOYEE_ONBOARDING_URL = [^;]+;', 'const EMPLOYEE_ONBOARDING_URL = ''!EMPLOYEE_ONBOARDING_URL!'';';
    $content = $content -replace 'const ASSET_ALLOCATION_URL = [^;]+;', 'const ASSET_ALLOCATION_URL = ''!ASSET_ALLOCATION_URL!'';';
    $content = $content -replace 'const EMAIL_NOTIFICATION_URL = [^;]+;', 'const EMAIL_NOTIFICATION_URL = ''!NOTIFICATION_URL!'';';
    Set-Content 'test-agent-fabric-comprehensive-nlp-mcp.js' -Value $content;
    "
    echo [SUCCESS] Updated test script with CloudHub URLs
) else (
    echo [WARNING] Test script not found, skipping update
)

echo.
echo [INFO] Step 5: Creating CloudHub URL Configuration File...
echo.

REM Create a configuration file for easy reference
(
echo # CloudHub Application URLs Configuration
echo # Generated on %date% at %time%
echo.
echo CLOUDHUB_REGION=!CLOUDHUB_REGION!
echo.
echo # Application URLs
echo AGENT_BROKER_URL=!AGENT_BROKER_URL!
echo EMPLOYEE_ONBOARDING_URL=!EMPLOYEE_ONBOARDING_URL!
echo ASSET_ALLOCATION_URL=!ASSET_ALLOCATION_URL!
echo EMAIL_NOTIFICATION_URL=!NOTIFICATION_URL!
echo.
echo # Health Check URLs
echo AGENT_BROKER_HEALTH=!AGENT_BROKER_URL!/health
echo EMPLOYEE_ONBOARDING_HEALTH=!EMPLOYEE_ONBOARDING_URL!/health
echo ASSET_ALLOCATION_HEALTH=!ASSET_ALLOCATION_URL!/health
echo EMAIL_NOTIFICATION_HEALTH=!NOTIFICATION_URL!/health
) > cloudhub-urls.env

echo ======================================================================
echo   CONFIGURATION UPDATE SUMMARY
echo ======================================================================
echo.
echo [SUCCESS] Updated CloudHub Configuration:
echo   Region: !CLOUDHUB_REGION!
echo   Agent Broker: !AGENT_BROKER_URL!
echo   Employee Onboarding: !EMPLOYEE_ONBOARDING_URL!
echo   Asset Allocation: !ASSET_ALLOCATION_URL!
echo   Email Notification: !NOTIFICATION_URL!
echo.
echo [INFO] Files Updated:
echo   - employee-onboarding-agent-fabric\react-client\.env.production
echo   - employee-onboarding-agent-fabric\react-client\.env.staging
echo   - employee-onboarding-agent-fabric\react-client\src\services\apiService.js
echo   - test-agent-fabric-comprehensive-nlp-mcp.js (if exists)
echo   - cloudhub-urls.env (configuration reference)
echo.
echo [NEXT STEPS]
echo   1. Verify URLs in Anypoint Platform Runtime Manager
echo   2. Test endpoints: run test-agent-fabric-comprehensive-nlp-mcp.js
echo   3. Build React client: cd employee-onboarding-agent-fabric\react-client && npm run build
echo   4. Start React client: npm start
echo   5. Test health checks: curl [URL]/health for each service
echo.

REM Create a quick test script
echo [INFO] Creating quick health check script...
(
echo @echo off
echo echo Testing CloudHub Endpoints Health...
echo curl -s "!AGENT_BROKER_URL!/health" ^|^| echo Agent Broker: FAILED
echo curl -s "!EMPLOYEE_ONBOARDING_URL!/health" ^|^| echo Employee Onboarding: FAILED  
echo curl -s "!ASSET_ALLOCATION_URL!/health" ^|^| echo Asset Allocation: FAILED
echo curl -s "!NOTIFICATION_URL!/health" ^|^| echo Email Notification: FAILED
echo echo Health check complete.
) > test-cloudhub-health.bat

echo [SUCCESS] Created test-cloudhub-health.bat for quick health checks
echo.

pause
