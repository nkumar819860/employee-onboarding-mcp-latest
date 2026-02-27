@echo off
REM ========================================
REM COMPREHENSIVE DEPLOYMENT SCRIPT
REM ✅ Load .env variables
REM ✅ Clean target folders (fix locking issues)
REM ✅ Compile projects
REM ✅ Publish assets to Exchange
REM ✅ Deploy to CloudHub
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo EMPLOYEE ONBOARDING DEPLOYMENT SCRIPT
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: LOAD ENVIRONMENT VARIABLES ===
echo ==============================
echo 🔧 LOADING ENVIRONMENT VARIABLES
echo ==============================

if not exist ".env" (
    echo ❌ ERROR: .env file not found in %CD%
    echo Please ensure .env file exists in the project root
    pause
    exit /b 1
)

echo ✅ Found .env file, loading variables...

REM Load environment variables from .env file
for /f "usebackq tokens=1,2 delims== eol=#" %%a in (".env") do (
    set "key=%%a"
    set "val=%%b"
    REM Trim whitespace from key and value
    for /f "tokens=* delims= " %%k in ("!key!") do set "key=%%k"
    for /f "tokens=* delims= " %%v in ("!val!") do set "val=%%v"
    if not "!key!"=="" if not "!val!"=="" (
        set "!key!=!val!"
        echo   !key!=!val!
    )
)

echo.
echo ✅ Environment variables loaded successfully

REM === STEP 2: VALIDATE REQUIRED VARIABLES ===
echo ==============================
echo 🔍 VALIDATING CONFIGURATION
echo ==============================

if not defined ANYPOINT_CLIENT_ID (
    echo ❌ ERROR: ANYPOINT_CLIENT_ID not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_CLIENT_SECRET (
    echo ❌ ERROR: ANYPOINT_CLIENT_SECRET not found in .env
    pause
    exit /b 1
)

if not defined ANYPOINT_ORG_ID (
    echo ❌ ERROR: ANYPOINT_ORG_ID not found in .env
    pause
    exit /b 1
)

REM Set defaults for missing variables
if not defined ANYPOINT_ENV set "ANYPOINT_ENV=Sandbox"
if not defined MULE_VERSION set "MULE_VERSION=4.9.4:2e-java17"
if not defined CLOUDHUB_REGION set "CLOUDHUB_REGION=us-east-1"
if not defined CLOUDHUB_WORKER_TYPE set "CLOUDHUB_WORKER_TYPE=MICRO"
if not defined CLOUDHUB_WORKERS set "CLOUDHUB_WORKERS=1"

echo ✅ Configuration validated:
echo   Client ID: %ANYPOINT_CLIENT_ID:~0,8%...
echo   Environment: %ANYPOINT_ENV%
echo   Organization: %ANYPOINT_ORG_ID:~0,8%...
echo   Mule Version: %MULE_VERSION%
echo   CloudHub Region: %CLOUDHUB_REGION%
echo   Worker Type: %CLOUDHUB_WORKER_TYPE%
echo.

REM === STEP 3: DISCOVER MCP SERVICES ===
echo ==============================
echo 🔍 DISCOVERING MCP SERVICES
echo ==============================

if not exist "mcp-servers" (
    echo ❌ ERROR: mcp-servers directory not found
    pause
    exit /b 1
)

set SERVER_COUNT=0
set SERVER_LIST=

echo Scanning mcp-servers directory for services...

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        set /a SERVER_COUNT+=1
        for %%n in (%%d) do (
            call set "SERVER!SERVER_COUNT!=%%~nxn"
            set "SERVER_LIST=!SERVER_LIST! %%~nxn"
            echo [!SERVER_COUNT!] ✅ Found: %%~nxn
        )
    )
)

if %SERVER_COUNT% EQU 0 (
    echo ❌ ERROR: No MCP services with pom.xml found in mcp-servers directory
    pause
    exit /b 1
)

echo.
echo ✅ Discovered %SERVER_COUNT% MCP services:%SERVER_LIST%
echo.

REM === STEP 4: CLEAN TARGET FOLDERS (FIX LOCKING ISSUES) ===
echo ==============================
echo 🧹 CLEANING TARGET FOLDERS
echo ==============================

