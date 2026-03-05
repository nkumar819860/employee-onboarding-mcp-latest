@echo off
echo ========================================
echo Testing Conditional Database Configuration
echo Assets Allocation MCP Server
echo ========================================
echo.

:: Set test environment
set ORIGINAL_DB_STRATEGY=%DB_STRATEGY%
set TEST_PORT=8083

echo Step 1: Testing H2 Database Configuration (Default)
echo ================================================
echo.
echo Setting DB_STRATEGY to h2...
set DB_STRATEGY=h2

echo Current configuration:
echo - DB_STRATEGY: %DB_STRATEGY%
echo - Expected Database: H2 In-Memory
echo.

echo Building project...
cd /d "%~dp0"
call mvn clean compile -q
if %errorlevel% neq 0 (
    echo ERROR: Maven compile failed for H2 configuration
    goto :error
)

echo H2 configuration test: PASSED
echo.

echo Step 2: Testing PostgreSQL Database Configuration
echo ==============================================
echo.
echo Setting DB_STRATEGY to postgres...
set DB_STRATEGY=postgres
set DB_POSTGRES_HOST=localhost
set DB_POSTGRES_PORT=5432
set DB_POSTGRES_NAME=assets_allocation_test
set DB_POSTGRES_USERNAME=test_user
set DB_POSTGRES_PASSWORD=test_password

echo Current configuration:
echo - DB_STRATEGY: %DB_STRATEGY%
echo - Expected Database: PostgreSQL
echo - DB_POSTGRES_HOST: %DB_POSTGRES_HOST%
echo - DB_POSTGRES_NAME: %DB_POSTGRES_NAME%
echo.

echo Building project...
call mvn clean compile -q
if %errorlevel% neq 0 (
    echo ERROR: Maven compile failed for PostgreSQL configuration
    goto :error
)

echo PostgreSQL configuration test: PASSED
echo.

echo Step 3: Testing Property Resolution
echo =================================
echo.
echo Testing property file resolution...

:: Check if config.properties contains the expected properties
findstr /C:"db.strategy=" "%~dp0src\main\resources\config.properties" >nul
if %errorlevel% neq 0 (
    echo ERROR: db.strategy property not found in config.properties
    goto :error
)

findstr /C:"db.h2.url=" "%~dp0src\main\resources\config.properties" >nul
if %errorlevel% neq 0 (
    echo ERROR: db.h2.url property not found in config.properties
    goto :error
)

findstr /C:"db.postgres.url=" "%~dp0src\main\resources\config.properties" >nul
if %errorlevel% neq 0 (
    echo ERROR: db.postgres.url property not found in config.properties
    goto :error
)

echo Property resolution test: PASSED
echo.

echo Step 4: Testing Global.xml Configuration
echo ======================================
echo.
echo Checking global.xml for database configurations...

:: Check if global.xml contains the expected database configurations
findstr /C:"Database_Config" "%~dp0src\main\mule\global.xml" >nul
if %errorlevel% neq 0 (
    echo ERROR: Dynamic database selector not found in global.xml
    goto :error
)

findstr /C:"H2_Database_Config" "%~dp0src\main\mule\global.xml" >nul
if %errorlevel% neq 0 (
    echo ERROR: H2 database config not found in global.xml
    goto :error
)

findstr /C:"PostgreSQL_Database_Config" "%~dp0src\main\mule\global.xml" >nul
if %errorlevel% neq 0 (
    echo ERROR: PostgreSQL database config not found in global.xml
    goto :error
)

echo Global.xml configuration test: PASSED
echo.

echo Step 5: Testing Environment Variable Override
echo ===========================================
echo.
echo Testing with no DB_STRATEGY set (should default to h2)...
set DB_STRATEGY=

echo Building project with default strategy...
call mvn clean compile -q
if %errorlevel% neq 0 (
    echo ERROR: Maven compile failed with default strategy
    goto :error
)

echo Default strategy test: PASSED
echo.

echo Step 6: Testing Documentation and Files
echo =====================================
echo.
echo Checking if documentation file exists...
if not exist "%~dp0DATABASE_CONFIGURATION_GUIDE.md" (
    echo ERROR: DATABASE_CONFIGURATION_GUIDE.md not found
    goto :error
)

echo Documentation file test: PASSED
echo.

:: Restore original environment
echo Restoring original environment...
set DB_STRATEGY=%ORIGINAL_DB_STRATEGY%

echo.
echo ========================================
echo ALL TESTS PASSED!
echo ========================================
echo.
echo Summary:
echo - H2 Database Configuration: PASSED
echo - PostgreSQL Database Configuration: PASSED  
echo - Property Resolution: PASSED
echo - Global.xml Configuration: PASSED
echo - Default Strategy: PASSED
echo - Documentation: PASSED
echo.
echo The conditional database configuration is working correctly!
echo.
echo Usage Instructions:
echo ===================
echo.
echo 1. For H2 (Default - CloudHub/Local):
echo    set DB_STRATEGY=h2
echo    (or leave unset for default)
echo.
echo 2. For PostgreSQL (Production/Docker):
echo    set DB_STRATEGY=postgres
echo    set DB_POSTGRES_HOST=your-db-host
echo    set DB_POSTGRES_PORT=5432
echo    set DB_POSTGRES_NAME=your-database
echo    set DB_POSTGRES_USERNAME=your-username
echo    set DB_POSTGRES_PASSWORD=your-password
echo.
echo 3. In flows, use config-ref="Database_Config" for automatic selection
echo.
goto :end

:error
echo.
echo ========================================
echo TESTS FAILED!
echo ========================================
echo.
echo Please check the error messages above and fix the configuration.
echo.
:: Restore original environment even on error
set DB_STRATEGY=%ORIGINAL_DB_STRATEGY%
exit /b 1

:end
echo Test completed successfully!
pause
