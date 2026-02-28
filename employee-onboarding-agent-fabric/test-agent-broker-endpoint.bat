@echo off
setlocal enabledelayedexpansion

echo ================================================================
echo TESTING AGENT BROKER MCP ENDPOINT
echo ================================================================
echo URL: http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo Method: POST
echo ================================================================
echo.

:: Create JSON payload file
echo Creating test payload...
(
echo {
echo   "firstName": "John",
echo   "lastName": "Doe", 
echo   "email": "john.doe@example.com",
echo   "phone": "+1-555-123-4567",
echo   "department": "Engineering",
echo   "position": "Software Developer",
echo   "startDate": "2024-03-01",
echo   "salary": 75000,
echo   "manager": "Jane Smith",
echo   "managerName": "Jane Smith",
echo   "managerEmail": "jane.smith@example.com",
echo   "companyName": "TechCorp Inc",
echo   "orientationDate": "2024-03-01",
echo   "assets": [
echo     "laptop",
echo     "phone", 
echo     "id-card",
echo     "parking-pass"
echo   ]
echo }
) > test_payload.json

echo.
echo ================================================================
echo PAYLOAD CREATED: test_payload.json
echo ================================================================
type test_payload.json
echo.
echo ================================================================

echo.
echo Testing with PowerShell (Invoke-RestMethod)...
echo.

powershell -Command "& {$headers = @{'Content-Type' = 'application/json'}; $body = Get-Content 'test_payload.json' -Raw; try { $response = Invoke-RestMethod -Uri 'http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding' -Method POST -Body $body -Headers $headers -TimeoutSec 60; Write-Host '=== SUCCESS RESPONSE ==='; $response | ConvertTo-Json -Depth 10 } catch { Write-Host '=== ERROR RESPONSE ==='; Write-Host 'StatusCode:' $_.Exception.Response.StatusCode; Write-Host 'StatusDescription:' $_.Exception.Response.StatusDescription; if ($_.Exception.Response.GetResponseStream()) { $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); $responseBody = $reader.ReadToEnd(); Write-Host 'Response Body:' $responseBody } } }"

echo.
echo ================================================================
echo Alternative: Testing with cURL (if available)...
echo ================================================================

where curl >nul 2>nul
if %ERRORLEVEL%==0 (
    echo.
    echo Running cURL test...
    curl -X POST ^
         -H "Content-Type: application/json" ^
         -d @test_payload.json ^
         --max-time 60 ^
         http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
    echo.
) else (
    echo cURL not available, using PowerShell method above.
)

echo.
echo ================================================================
echo TESTING HEALTH CHECK ENDPOINT
echo ================================================================
echo.
powershell -Command "& {try { $response = Invoke-RestMethod -Uri 'http://agent-broker-mcp-server.us-e1.cloudhub.io/health' -Method GET -TimeoutSec 30; Write-Host '=== HEALTH CHECK SUCCESS ==='; $response | ConvertTo-Json -Depth 5 } catch { Write-Host '=== HEALTH CHECK ERROR ==='; Write-Host $_.Exception.Message } }"

echo.
echo ================================================================
echo TESTING MCP INFO ENDPOINT  
echo ================================================================
echo.
powershell -Command "& {try { $response = Invoke-RestMethod -Uri 'http://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info' -Method GET -TimeoutSec 30; Write-Host '=== MCP INFO SUCCESS ==='; $response | ConvertTo-Json -Depth 5 } catch { Write-Host '=== MCP INFO ERROR ==='; Write-Host $_.Exception.Message } }"

echo.
echo ================================================================
echo TEST COMPLETED
echo ================================================================
echo Payload file: test_payload.json (kept for reference)
echo.

pause
