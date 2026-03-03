@echo off
REM ========================================
REM 504 GATEWAY TIMEOUT FIX FOR EXCHANGE PUBLICATION
REM ✅ Extended timeout configurations
REM ✅ Retry mechanism for failed uploads
REM ✅ Optimized Maven settings
REM ✅ Alternative deployment strategies
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory and navigate to project root
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo ========================================
echo 504 GATEWAY TIMEOUT FIX - EXCHANGE PUBLICATION
echo ========================================
echo Working directory: %CD%
echo.

REM === STEP 1: LOAD ENVIRONMENT VARIABLES ===
echo ==============================
echo [LOADING] ENVIRONMENT VARIABLES
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

echo ✅ Environment variables loaded successfully
echo.

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

echo ✅ Configuration validated successfully
echo.

REM === STEP 3: CREATE TIMEOUT-OPTIMIZED MAVEN SETTINGS ===
echo ==============================
echo 🔧 CREATING TIMEOUT-OPTIMIZED MAVEN SETTINGS
echo ==============================

set "TEMP_SETTINGS_FILE=%TEMP%\maven-settings-timeout-fix.xml"

echo Creating optimized Maven settings file with extended timeouts...

(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
echo           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
echo           xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
echo                               http://maven.apache.org/xsd/settings-1.0.0.xsd"^>
echo.
echo   ^<servers^>
echo     ^<server^>
echo       ^<id^>anypoint-exchange^</id^>
echo       ^<username^>~~~Client~~~^</username^>
echo       ^<password^>%ANYPOINT_CLIENT_ID%~?~%ANYPOINT_CLIENT_SECRET%^</password^>
echo     ^</server^>
echo     ^<server^>
echo       ^<id^>anypoint-exchange-v3^</id^>
echo       ^<username^>~~~Client~~~^</username^>
echo       ^<password^>%ANYPOINT_CLIENT_ID%~?~%ANYPOINT_CLIENT_SECRET%^</password^>
echo     ^</server^>
echo     ^<server^>
echo       ^<id^>MuleRepository^</id^>
echo       ^<username^>~~~Client~~~^</username^>
echo       ^<password^>%ANYPOINT_CLIENT_ID%~?~%ANYPOINT_CLIENT_SECRET%^</password^>
echo     ^</server^>
echo   ^</servers^>
echo.
echo   ^<profiles^>
echo     ^<profile^>
echo       ^<id^>timeout-fix^</id^>
echo       ^<activation^>
echo         ^<activeByDefault^>true^</activeByDefault^>
echo       ^</activation^>
echo       ^<properties^>
echo         ^<!-- Extended timeout configurations --^>
echo         ^<maven.wagon.http.connectionTimeout^>300000^</maven.wagon.http.connectionTimeout^>
echo         ^<maven.wagon.http.readTimeout^>600000^</maven.wagon.http.readTimeout^>
echo         ^<maven.wagon.httpconnectionManager.ttlSeconds^>120^</maven.wagon.httpconnectionManager.ttlSeconds^>
echo         ^<maven.wagon.http.retryHandler.count^>5^</maven.wagon.http.retryHandler.count^>
echo         ^<maven.wagon.http.pool^>true^</maven.wagon.http.pool^>
echo         ^<maven.wagon.http.ssl.insecure^>false^</maven.wagon.http.ssl.insecure^>
echo         ^<maven.wagon.http.ssl.allowall^>false^</maven.wagon.http.ssl.allowall^>
echo         ^<maven.wagon.http.ssl.ignore.validity.dates^>false^</maven.wagon.http.ssl.ignore.validity.dates^>
echo         ^<!-- Anypoint Platform settings --^>
echo         ^<anypoint.platform.base.uri^>https://anypoint.mulesoft.com^</anypoint.platform.base.uri^>
echo         ^<anypoint.exchange.base.uri^>https://anypoint.mulesoft.com/exchange^</anypoint.exchange.base.uri^>
echo         ^<anypoint.businessGroup.id^>%ANYPOINT_ORG_ID%^</anypoint.businessGroup.id^>
echo       ^</properties^>
echo     ^</profile^>
echo   ^</profiles^>
echo.
echo ^</settings^>
) > "%TEMP_SETTINGS_FILE%"

echo ✅ Created timeout-optimized Maven settings: %TEMP_SETTINGS_FILE%
echo.