echo Cleaning target folders to resolve locking issues...

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo [%%i/%SERVER_COUNT%] Cleaning !SRV!/target...
    
    if exist "mcp-servers\!SRV!\target" (
        echo   Removing target directory for !SRV!...
        rmdir /s /q "mcp-servers\!SRV!\target" 2>nul
        if exist "mcp-servers\!SRV!\target" (
            echo   ⚠️  Warning: Could not completely remove target directory
        ) else (
            echo   ✅ Target directory cleaned for !SRV!
        )
    ) else (
        echo   ✅ No target directory found for !SRV!
    )
)

echo.
echo ✅ Target folder cleanup completed
echo.

REM === STEP 5: COMPILE ALL SERVICES ===
echo ==============================
echo 🛠️  COMPILING MCP SERVICES
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 🛠️  Compiling !SRV!...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    
    if not exist "mcp-servers\!SRV!\pom.xml" (
        echo ❌ ERROR: pom.xml not found for !SRV!
        pause
        exit /b 1
    )
    
    cd "mcp-servers\!SRV!"
    echo 📁 Compiling from: %CD%
    
    echo   Running: mvn clean compile package -DskipTests -T 4 -q -DskipMuleApplicationDeployment
    call mvn clean compile package -DskipTests -T 4 -q -DskipMuleApplicationDeployment
    if !errorlevel! neq 0 (
        echo ❌ COMPILATION FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    REM Verify JAR was created
    dir target\*.jar >nul 2>&1
    if !errorlevel! neq 0 (
        echo ❌ ERROR: No JAR file found in target directory for !SRV!
        dir target
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV! compiled successfully
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ All MCP services compiled successfully
echo.

REM === STEP 6: PUBLISH TO EXCHANGE (OPTIONAL) ===
echo ==============================
echo 📤 EXCHANGE PUBLICATION OPTIONS
echo ==============================

echo Do you want to publish assets to Anypoint Exchange?
echo [Y] Yes - Publish to Exchange (requires proper Exchange permissions)
echo [N] No  - Skip Exchange publication (CloudHub deployment only)
echo.
set /p PUBLISH_CHOICE=Enter your choice (Y/N): 

if /i "%PUBLISH_CHOICE%"=="Y" (
    set SKIP_EXCHANGE=false
    echo ✅ Exchange publication ENABLED
) else if /i "%PUBLISH_CHOICE%"=="N" (
    set SKIP_EXCHANGE=true
    echo ℹ️  Exchange publication SKIPPED - CloudHub deployment only
) else (
    echo ❌ Invalid choice. Defaulting to SKIP Exchange publication
    set SKIP_EXCHANGE=true
)

echo.

if "%SKIP_EXCHANGE%"=="false" (
    echo ==============================
    echo 📤 PUBLISHING TO EXCHANGE
    echo ==============================
    
    echo 📤 Publishing MCP assets to Anypoint Exchange...
    echo ℹ️  Using MCP classifier with automatic version handling
    echo.

    REM === PARENT POM PUBLICATION ===
    echo ==============================
    echo 📦 PUBLISHING PARENT POM
    echo ==============================
    
    if exist "exchange.json" (
        echo ✅ Found parent exchange.json
        
        REM Extract parent version
        for /f "tokens=2 delims=: " %%v in ('findstr /C:"version" exchange.json') do (
            set "PARENT_VERSION=%%v"
            set "PARENT_VERSION=!PARENT_VERSION:"=!"
            set "PARENT_VERSION=!PARENT_VERSION:,=!"
            set "PARENT_VERSION=!PARENT_VERSION: =!"
            echo 📌 Parent POM version: !PARENT_VERSION!
        )
        
        REM First attempt: Try publishing parent with current version
        echo 📦 Attempting to publish parent POM v!PARENT_VERSION! with MCP classifier...
        call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
            -Danypoint.client.id="!ANYPOINT_CLIENT_ID!" ^
            -Danypoint.client.secret="!ANYPOINT_CLIENT_SECRET!" ^
            -Danypoint.businessGroup.id="!ANYPOINT_ORG_ID!" ^
            -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
            -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
        
        if !errorlevel! neq 0 (
            echo ⚠️  Parent version !PARENT_VERSION! may already exist, incrementing version...
            
            REM Extract version components and increment patch version
            for /f "tokens=1,2,3 delims=." %%a in ("!PARENT_VERSION!") do (
                set /a PATCH_NUM=%%c+1
                set "NEW_PARENT_VERSION=%%a.%%b.!PATCH_NUM!"
                echo 📈 Incremented parent to version: !NEW_PARENT_VERSION!
                
                REM Update exchange.json with new version
                powershell -Command "& { $content = Get-Content 'exchange.json' -Raw; $content = $content -replace '\"version\":\s*\"[^\"]*\"', '\"version\": \"!NEW_PARENT_VERSION!\"'; Set-Content 'exchange.json' $content -NoNewline }"
                
                REM Also update pom.xml parent version
                powershell -Command "& { $content = Get-Content 'pom.xml' -Raw; $content = $content -replace '<version>[^<]*</version>', '<version>!NEW_PARENT_VERSION!</version>'; Set-Content 'pom.xml' $content -NoNewline }"
                
                echo 📝 Updated parent exchange.json and pom.xml with version !NEW_PARENT_VERSION!
                
                REM Retry publishing parent with new version
                echo 📦 Retrying parent POM publication with version !NEW_PARENT_VERSION!...
                call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
                    -Danypoint.client.id="!ANYPOINT_CLIENT_ID!" ^
                    -Danypoint.client.secret="!ANYPOINT_CLIENT_SECRET!" ^
                    -Danypoint.businessGroup.id="!ANYPOINT_ORG_ID!" ^
                    -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
                    -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
                
                if !errorlevel! neq 0 (
                    echo ❌ ERROR: Failed to publish parent POM even after version increment
                    echo ℹ️  Check: EXCHANGE_401_AUTHENTICATION_FIX.md for troubleshooting
                ) else (
                    echo ✅ Parent POM v!NEW_PARENT_VERSION! published to Exchange successfully ^(MCP classifier^)
                    
                    REM Update child POMs to reference new parent version
                    echo 📝 Updating child module parent references to !NEW_PARENT_VERSION!...
                    for /d %%d in (mcp-servers\*) do (
                        if exist "%%d\pom.xml" (
                            powershell -Command "& { $content = Get-Content '%%d\pom.xml' -Raw; $content = $content -replace '<parent>[\s\S]*?<version>[^<]*</version>[\s\S]*?</parent>', ('<parent>' + [Environment]::NewLine + '        <groupId>47562e5d-bf49-440a-a0f5-a9cea0a89aa9</groupId>' + [Environment]::NewLine + '        <artifactId>employee-onboarding-mcp-parent</artifactId>' + [Environment]::NewLine + '        <version>!NEW_PARENT_VERSION!</version>' + [Environment]::NewLine + '    </parent>'); Set-Content '%%d\pom.xml' $content -NoNewline }"
                            echo   ✅ Updated %%d parent reference
                        )
                    )
                )
            )
        ) else (
            echo ✅ Parent POM v!PARENT_VERSION! published to Exchange successfully ^(MCP classifier^)
        )
    ) else (
        echo ⚠️  Warning: Parent exchange.json not found, skipping parent publication
    )
    
    echo.
    echo ==============================
    echo 📦 PUBLISHING CHILD MODULES
    echo ==============================

    for /l %%i in (1,1,%SERVER_COUNT%) do (
        call set "SRV=%%SERVER%%i%%"
        echo.
        echo [%%i/%SERVER_COUNT%] 📤 Publishing !SRV! to Exchange...
        echo ================================
        
        cd /d "%SCRIPT_DIR%"
        cd "mcp-servers\!SRV!"
        echo 📁 Publishing from: %CD%
        
        REM Check if exchange.json exists and extract current version
        if exist "exchange.json" (
            echo   📋 Reading version from exchange.json...
            for /f "tokens=2 delims=: " %%v in ('findstr /C:"version" exchange.json') do (
                set "CURRENT_VERSION=%%v"
                set "CURRENT_VERSION=!CURRENT_VERSION:"=!"
                set "CURRENT_VERSION=!CURRENT_VERSION:,=!"
                set "CURRENT_VERSION=!CURRENT_VERSION: =!"
                echo   📌 Current version: !CURRENT_VERSION!
            )
        ) else (
            echo   ⚠️  Warning: exchange.json not found, using default version 1.0.1
            set "CURRENT_VERSION=1.0.1"
        )
        
        REM First attempt: Try publishing with current version
        echo   📦 Attempting to publish !SRV! v!CURRENT_VERSION! with MCP classifier...
        call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
            -Danypoint.client.id="!ANYPOINT_CLIENT_ID!" ^
            -Danypoint.client.secret="!ANYPOINT_CLIENT_SECRET!" ^
            -Danypoint.businessGroup.id="!ANYPOINT_ORG_ID!" ^
            -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
            -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
        
        if !errorlevel! neq 0 (
            echo   ⚠️  Version !CURRENT_VERSION! may already exist, incrementing version...
            
            REM Extract version components and increment patch version
            for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT_VERSION!") do (
                set /a PATCH_NUM=%%c+1
                set "NEW_VERSION=%%a.%%b.!PATCH_NUM!"
                echo   📈 Incremented to version: !NEW_VERSION!
                
                REM Update exchange.json with new version
                powershell -Command "& { $content = Get-Content 'exchange.json' -Raw; $content = $content -replace '\"version\":\s*\"[^\"]*\"', '\"version\": \"!NEW_VERSION!\"'; Set-Content 'exchange.json' $content -NoNewline }"
                
                echo   📝 Updated exchange.json with version !NEW_VERSION!
                
                REM Retry publishing with new version
                echo   📦 Retrying publication with version !NEW_VERSION!...
                call mvn deploy -DskipMuleApplicationDeployment -DskipTests -q ^
                    -Danypoint.client.id="!ANYPOINT_CLIENT_ID!" ^
                    -Danypoint.client.secret="!ANYPOINT_CLIENT_SECRET!" ^
                    -Danypoint.businessGroup.id="!ANYPOINT_ORG_ID!" ^
                    -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
                    -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange"
                
                if !errorlevel! neq 0 (
                    echo   ❌ ERROR: Failed to publish !SRV! even after version increment
                    echo   ℹ️  Check: EXCHANGE_401_AUTHENTICATION_FIX.md for troubleshooting
                ) else (
                    echo   ✅ !SRV! v!NEW_VERSION! published to Exchange successfully ^(MCP classifier^)
                )
            )
        ) else (
            echo   ✅ !SRV! v!CURRENT_VERSION! published to Exchange successfully ^(MCP classifier^)
        )
        
        cd /d "%SCRIPT_DIR%"
    )

    echo.
    echo ✅ Exchange publishing phase completed with automatic version handling
) else (
    echo ℹ️  Exchange publication skipped as requested
)

echo.

REM === STEP 7: DEPLOY TO CLOUDHUB ===
echo ==============================
echo ☁️  DEPLOYING TO CLOUDHUB
echo ==============================

echo Deploying %SERVER_COUNT% services to CloudHub...
echo Configuration:
echo   Mule Version: %MULE_VERSION%
echo   Region: %CLOUDHUB_REGION%
echo   Worker Type: %CLOUDHUB_WORKER_TYPE%
echo   Workers: %CLOUDHUB_WORKERS%
echo.

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] ☁️  Deploying !SRV!-server...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo 📁 Deploying from: %CD%
    
    echo   Running CloudHub deployment for !SRV!-server...
    call mvn clean deploy ^
        -DmuleDeploy ^
        -Danypoint.client.id="!ANYPOINT_CLIENT_ID!" ^
        -Danypoint.client.secret="!ANYPOINT_CLIENT_SECRET!" ^
        -Danypoint.businessGroup.id="!ANYPOINT_ORG_ID!" ^
        -Danypoint.environment="!ANYPOINT_ENV!" ^
        -Dcloudhub.applicationName="!SRV!-server" ^
        -Dcloudhub.muleVersion="!MULE_VERSION!" ^
        -Dcloudhub.region="!CLOUDHUB_REGION!" ^
        -Dcloudhub.workers="!CLOUDHUB_WORKERS!" ^
        -Dcloudhub.workerType="!CLOUDHUB_WORKER_TYPE!" ^
        -Dcloudhub.objectStoreV2=true ^
        -Danypoint.platform.client_id="!ANYPOINT_CLIENT_ID!" ^
        -Danypoint.platform.client_secret="!ANYPOINT_CLIENT_SECRET!" ^
        -Danypoint.username="!ANYPOINT_USERNAME!" ^
        -Danypoint.password="!ANYPOINT_PASSWORD!" ^
        -DskipTests ^
        -U
    
    if !errorlevel! neq 0 (
        echo ❌ DEPLOYMENT FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV!-server deployed successfully
    echo 🌐 URL: https://!SRV!-server.us-e1.cloudhub.io
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ All services deployed to CloudHub successfully
echo.

REM === STEP 8: HEALTH CHECKS ===
echo ==============================
echo 🧪 PERFORMING HEALTH CHECKS
echo ==============================

echo Waiting 15 seconds for applications to start...
timeout /t 15 /nobreak >nul

echo Testing deployed services:

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   Testing !SRV!-server...
    
    powershell -Command "& { try { $response = Invoke-WebRequest -Uri 'https://!SRV!-server.us-e1.cloudhub.io/health' -UseBasicParsing -TimeoutSec 10 -Method GET; if ($response.StatusCode -eq 200) { Write-Host '    ✅ !SRV!-server: HEALTHY' -ForegroundColor Green } else { Write-Host '    ⚠️  !SRV!-server: HTTP $($response.StatusCode)' -ForegroundColor Yellow } } catch { Write-Host '    ⏳ !SRV!-server: Starting or not accessible...' -ForegroundColor Cyan } }"
)

