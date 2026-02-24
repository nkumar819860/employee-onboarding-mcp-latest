@echo off
echo ============================================
echo    VALIDATE CONNECTED APP CREDENTIALS
echo    Testing Authentication Before Deployment  
echo ============================================
echo.

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo [INFO] Current directory: %CD%
echo [INFO] Loading credentials from .env file...
echo.

REM Load from .env (secure - no hardcoding)
if exist ".env" (
    for /f "usebackq eol=# tokens=1,2 delims==" %%a in (".env") do (
        if not "%%a"=="" (
            set "%%a=%%b"
        )
    )
    echo [SUCCESS] Credentials loaded from .env
) else (
    echo [ERROR] .env file not found! Please create .env file with your credentials
    echo Required variables:
    echo   ANYPOINT_CLIENT_ID=your_client_id
    echo   ANYPOINT_CLIENT_SECRET=your_client_secret
    echo   ANYPOINT_ORG_ID=your_org_id
    pause
    exit /b 1
)

echo [INFO] Client ID: %ANYPOINT_CLIENT_ID:~0,12%... (masked)
echo [INFO] Client Secret: %ANYPOINT_CLIENT_SECRET:~0,6%... (masked)  
echo [INFO] Organization ID: %ANYPOINT_ORG_ID%
echo.

REM Validate vars exist
if "%ANYPOINT_CLIENT_ID%"=="" (
    echo [ERROR] ANYPOINT_CLIENT_ID missing from .env
    pause & exit /b 1
)
if "%ANYPOINT_CLIENT_SECRET%"=="" (
    echo [ERROR] ANYPOINT_CLIENT_SECRET missing from .env  
    pause & exit /b 1
)
if "%ANYPOINT_ORG_ID%"=="" (
    echo [ERROR] ANYPOINT_ORG_ID missing from .env
    pause & exit /b 1
)

REM Use PowerShell with simple string body (CORRECTED FOR 422 ERROR)
powershell -Command ^
"$ErrorActionPreference = 'Stop'; ^
try { ^
    Write-Host '[INFO] Making authentication request...' -ForegroundColor Green; ^
    ^
    $clientId = '%ANYPOINT_CLIENT_ID%'; ^
    $clientSecret = '%ANYPOINT_CLIENT_SECRET%'; ^
    $orgId = '%ANYPOINT_ORG_ID%'; ^
    ^
    $body = \"grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret\"; ^
    Write-Host '[DEBUG] Request body prepared' -ForegroundColor Yellow; ^
    ^
    $tokenResponse = Invoke-RestMethod -Uri 'https://anypoint.mulesoft.com/accounts/oauth2/token' -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded'; ^
    Write-Host '[SUCCESS] Token obtained!' -ForegroundColor Green; ^
    Write-Host '[INFO] Token type:' $tokenResponse.token_type -ForegroundColor Green; ^
    Write-Host '[INFO] Expires in:' $tokenResponse.expires_in 'seconds' -ForegroundColor Green; ^
    ^
    $authHeaders = @{ ^
        'Authorization' = ($tokenResponse.token_type + ' ' + $tokenResponse.access_token); ^
        'Content-Type' = 'application/json' ^
    }; ^
    ^
    Write-Host '[INFO] Testing organization access...' -ForegroundColor Green; ^
    $orgResponse = Invoke-RestMethod -Uri \"https://anypoint.mulesoft.com/accounts/api/me\" -Method Get -Headers $authHeaders; ^
    ^
    Write-Host '[SUCCESS] Organization access confirmed!' -ForegroundColor Green; ^
    Write-Host '[INFO] User Name:' $orgResponse.user.firstName $orgResponse.user.lastName -ForegroundColor Green; ^
    Write-Host '[INFO] Organization:' $orgResponse.user.organizationId -ForegroundColor Green; ^
    Write-Host ''; ^
    ^
    Write-Host '============================================' -ForegroundColor Green; ^
    Write-Host '    CREDENTIALS VALIDATION SUCCESSFUL!' -ForegroundColor Green; ^
    Write-Host '============================================' -ForegroundColor Green; ^
    Write-Host '[SUCCESS] Ready for deployment!' -ForegroundColor Green; ^
    exit 0; ^
} ^
catch { ^
    Write-Host '[ERROR] Validation failed!' -ForegroundColor Red; ^
    Write-Host '[ERROR]' $_.Exception.Message -ForegroundColor Red; ^
    ^
    if ($_.Exception.Response) { ^
        $status = $_.Exception.Response.StatusCode.value__; ^
        Write-Host '[ERROR] Status Code:' $status -ForegroundColor Red; ^
        ^
        if ($status -eq 401) { ^
            Write-Host '[FIX 401] Client credentials invalid or scopes missing:' -ForegroundColor Yellow; ^
            Write-Host '  → Verify Client ID/Secret exact match' -ForegroundColor Yellow; ^
            Write-Host '  → Add scopes: Deploy Applications, Manage Applications' -ForegroundColor Yellow; ^
        } elseif ($status -eq 403) { ^
            Write-Host '[FIX 403] Insufficient scopes for organization' -ForegroundColor Yellow; ^
        } elseif ($status -eq 404) { ^
            Write-Host '[FIX 404] Organization ID incorrect' -ForegroundColor Yellow; ^
        } elseif ($status -eq 422) { ^
            Write-Host '[FIX 422] Invalid request format or missing required fields:' -ForegroundColor Yellow; ^
            Write-Host '  → Check Connected App configuration in Access Management' -ForegroundColor Yellow; ^
            Write-Host '  → Ensure scopes include: cloudhub:applications:read, cloudhub:applications:write' -ForegroundColor Yellow; ^
            Write-Host '  → Verify grant_type client_credentials is enabled' -ForegroundColor Yellow; ^
        } ^
    } ^
    Write-Host ''; ^
    Write-Host '============================================' -ForegroundColor Red; ^
    Write-Host '    CREDENTIALS VALIDATION FAILED!' -ForegroundColor Red; ^
    Write-Host '============================================' -ForegroundColor Red; ^
    exit 1; ^
}"

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Credential validation FAILED
    echo [HELP] Fix issues above, then re-run
    pause
    exit /b 1
)

echo.
echo [SUCCESS] ✅ Connected App credentials VALIDATED!
echo [NEXT]   Run: deploy-all-mcp-servers.bat
echo.
pause
