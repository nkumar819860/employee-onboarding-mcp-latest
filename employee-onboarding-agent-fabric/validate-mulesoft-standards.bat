@echo off
REM ========================================
REM MULESOFT STANDARDS VALIDATION SCRIPT
REM Validates compliance with MuleSoft standards for:
REM - Exchange Publication
REM - CloudHub Deployment
REM - Asset Classification
REM - POM Configuration
REM ========================================

setlocal enabledelayedexpansion

echo ========================================
echo MULESOFT STANDARDS VALIDATION
echo ========================================
echo.

set VALIDATION_ERRORS=0
set VALIDATION_WARNINGS=0

REM === STEP 1: VALIDATE EXCHANGE.JSON COMPLIANCE ===
echo ==============================
echo 📋 VALIDATING EXCHANGE.JSON COMPLIANCE
echo ==============================

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\exchange.json" (
        echo Validating %%d\exchange.json...
        
        REM Check for required MuleSoft Exchange fields
        findstr /C:"\"classifier\"" "%%d\exchange.json" >nul
        if !errorlevel! neq 0 (
            echo   ❌ ERROR: Missing classifier field in %%d
            set /a VALIDATION_ERRORS+=1
        )
        
        findstr /C:"\"groupId\"" "%%d\exchange.json" >nul
        if !errorlevel! neq 0 (
            echo   ❌ ERROR: Missing groupId field in %%d
            set /a VALIDATION_ERRORS+=1
        )
        
        findstr /C:"\"assetId\"" "%%d\exchange.json" >nul
        if !errorlevel! neq 0 (
            echo   ❌ ERROR: Missing assetId field in %%d
            set /a VALIDATION_ERRORS+=1
        )
        
        REM Validate version format (semantic versioning)
        for /f "tokens=2 delims=: " %%v in ('findstr /C:"version" "%%d\exchange.json"') do (
            set "VERSION=%%v"
            set "VERSION=!VERSION:"=!"
            set "VERSION=!VERSION:,=!"
            set "VERSION=!VERSION: =!"
            echo !VERSION! | findstr /R "^[0-9]*\.[0-9]*\.[0-9]*$" >nul
            if !errorlevel! neq 0 (
                echo   ❌ ERROR: Invalid semantic version format in %%d: !VERSION!
                set /a VALIDATION_ERRORS+=1
            ) else (
                echo   ✅ Valid version format: !VERSION!
            )
        )
        
        REM Check for MCP classifier specifically
        findstr /C:"\"classifier\":\s*\"mcp\"" "%%d\exchange.json" >nul
        if !errorlevel! equ 0 (
            echo   ✅ MCP classifier found
        ) else (
            echo   ⚠️  WARNING: MCP classifier may not be properly set in %%d
            set /a VALIDATION_WARNINGS+=1
        )
        
        echo.
    ) else (
        echo   ❌ ERROR: exchange.json not found in %%d
        set /a VALIDATION_ERRORS+=1
    )
)

REM Check parent exchange.json
if exist "exchange.json" (
    echo Validating parent exchange.json...
    
    REM Validate parent has correct classifier
    findstr /C:"\"classifier\":\s*\"mcp\"" "exchange.json" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Parent MCP classifier found
    ) else (
        echo   ❌ ERROR: Parent MCP classifier not found
        set /a VALIDATION_ERRORS+=1
    )
    
    REM Check for API specification reference
    findstr /C:"apiSpecification" "exchange.json" >nul
    if !errorlevel! equ 0 (
        echo   ✅ API specification reference found
    ) else (
        echo   ⚠️  WARNING: API specification reference missing from parent
        set /a VALIDATION_WARNINGS+=1
    )
) else (
    echo   ❌ ERROR: Parent exchange.json not found
    set /a VALIDATION_ERRORS+=1
)

echo.

REM === STEP 2: VALIDATE POM.XML MULESOFT STANDARDS ===
echo ==============================
echo 🏗️  VALIDATING POM.XML STANDARDS
echo ==============================

REM Check parent POM
if exist "pom.xml" (
    echo Validating parent pom.xml...
    
    REM Check for Mule BOM import
    findstr /C:"mule-runtime-impl-bom" "pom.xml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Mule BOM import found
    ) else (
        echo   ❌ ERROR: Mule BOM import missing from parent POM
        set /a VALIDATION_ERRORS+=1
    )
    
    REM Check for proper Java version (17)
    findstr /C:"<java.version>17</java.version>" "pom.xml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Java 17 configuration found
    ) else (
        echo   ⚠️  WARNING: Java 17 version may not be properly configured
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for Mule version 4.9+ (Java 17 compatible)
    findstr /C:"<mule.version>4.9" "pom.xml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Mule 4.9+ version found (Java 17 compatible)
    ) else (
        echo   ⚠️  WARNING: Mule version may not be Java 17 compatible
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for proper group ID format
    findstr /C:"<groupId>47562e5d-bf49-440a-a0f5-a9cea0a89aa9</groupId>" "pom.xml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Business Group ID format is valid
    ) else (
        echo   ⚠️  WARNING: Group ID may not follow MuleSoft business group format
        set /a VALIDATION_WARNINGS+=1
    )
) else (
    echo   ❌ ERROR: Parent pom.xml not found
    set /a VALIDATION_ERRORS+=1
)