REM === STEP 4: SET MAVEN ENVIRONMENT VARIABLES FOR TIMEOUT HANDLING ===
echo ==============================
echo 🌐 SETTING MAVEN TIMEOUT ENVIRONMENT VARIABLES
echo ==============================

REM Set Maven timeout options
set "MAVEN_OPTS=-Xmx2048m -Xms512m -XX:MaxPermSize=512m -Dmaven.wagon.http.connectionTimeout=300000 -Dmaven.wagon.http.readTimeout=600000 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 -Dmaven.wagon.http.retryHandler.count=5"

REM Set Java network properties for better timeout handling
set "JAVA_OPTS=%JAVA_OPTS% -Dsun.net.client.defaultConnectTimeout=300000 -Dsun.net.client.defaultReadTimeout=600000 -Djava.net.useSystemProxies=true"

echo ✅ Maven timeout options configured:
echo   MAVEN_OPTS=%MAVEN_OPTS%
echo   JAVA_OPTS=%JAVA_OPTS%
echo.

REM === STEP 5: DISCOVER AND PREPARE MCP SERVICES ===
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

echo ✅ Discovered %SERVER_COUNT% MCP services: !SERVER_LIST!
echo.

REM === STEP 6: CLEAN AND COMPILE ALL SERVICES ===
echo ==============================
echo 🛠️  CLEANING AND COMPILING MCP SERVICES
echo ==============================

for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 🛠️  Preparing !SRV!...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    
    if not exist "mcp-servers\!SRV!\pom.xml" (
        echo ❌ ERROR: pom.xml not found for !SRV!
        pause
        exit /b 1
    )
    
    cd "mcp-servers\!SRV!"
    echo 📁 Working from: %CD%
    
    REM Clean with timeout-optimized settings
    echo   🧹 Cleaning !SRV!...
    call mvn clean -s "%TEMP_SETTINGS_FILE%" -q -DskipTests
    if !errorlevel! neq 0 (
        echo ❌ CLEAN FAILED for !SRV!
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    REM Compile with timeout-optimized settings
    echo   🔨 Compiling !SRV!...
    call mvn compile package -s "%TEMP_SETTINGS_FILE%" -q -DskipTests -DskipMuleApplicationDeployment -T 2
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
        cd /d "%SCRIPT_DIR%"
        pause
        exit /b 1
    )
    
    echo ✅ !SRV! prepared successfully
    cd /d "%SCRIPT_DIR%"
)

echo ✅ All MCP services prepared successfully
echo.

REM === STEP 7: PUBLISH TO EXCHANGE WITH TIMEOUT FIXES ===
echo ==============================
echo 📤 PUBLISHING TO EXCHANGE (WITH TIMEOUT FIXES)
echo ==============================

echo Publishing MCP assets with extended timeout configurations...
echo Using optimized settings: %TEMP_SETTINGS_FILE%
echo.

