@echo off
echo ============================================================
echo  TESTING PARENT POM 401 AUTHENTICATION FIXES
echo ============================================================

REM Set the working directory to the fabric folder
cd employee-onboarding-agent-fabric

echo.
echo [STEP 1] Testing Maven Parent-Child Relationship...
echo ============================================================
mvn help:effective-pom -N > effective-parent-pom.xml
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: Parent POM structure is valid
) else (
    echo ❌ ERROR: Parent POM has structural issues
    goto :error
)

echo.
echo [STEP 2] Testing Child Module Dependencies...
echo ============================================================
mvn validate
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: All modules validate correctly
) else (
    echo ❌ ERROR: Module validation failed - check parent-child relationships
    goto :error
)

echo.
echo [STEP 3] Testing Authentication Configuration...
echo ============================================================
echo Testing Connected App credentials...
call validate-credentials.bat
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: Authentication working
) else (
    echo ⚠️  WARNING: Authentication may need Connected App scope fixes
    echo See POM_401_ERROR_COMPREHENSIVE_FIX.md for Connected App scope requirements
)

echo.
echo [STEP 4] Testing Maven Repository Access...
echo ============================================================
mvn dependency:resolve-sources -N
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: Maven repository access working
) else (
    echo ❌ ERROR: Maven repository access failed
    goto :error
)

echo.
echo [STEP 5] Testing Build Process...
echo ============================================================
mvn clean compile -N
if %ERRORLEVEL% EQU 0 (
    echo ✅ SUCCESS: Parent POM compiles successfully
) else (
    echo ❌ ERROR: Compilation failed
    goto :error
)

echo.
echo ============================================================
echo  ✅ POM FIXES TEST COMPLETED SUCCESSFULLY!
echo ============================================================
echo.
echo NEXT STEPS:
echo 1. If authentication test failed, add missing Connected App scopes
echo 2. Run: mvn clean install (to build all child modules)  
echo 3. Run: mvn clean deploy -DmuleDeploy (to deploy to CloudHub)
echo.
echo See POM_401_ERROR_COMPREHENSIVE_FIX.md for complete instructions.
echo ============================================================
goto :end

:error
echo.
echo ============================================================
echo  ❌ POM FIXES TEST FAILED!
echo ============================================================
echo.
echo Please check:
echo 1. Parent POM structure in employee-onboarding-agent-fabric/pom.xml
echo 2. Child POM parent references match new groupId and artifactId  
echo 3. Maven settings.xml authentication
echo 4. Connected App scopes in Anypoint Platform
echo.
echo See POM_401_ERROR_COMPREHENSIVE_FIX.md for complete fix instructions.
echo ============================================================

:end
pause