REM Check child POMs
for /d %%d in (mcp-servers\*) do (
    if exist "%%d\pom.xml" (
        echo Validating %%d\pom.xml...
        
        REM Check for Mule Maven Plugin
        findstr /C:"mule-maven-plugin" "%%d\pom.xml" >nul
        if !errorlevel! equ 0 (
            echo   ✅ Mule Maven Plugin found in %%d
        ) else (
            echo   ❌ ERROR: Mule Maven Plugin missing in %%d
            set /a VALIDATION_ERRORS+=1
        )
        
        REM Check for Exchange Maven Plugin (optional but recommended)
        findstr /C:"exchange-mule-maven-plugin" "%%d\pom.xml" >nul
        if !errorlevel! equ 0 (
            echo   ✅ Exchange Maven Plugin found in %%d
        ) else (
            echo   ⚠️  INFO: Exchange Maven Plugin not found in %%d (optional)
        )
        
        REM Check for parent reference
        findstr /C:"<parent>" "%%d\pom.xml" >nul
        if !errorlevel! equ 0 (
            echo   ✅ Parent reference found in %%d
        ) else (
            echo   ⚠️  WARNING: Parent reference missing in %%d
            set /a VALIDATION_WARNINGS+=1
        )
        
        echo.
    )
)

echo.

REM === STEP 3: VALIDATE MULE ARTIFACT DESCRIPTORS ===
echo ==============================
echo 📦 VALIDATING MULE ARTIFACT DESCRIPTORS
echo ==============================

for /d %%d in (mcp-servers\*) do (
    if exist "%%d\mule-artifact.json" (
        echo Validating %%d\mule-artifact.json...
        
        REM Check for minimum Mule version
        findstr /C:"minMuleVersion" "%%d\mule-artifact.json" >nul
        if !errorlevel! equ 0 (
            echo   ✅ MinMuleVersion specified in %%d
        ) else (
            echo   ⚠️  WARNING: MinMuleVersion not specified in %%d
            set /a VALIDATION_WARNINGS+=1
        )
        
        REM Check for required JDK version
        findstr /C:"17" "%%d\mule-artifact.json" >nul
        if !errorlevel! equ 0 (
            echo   ✅ Java 17 compatible configuration in %%d
        ) else (
            echo   ⚠️  INFO: Java version compatibility not explicit in %%d
        )
        
        echo.
    ) else (
        echo   ❌ ERROR: mule-artifact.json not found in %%d
        set /a VALIDATION_ERRORS+=1
    )
)

echo.

REM === STEP 4: VALIDATE CLOUDHUB DEPLOYMENT STANDARDS ===
echo ==============================
echo ☁️  VALIDATING CLOUDHUB DEPLOYMENT STANDARDS
echo ==============================

REM Check deployment script for CloudHub best practices
if exist "deploy.bat" (
    echo Validating deploy.bat CloudHub configuration...
    
    REM Check for proper Mule version format
    findstr /C:"4.9" "deploy.bat" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Mule 4.9+ version specified for CloudHub
    ) else (
        echo   ⚠️  WARNING: CloudHub Mule version may not be optimal
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for Java 17 runtime specification
    findstr /C:"java17" "deploy.bat" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Java 17 runtime specified for CloudHub
    ) else (
        echo   ⚠️  WARNING: Java 17 runtime may not be specified
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for proper worker configuration
    findstr /C:"CLOUDHUB_WORKER_TYPE" "deploy.bat" >nul
    if !errorlevel! equ 0 (
        echo   ✅ CloudHub worker type configuration found
    ) else (
        echo   ⚠️  WARNING: CloudHub worker type may not be configured
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for proper region configuration
    findstr /C:"CLOUDHUB_REGION" "deploy.bat" >nul
    if !errorlevel! equ 0 (
        echo   ✅ CloudHub region configuration found
    ) else (
        echo   ⚠️  WARNING: CloudHub region may not be configured
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for Object Store V2 (CloudHub best practice)
    findstr /C:"objectStoreV2=true" "deploy.bat" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Object Store V2 enabled (CloudHub best practice)
    ) else (
        echo   ⚠️  WARNING: Object Store V2 not explicitly enabled
        set /a VALIDATION_WARNINGS+=1
    )
    
) else (
    echo   ❌ ERROR: deploy.bat not found
    set /a VALIDATION_ERRORS+=1
)

echo.

REM === STEP 5: VALIDATE API SPECIFICATIONS ===
echo ==============================
echo 📄 VALIDATING API SPECIFICATIONS
echo ==============================

if exist "src\main\resources\api\employee-onboarding-agent-fabric-api.yaml" (
    echo Validating OpenAPI specification...
    
    REM Check for OpenAPI version
    findstr /C:"openapi: 3.0" "src\main\resources\api\employee-onboarding-agent-fabric-api.yaml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ OpenAPI 3.0+ specification found
    ) else (
        echo   ⚠️  WARNING: OpenAPI version may not be optimal
        set /a VALIDATION_WARNINGS+=1
    )
    
    REM Check for MCP classifier in API
    findstr /C:"x-mcp-classifier" "src\main\resources\api\employee-onboarding-agent-fabric-api.yaml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ MCP classifier extension found in API spec
    ) else (
        echo   ⚠️  INFO: MCP classifier extension not found in API spec
    )
    
    REM Check for security schemes
    findstr /C:"securitySchemes" "src\main\resources\api\employee-onboarding-agent-fabric-api.yaml" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Security schemes defined in API spec
    ) else (
        echo   ⚠️  WARNING: Security schemes may not be defined
        set /a VALIDATION_WARNINGS+=1
    )
    
) else (
    echo   ⚠️  INFO: OpenAPI specification not found (optional for parent POM)
)

