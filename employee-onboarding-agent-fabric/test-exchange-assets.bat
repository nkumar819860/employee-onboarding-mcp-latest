@echo off
REM ========================================
REM EXCHANGE VERSION CHECKER - FIX 409 ERROR
REM FIXED: Correct Anypoint Platform Token URL
REM ========================================
title Exchange Version Checker - MCP Publishing

REM === CONFIG ===
set CLIENT_ID=aec0b3117f7d4d4e8433a7d3d23bc80e
set CLIENT_SECRET=9bc9D86a77b343b98a148C0313239aDA
set ORG_ID=47562e5d-bf49-440a-a0f5-a9cea0a89aa9
set ASSET_ID=notification-mcp

echo ========================================
echo EXCHANGE VERSION CHECKER v2.0
echo ========================================
echo Asset: %ASSET_ID%
echo Org:   %ORG_ID%
echo.

REM === 1. GET TOKEN (CORRECTED URL) ===
echo [1/3] Getting Connected App token...
powershell -NoProfile -Command ^
"$body = 'grant_type=client_credentials&client_id=%CLIENT_ID%&client_secret=%CLIENT_SECRET%'; ^
$response = Invoke-RestMethod -Uri 'https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token' -Method Post -Body $body -ContentType 'application/x-www-form-urlencoded'; ^
$response.access_token" > token.tmp 2>nul

set /p ACCESS_TOKEN=<token.tmp
if "%ACCESS_TOKEN%"=="" (
    echo [ERROR] Token failed. Check:
    echo 1. CLIENT_ID/CLIENT_SECRET correct?
    echo 2. Connected App has "Exchange Publisher" scope?
    echo 3. Business Group Admin role?
    echo.
    echo Manual token test:
    echo curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
    echo    -d "grant_type=client_credentials" ^
    echo    -d "client_id=%CLIENT_ID%" ^
    echo    -d "client_secret=%CLIENT_SECRET%"
    del token.tmp 2>nul
    pause
    exit /b 1
)
echo [OK] Token: %ACCESS_TOKEN:~0,20%...

REM === 2. GET ASSET VERSIONS ===
echo [2/3] Checking %ASSET_ID% versions...
powershell -NoProfile -Command ^
"$headers = @{'Authorization'='Bearer %ACCESS_TOKEN%'}; ^
$response = Invoke-RestMethod -Uri 'https://anypoint.mulesoft.com/exchange/api/v1/assets/%ORG_ID%/%ASSET_ID%/versions' -Method Get -Headers $headers; ^
if($response.assets){ ^
    $latest = ($response.assets | Sort-Object version -Descending | Select-Object -First 1); ^
    Write-Output \"Latest: $($latest.version)\"; ^
    $parts = $latest.version.Split('.'); ^
    $next = \"$($parts[0]).$($parts[1]).\" + ([int]$parts[2] + 1); ^
    Write-Output \"Next version: $next\"; ^
    $next | Out-File -FilePath 'next-version.txt' -Encoding utf8 ^
} else { ^
    Write-Output \"No versions found - First publish: 1.0\"; ^
    '1.0' | Out-File -FilePath 'next-version.txt' -Encoding utf8 ^
}" > versions.txt 2>nul

set /p NEXT_VERSION=<next-version.txt
echo [OK] Next version: %NEXT_VERSION%

REM === 3. AUTO-FIX pom.xml ===
echo.
echo ========================================
echo RECOMMENDATIONS:
echo ========================================
echo 1. UPDATE pom.xml: ^<version^>%NEXT_VERSION%^</version>
echo 2. mvn clean package -DskipTests
echo 3. Studio: Publish -^> TEMPLATE project type
echo.

:MENU
set /p CHOICE="Auto-update pom.xml and build? (Y/N/Q): "
if /i "%CHOICE%"=="Q" goto END
if /i "%CHOICE%"=="Y" (
    echo [3/3] Updating pom.xml...
    powershell -NoProfile -Command ^
    "(Get-Content pom.xml) -replace '^\s*\<version\>.*\</version\>', \"    <version>%NEXT_VERSION%</version>\" | Set-Content pom.xml"
    
    echo [4/4] Building %NEXT_VERSION%...
    call mvn clean package -DskipTests
    
    echo.
    echo [SUCCESS] Ready for Studio Publish!
    echo JAR: target\notification-mcp-%NEXT_VERSION%-mule-application.jar
    echo Studio: Right-click -^> Publish to Exchange -^> TEMPLATE
    goto END
)
if /i "%CHOICE%"=="N" goto END

:END
del token.tmp next-version.txt versions.txt 2>nul
echo.
echo Press any key to exit...
pause >nul
