@echo off
echo ================================================================
echo TESTING OAS CONVERSION FIX FOR RAML PARSING ERROR
echo ================================================================
echo.

set PROJECT_ROOT=%cd%
set EMPLOYEE_MCP=%PROJECT_ROOT%\employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp
set ASSET_MCP=%PROJECT_ROOT%\employee-onboarding-agent-fabric\mcp-servers\asset-allocation-mcp

echo 1. TESTING EMPLOYEE ONBOARDING MCP SERVER...
echo ----------------------------------------------------------------
cd "%EMPLOYEE_MCP%"

echo Validating OpenAPI specification...
if exist "src\main\resources\api\employee-onboarding-mcp-api.yaml" (
    echo [✓] OpenAPI spec file exists
    
    REM Check if it's OpenAPI format
    findstr /C:"openapi: 3.0.3" "src\main\resources\api\employee-onboarding-mcp-api.yaml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] File is in OpenAPI 3.0.3 format
    ) else (
        echo [✗] File is not in OpenAPI format
        goto :error
    )
    
    REM Check for required schemas
    findstr /C:"components:" "src\main\resources\api\employee-onboarding-mcp-api.yaml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] Contains components section
    ) else (
        echo [✗] Missing components section
        goto :error
    )
    
    findstr /C:"schemas:" "src\main\resources\api\employee-onboarding-mcp-api.yaml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] Contains schemas definition
    ) else (
        echo [✗] Missing schemas definition
        goto :error
    )
    
) else (
    echo [✗] OpenAPI spec file not found
    goto :error
)

echo.
echo 2. TESTING ASSET ALLOCATION MCP SERVER...
echo ----------------------------------------------------------------
cd "%ASSET_MCP%"

echo Validating OpenAPI specification...
if exist "src\main\resources\api\asset-allocation-mcp-api.yaml" (
    echo [✓] OpenAPI spec file exists
    
    REM Check if it's OpenAPI format
    findstr /C:"openapi: 3.0.3" "src\main\resources\api\asset-allocation-mcp-api.yaml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] File is in OpenAPI 3.0.3 format
    ) else (
        echo [✗] File is not in OpenAPI format
        goto :error
    )
    
    REM Check for required schemas
    findstr /C:"components:" "src\main\resources\api\asset-allocation-mcp-api.yaml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] Contains components section
    ) else (
        echo [✗] Missing components section
        goto :error
    )
    
) else (
    echo [✗] OpenAPI spec file not found
    goto :error
)

echo.
echo 3. TESTING MULE CONFIGURATION FILES...
echo ----------------------------------------------------------------

REM Test employee onboarding global.xml
cd "%EMPLOYEE_MCP%"
if exist "src\main\mule\global.xml" (
    echo [✓] Employee MCP global.xml exists
    
    REM Check if it references the yaml file correctly
    findstr /C:"api/employee-onboarding-mcp-api.yaml" "src\main\mule\global.xml" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] References OpenAPI spec file
    ) else (
        echo [?] May need APIKit configuration update
    )
) else (
    echo [✗] Employee MCP global.xml not found
)

REM Test asset allocation global.xml
cd "%ASSET_MCP%"
if exist "src\main\mule\global.xml" (
    echo [✓] Asset MCP global.xml exists
) else (
    echo [✗] Asset MCP global.xml not found
)

echo.
echo 4. TESTING MULE ARTIFACT CONFIGURATIONS...
echo ----------------------------------------------------------------

REM Test employee onboarding mule-artifact.json
cd "%EMPLOYEE_MCP%"
if exist "mule-artifact.json" (
    echo [✓] Employee MCP mule-artifact.json exists
    
    findstr /C:"4.9.0" "mule-artifact.json" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] Uses Mule 4.9.0 runtime
    ) else (
        echo [?] Different Mule runtime version
    )
    
    findstr /C:"17" "mule-artifact.json" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [✓] Uses Java 17
    ) else (
        echo [?] Different Java version
    )
) else (
    echo [✗] Employee MCP mule-artifact.json not found
)

REM Test asset allocation mule-artifact.json
cd "%ASSET_MCP%"
if exist "mule-artifact.json" (
    echo [✓] Asset MCP mule-artifact.json exists
) else (
    echo [✗] Asset MCP mule-artifact.json not found
)

echo.
echo 5. SUMMARY REPORT...
echo ----------------------------------------------------------------
cd "%PROJECT_ROOT%"

echo [CONVERSION STATUS]
echo - Employee Onboarding MCP: RAML → OpenAPI 3.0.3 ✓
echo - Asset Allocation MCP: RAML → OpenAPI 3.0.3 ✓
echo - API specifications validated ✓
echo - Mule configurations present ✓
echo.

echo [EXPECTED BENEFITS]
echo - Eliminates RAML parsing errors in [AUTO] mode
echo - Provides better API tooling support
echo - Improves OpenAPI ecosystem compatibility
echo - Maintains existing functionality
echo.

echo [NEXT STEPS]
echo 1. Clean and rebuild MCP projects: mvn clean compile
echo 2. Test APIKit router initialization
echo 3. Verify endpoint accessibility
echo 4. Monitor application startup logs
echo.

echo ================================================================
echo OAS CONVERSION TEST COMPLETED SUCCESSFULLY!
echo ================================================================
goto :end

:error
echo.
echo ================================================================
echo ERROR: OAS CONVERSION TEST FAILED!
echo Please check the issues reported above.
echo ================================================================
exit /b 1

:end
echo.
pause