echo.

REM === STEP 6: VALIDATE ENVIRONMENT CONFIGURATION ===
echo ==============================
echo 🔧 VALIDATING ENVIRONMENT CONFIGURATION
echo ==============================

if exist ".env" (
    echo Validating .env configuration...
    
    REM Check for required Anypoint Platform credentials
    findstr /C:"ANYPOINT_CLIENT_ID" ".env" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Anypoint Client ID configured
    ) else (
        echo   ❌ ERROR: ANYPOINT_CLIENT_ID not found in .env
        set /a VALIDATION_ERRORS+=1
    )
    
    findstr /C:"ANYPOINT_CLIENT_SECRET" ".env" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Anypoint Client Secret configured
    ) else (
        echo   ❌ ERROR: ANYPOINT_CLIENT_SECRET not found in .env
        set /a VALIDATION_ERRORS+=1
    )
    
    findstr /C:"ANYPOINT_ORG_ID" ".env" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Anypoint Organization ID configured
    ) else (
        echo   ❌ ERROR: ANYPOINT_ORG_ID not found in .env
        set /a VALIDATION_ERRORS+=1
    )
    
    REM Check for recommended environment
    findstr /C:"ANYPOINT_ENV=Sandbox" ".env" >nul
    if !errorlevel! equ 0 (
        echo   ✅ Sandbox environment configured (recommended for testing)
    ) else (
        echo   ⚠️  INFO: Environment configuration may vary (check if intentional)
    )
    
) else (
    echo   ❌ ERROR: .env file not found
    set /a VALIDATION_ERRORS+=1
)

echo.

REM === VALIDATION SUMMARY ===
echo ==============================
echo 📊 MULESOFT STANDARDS VALIDATION SUMMARY
echo ==============================

echo.
echo RESULTS:
echo   🔴 Errors: %VALIDATION_ERRORS%
echo   🟡 Warnings: %VALIDATION_WARNINGS%
echo.

if %VALIDATION_ERRORS% EQU 0 (
    if %VALIDATION_WARNINGS% EQU 0 (
        echo ✅ ALL MULESOFT STANDARDS VALIDATED SUCCESSFULLY
        echo.
        echo 🎉 Your project fully complies with MuleSoft standards for:
        echo   - Anypoint Exchange publication
        echo   - CloudHub deployment
        echo   - MCP asset classification
        echo   - Maven configuration
        echo   - API specifications
        echo.
        echo Ready for production deployment to Anypoint Platform!
    ) else (
        echo ⚠️  VALIDATION PASSED WITH WARNINGS
        echo.
        echo ✅ No critical errors found
        echo ⚠️  %VALIDATION_WARNINGS% warnings detected - review recommended
        echo.
        echo Your project meets MuleSoft standards but could benefit from addressing warnings.
    )
) else (
    echo ❌ VALIDATION FAILED
    echo.
    echo ❌ %VALIDATION_ERRORS% critical errors must be fixed before deployment
    echo ⚠️  %VALIDATION_WARNINGS% warnings should also be reviewed
    echo.
    echo Please address the errors above before deploying to Anypoint Platform.
)

echo.
echo ==============================
echo MULESOFT STANDARDS COMPLIANCE RECOMMENDATIONS:
echo ==============================
echo.
echo 📋 EXCHANGE PUBLICATION:
echo   - Use semantic versioning (x.y.z)
echo   - Include proper MCP classifier
echo   - Provide comprehensive documentation
echo   - Include API specifications where applicable
echo.
echo ☁️  CLOUDHUB DEPLOYMENT:
echo   - Use Mule 4.9+ with Java 17 for latest features
echo   - Enable Object Store V2 for better performance
echo   - Configure appropriate worker types and regions
echo   - Use Connected App authentication
echo.
echo 🏗️  MAVEN CONFIGURATION:
echo   - Import Mule BOM for version consistency
echo   - Use business group ID as Maven groupId
echo   - Include Mule Maven Plugin in all applications
echo   - Define proper parent-child relationships
echo.
echo 🔒 SECURITY:
echo   - Use Connected App OAuth 2.0 authentication
echo   - Store sensitive credentials in secure properties
echo   - Enable audit logging for compliance
echo   - Validate all input parameters
echo.

pause
endlocal
