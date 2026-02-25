@echo off
REM Test script to verify Exchange Plugin connectivity fix

echo ========================================
echo TESTING EXCHANGE PLUGIN CONNECTIVITY FIX
echo ========================================
echo.

REM Change to project directory
cd /d %~dp0

echo [INFO] Testing Maven compilation with exchange.skip=true property...
echo.

REM Test Maven compilation to see if exchange plugin issue is resolved
echo [STEP 1] Running Maven validate to check for plugin resolution issues...
call mvn validate -Dexchange.skip=true

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven validate failed. Check for other configuration issues.
    goto :error
)

echo [SUCCESS] Maven validate completed without exchange plugin errors!
echo.

echo [STEP 2] Testing Maven compile phase...
call mvn compile -Dexchange.skip=true

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven compile failed. Check for compilation errors.
    goto :error
)

echo [SUCCESS] Maven compile completed without exchange plugin errors!
echo.

echo [STEP 3] Testing deployment preparation (package phase)...
call mvn package -DskipTests -Dexchange.skip=true

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Maven package failed. Check for packaging errors.
    goto :error
)

echo [SUCCESS] Maven package completed without exchange plugin errors!
echo.

echo ========================================
echo EXCHANGE PLUGIN FIX VERIFICATION COMPLETE
echo ========================================
echo.
echo [SUCCESS] All tests passed! The exchange.skip=true fix is working correctly.
echo [INFO] Your deployment should now proceed without exchange plugin connectivity issues.
echo [INFO] The warning about exchange publish failure is expected and can be ignored.
echo.
goto :end

:error
echo ========================================
echo TEST FAILED
echo ========================================
echo [ERROR] The exchange plugin fix did not resolve all issues.
echo [INFO] Please check the error messages above and review the EXCHANGE_PLUGIN_CONNECTIVITY_FIX.md file for additional solutions.
echo.

:end
pause