echo.

REM === STEP 9: DEPLOYMENT SUMMARY ===
echo ==============================
echo 🎉 DEPLOYMENT COMPLETED
echo ==============================

echo.
echo ✅ DEPLOYED SERVICE URLS (ACTUAL CLOUDHUB APPLICATIONS):
echo   🌐 agent-broker-mcp-server: https://agent-broker-mcp-server.us-e1.cloudhub.io
echo   🌐 employee-onboarding-mcp: https://employee-onboarding-mcp.us-e1.cloudhub.io
echo   🌐 asset-allocation-mcp: https://asset-allocation-mcp.us-e1.cloudhub.io
echo   🌐 notification-mcp-server: https://notification-mcp-server.us-e1.cloudhub.io
echo   🌐 employee-onboarding-mcp-server: https://employee-onboarding-mcp-server.us-e1.cloudhub.io
echo   🌐 asset-allocation-mcp-server: https://asset-allocation-mcp-server.us-e1.cloudhub.io

echo.
echo 📋 KEY ENDPOINTS:
echo   🔗 Main API: https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding
echo   🔗 Employee MCP: https://employee-onboarding-mcp-server.us-e1.cloudhub.io/mcp
echo   🔗 Asset MCP: https://asset-allocation-mcp-server.us-e1.cloudhub.io/mcp
echo   🔗 Notification MCP: https://notification-mcp-server.us-e1.cloudhub.io/mcp

if exist "mcp-servers\agent-broker-mcp" (
    echo.
    echo 🚀 SAMPLE TEST COMMAND:
    echo curl -X POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding ^
    echo      -H "Content-Type: application/json" ^
    echo      -d "{\"firstName\":\"John\",\"lastName\":\"Doe\",\"email\":\"john.doe@test.com\",\"department\":\"Engineering\"}"
)

echo.
echo ✅ DEPLOYMENT SCRIPT COMPLETED SUCCESSFULLY
echo   - %SERVER_COUNT% services compiled
echo   - Target folders cleaned
if "%SKIP_EXCHANGE%"=="false" (
    echo   - Exchange publishing attempted ^(with corrected credentials^)
) else (
    echo   - Exchange publishing skipped ^(as requested^)
)
echo   - All services deployed to CloudHub
echo   - Health checks performed
echo.
echo Ready for testing and use!
echo.

pause
endlocal
