@echo off 
echo Testing CloudHub HTTPS Configuration... 
echo. 
 
REM Test HTTPS endpoint 
echo Testing HTTPS endpoint... 
curl -k -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/health" 
echo. 
 
REM Test HTTP endpoint (should redirect to HTTPS) 
echo Testing HTTP endpoint (should redirect)... 
curl -L -X GET "http://asset-allocation-mcp-server.us-e1.cloudhub.io/health" 
echo. 
 
REM Test with timeout settings 
echo Testing with extended timeout... 
curl -k --connect-timeout 30 --max-time 60 -X GET "https://asset-allocation-mcp-server.us-e1.cloudhub.io/health" 
echo. 
pause 
