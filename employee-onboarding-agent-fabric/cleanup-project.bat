@echo off
echo =====================================================
echo Employee Onboarding Agent Fabric - Project Cleanup
echo =====================================================
echo.
echo This script will remove unnecessary files for agent-fabric optimization.
echo Please review CLEANUP_OPTIMIZATION_GUIDE.md before proceeding.
echo.
pause

echo.
echo Phase 1: Removing traditional MuleSoft structure...
echo ===================================================

REM Remove empty .mule directory
if exist ".mule" (
    echo Removing .mule directory...
    rmdir /s /q ".mule"
    echo ✅ Removed .mule directory
) else (
    echo ℹ️  .mule directory not found
)

REM Remove traditional Mule API structure
if exist "src" (
    echo Removing traditional src directory...
    rmdir /s /q "src"
    echo ✅ Removed src directory
) else (
    echo ℹ️  src directory not found
)

REM Remove alternative POM
if exist "pom-standalone.xml" (
    echo Removing pom-standalone.xml...
    del "pom-standalone.xml"
    echo ✅ Removed pom-standalone.xml
) else (
    echo ℹ️  pom-standalone.xml not found
)

echo.
echo Phase 2: Removing deployment fix scripts...
echo ===========================================

REM List of deployment fix scripts to remove
set "scripts_to_remove=fix-and-redeploy.bat fix-mule-versions.bat final-fix.bat update-mule-versions.bat update-to-stable-version.bat build-and-deploy-workaround.bat deploy-with-credentials.bat debug-401-error.bat deploy-individual-services.bat deploy-to-cloudhub.bat debug-env-loading.bat validate-credentials.bat validate-credentials-fixed.bat quick-deploy.bat deploy-with-cli.bat test-pom-fixes.bat"

for %%f in (%scripts_to_remove%) do (
    if exist "%%f" (
        echo Removing %%f...
        del "%%f"
        echo ✅ Removed %%f
    )
)

echo.
echo Phase 3: Removing test and debug scripts...
echo ===========================================

REM Remove test scripts (keep essential ones)
for %%f in (test-docker-deployment.sh test-docker-deployment.bat test-e2e-deployment.bat test-credentials-with-curl.bat test-agent-broker-endpoint.bat) do (
    if exist "%%f" (
        echo Removing %%f...
        del "%%f"
        echo ✅ Removed %%f
    )
)

echo.
echo Phase 4: Removing fix documentation...
echo ======================================

REM List of fix documentation files to remove
set "docs_to_remove=CLOUDHUB_CONFIGURATION_FIX.md DEPLOYMENT_ISSUE_RESOLUTION.md CREDENTIAL_VALIDATION_FIXES.md DEPLOYMENT_SCRIPT_FIXES.md CONNECTED_APP_SETUP_GUIDE.md CONNECTED_APP_422_FIX_GUIDE.md POSTMAN_COLLECTION_FIXES_SUMMARY.md"

for %%f in (%docs_to_remove%) do (
    if exist "%%f" (
        echo Removing %%f...
        del "%%f"
        echo ✅ Removed %%f
    )
)

echo.
echo Phase 5: Removing alternative configurations...
echo ===============================================

REM Remove alternative POM configurations in MCP servers
if exist "mcp-servers\notification-mcp\pom-cloudhub.xml" (
    echo Removing notification-mcp alternative POM...
    del "mcp-servers\notification-mcp\pom-cloudhub.xml"
    echo ✅ Removed pom-cloudhub.xml
)

if exist "mcp-servers\notification-mcp\mule-artifact-cloudhub.json" (
    echo Removing notification-mcp alternative mule-artifact...
    del "mcp-servers\notification-mcp\mule-artifact-cloudhub.json"
    echo ✅ Removed mule-artifact-cloudhub.json
)

echo.
echo =====================================================
echo Cleanup Complete!
echo =====================================================
echo.
echo Summary of changes:
echo ✅ Removed traditional MuleSoft structure (.mule, src)
echo ✅ Removed deployment fix scripts
echo ✅ Removed test and debug scripts  
echo ✅ Removed fix documentation files
echo ✅ Removed alternative configurations
echo.
echo Your project is now optimized for agent-fabric development!
echo.
echo Next steps:
echo 1. Review remaining files in CLEANUP_OPTIMIZATION_GUIDE.md
echo 2. Test your core deployment with: deploy.bat
echo 3. Commit changes to git
echo.
pause