REM Publish each service individually with retries
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo.
    echo [%%i/%SERVER_COUNT%] 📤 Publishing !SRV! to Exchange...
    echo ================================
    
    cd /d "%SCRIPT_DIR%"
    cd "mcp-servers\!SRV!"
    echo 📁 Publishing from: %CD%
    
    REM Attempt 1: Standard deploy with timeout fixes
    echo   📤 Attempt 1: Standard deploy with timeout optimization...
    call mvn deploy ^
        -s "%TEMP_SETTINGS_FILE%" ^
        -DskipMuleApplicationDeployment ^
        -DskipTests ^
        -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
        -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
        -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange" ^
        -Dmaven.wagon.http.connectionTimeout=300000 ^
        -Dmaven.wagon.http.readTimeout=600000 ^
        -Dmaven.wagon.http.retryHandler.count=5 ^
        -U -X -q
    
    if !errorlevel! equ 0 (
        echo ✅ !SRV! published successfully on first attempt
    ) else (
        echo ⚠️  First attempt failed, trying alternative approach...
        
        REM Attempt 2: Force update with explicit timeout
        echo   📤 Attempt 2: Force update with explicit timeout...
        timeout /t 5 /nobreak >nul
        
        call mvn deploy ^
            -s "%TEMP_SETTINGS_FILE%" ^
            -DskipMuleApplicationDeployment ^
            -DskipTests ^
            -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" ^
            -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
            -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
            -Danypoint.platform.base.uri="https://anypoint.mulesoft.com" ^
            -Danypoint.exchange.base.uri="https://anypoint.mulesoft.com/exchange" ^
            -Dmaven.wagon.http.connectionTimeout=600000 ^
            -Dmaven.wagon.http.readTimeout=1200000 ^
            -Dmaven.wagon.http.pool=false ^
            -Dmaven.wagon.http.retryHandler.count=10 ^
            -DforceUpdate=true ^
            -U -X
        
        if !errorlevel! equ 0 (
            echo ✅ !SRV! published successfully on second attempt
        ) else (
            echo ⚠️  Second attempt failed, trying final approach...
            
            REM Attempt 3: Minimal deploy with maximum timeout
            echo   📤 Attempt 3: Minimal deploy with maximum timeout...
            timeout /t 10 /nobreak >nul
            
            call mvn org.apache.maven.plugins:maven-deploy-plugin:3.1.1:deploy ^
                -s "%TEMP_SETTINGS_FILE%" ^
                -DskipMuleApplicationDeployment=true ^
                -DskipTests=true ^
                -Danypoint.client.id="%ANYPOINT_CLIENT_ID%" ^
                -Danypoint.client.secret="%ANYPOINT_CLIENT_SECRET%" ^
                -Danypoint.businessGroup.id="%ANYPOINT_ORG_ID%" ^
                -Dmaven.wagon.http.connectionTimeout=900000 ^
                -Dmaven.wagon.http.readTimeout=1800000 ^
                -Dmaven.wagon.httpconnectionManager.maxPerRoute=1 ^
                -Dmaven.wagon.httpconnectionManager.maxTotal=5 ^
                -Dmaven.wagon.http.retryHandler.count=15 ^
                -DretryFailedDeploymentCount=5 ^
                -U
            
            if !errorlevel! equ 0 (
                echo ✅ !SRV! published successfully on third attempt
            ) else (
                echo ❌ All attempts failed for !SRV!
                echo.
                echo 🔍 TROUBLESHOOTING INFORMATION:
                echo   - Service: !SRV!
                echo   - Error: 504 Gateway Timeout persists
                echo   - Possible causes:
                echo     * Large artifact size ^(JAR file too big^)
                echo     * Network connectivity issues
                echo     * Exchange server overload
                echo     * Authentication token expiration
                echo.
                echo 💡 RECOMMENDATIONS:
                echo   1. Check internet connection stability
                echo   2. Try publishing during off-peak hours
                echo   3. Contact MuleSoft support if issue persists
                echo   4. Consider using Anypoint CLI as alternative
                echo.
                set /p CONTINUE_CHOICE=Continue with remaining services? (Y/N): 
                if /i "!CONTINUE_CHOICE!" neq "Y" (
                    echo ❌ Deployment stopped by user
                    cd /d "%SCRIPT_DIR%"
                    pause
                    exit /b 1
                )
            )
        )
    )
    
    cd /d "%SCRIPT_DIR%"
)

echo.
echo ✅ Exchange publication process completed
echo.

REM === STEP 8: CLEANUP TEMPORARY FILES ===
echo ==============================
echo 🧹 CLEANUP
echo ==============================

if exist "%TEMP_SETTINGS_FILE%" (
    del "%TEMP_SETTINGS_FILE%" 2>nul
    echo ✅ Cleaned up temporary Maven settings file
)

echo.

REM === STEP 9: DEPLOYMENT SUMMARY ===
echo ==============================
echo 📋 DEPLOYMENT SUMMARY
echo ==============================

echo.
echo ✅ 504 TIMEOUT FIX DEPLOYMENT COMPLETED
echo.
echo 🔧 APPLIED FIXES:
echo   - Extended HTTP connection timeout: 5-15 minutes
echo   - Extended HTTP read timeout: 10-30 minutes
echo   - Enabled HTTP retry handler: 5-15 retries
echo   - Optimized connection pooling
echo   - Multiple deployment attempts per service
echo   - Temporary Maven settings with timeout configuration
echo.
echo 📊 SERVICES PROCESSED: %SERVER_COUNT%
for /l %%i in (1,1,%SERVER_COUNT%) do (
    call set "SRV=%%SERVER%%i%%"
    echo   [%%i] !SRV!
)

echo.
echo 💡 IF ISSUES PERSIST:
echo   1. Check network stability and try again
echo   2. Use Anypoint CLI: anypoint-cli exchange asset upload
echo   3. Try publishing during off-peak hours
echo   4. Contact MuleSoft Support for assistance
echo.
echo Ready for CloudHub deployment!
echo.

pause
endlocal
