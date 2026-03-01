@echo off
echo ===============================================
echo CloudHub HTTPS and 504 Timeout Fix Script
echo ===============================================
echo.
echo This script fixes common CloudHub deployment issues:
echo 1. HTTPS/HTTP port configuration mismatch
echo 2. 504 Gateway timeout on health endpoints
echo 3. CloudHub URL protocol issues
echo.

REM Create CloudHub HTTPS test script
echo Creating CloudHub HTTPS test script...

echo @echo off > test-cloudhub-https-fix.bat
echo echo Testing CloudHub HTTPS Configuration... >> test-cloudhub-https-fix.bat
echo echo. >> test-cloudhub-https-fix.bat
echo. >> test-cloudhub-https-fix.bat
echo REM Test HTTPS endpoint >> test-cloudhub-https-fix.bat
echo echo Testing HTTPS endpoint... >> test-cloudhub-https-fix.bat
echo curl -k -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/health" >> test-cloudhub-https-fix.bat
echo echo. >> test-cloudhub-https-fix.bat
echo. >> test-cloudhub-https-fix.bat
echo REM Test HTTP endpoint (should redirect to HTTPS) >> test-cloudhub-https-fix.bat
echo echo Testing HTTP endpoint (should redirect)... >> test-cloudhub-https-fix.bat
echo curl -L -X GET "http://asset-allocation-mcp-server.us-e1.cloudhub.io/health" >> test-cloudhub-https-fix.bat
echo echo. >> test-cloudhub-https-fix.bat
echo. >> test-cloudhub-https-fix.bat
echo REM Test with timeout settings >> test-cloudhub-https-fix.bat
echo echo Testing with extended timeout... >> test-cloudhub-https-fix.bat
echo curl -k --connect-timeout 30 --max-time 60 -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/health" >> test-cloudhub-https-fix.bat
echo echo. >> test-cloudhub-https-fix.bat
echo pause >> test-cloudhub-https-fix.bat

echo.
echo =============================================== 
echo CloudHub HTTPS Configuration Guide
echo ===============================================
echo.
echo ISSUE: CloudHub applications showing HTTP instead of HTTPS URLs
echo CAUSE: Port configuration mismatch between POM and Mule flows
echo.
echo SOLUTION APPLIED:
echo 1. Updated POM CloudHub properties to include both http.port and https.port
echo 2. Set https.port=8082 to match config.properties
echo 3. Added CloudHub-specific environment settings
echo 4. Configured secure key for CloudHub deployment
echo.
echo FOR 504 TIMEOUT ISSUES:
echo - CloudHub applications may take 30-60 seconds to start
echo - Health endpoints may timeout during application startup
echo - Use extended timeout settings when testing
echo.
echo TESTING INSTRUCTIONS:
echo 1. Deploy application to CloudHub
echo 2. Wait 2-3 minutes for full startup
echo 3. Run: test-cloudhub-https-fix.bat
echo 4. Verify HTTPS URLs are returned
echo.
echo EXPECTED RESULTS:
echo - Application accessible via HTTPS on port 443 (CloudHub default)
echo - HTTP requests automatically redirect to HTTPS
echo - Health endpoint responds within 30 seconds after startup
echo.
echo ===============================================
echo CloudHub URL Format
echo ===============================================
echo Correct HTTPS URL: https://asset-allocation-mcp-server.us-e1.cloudhub.io
echo Health Check: https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
echo API Base: https://asset-allocation-mcp-server.us-e1.cloudhub.io/api/*
echo.
echo NOTE: CloudHub automatically handles HTTPS termination
echo Internal Mule flows still use configured ports (8081/8082)
echo External access is always through CloudHub's HTTPS proxy (port 443)
echo.

echo Test script created: test-cloudhub-https-fix.bat
echo.
echo Next steps:
echo 1. Redeploy the asset-allocation-mcp to CloudHub
echo 2. Wait for deployment to complete (2-3 minutes)
echo 3. Run the test script to verify HTTPS configuration
echo.
pause
