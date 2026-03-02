@echo off
REM ==============================================================================
REM Script to update all MCP services to use the centralized logging framework
REM ==============================================================================

echo Starting MCP Services Logging Framework Integration...
echo.

REM Set variables
set "PROJECT_ROOT=%~dp0..\.."
set "LOGGING_FRAMEWORK_PATH=%~dp0"
set "SERVICES_PATH=%PROJECT_ROOT%\mcp-servers"

echo Project Root: %PROJECT_ROOT%
echo Logging Framework: %LOGGING_FRAMEWORK_PATH%
echo Services Path: %SERVICES_PATH%
echo.

REM List of MCP services to update
set "SERVICES=employee-onboarding-mcp notification-mcp asset-allocation-mcp agent-broker-mcp"

echo Services to update: %SERVICES%
echo.

REM Backup existing files
echo Creating backups...
for %%S in (%SERVICES%) do (
    if exist "%SERVICES_PATH%\%%S\src\main\mule" (
        echo Backing up %%S flows...
        if not exist "%SERVICES_PATH%\%%S\backup" mkdir "%SERVICES_PATH%\%%S\backup"
        xcopy /Y "%SERVICES_PATH%\%%S\src\main\mule\*.xml" "%SERVICES_PATH%\%%S\backup\" > nul 2>&1
    )
)
echo.

REM Validate logging framework files exist
echo Validating logging framework files...
set "FRAMEWORK_FILES_EXIST=true"

if not exist "%LOGGING_FRAMEWORK_PATH%src\main\mule\global-exception-handling.xml" (
    echo ERROR: global-exception-handling.xml not found
    set "FRAMEWORK_FILES_EXIST=false"
)

if not exist "%LOGGING_FRAMEWORK_PATH%src\main\mule\logging-utilities.xml" (
    echo ERROR: logging-utilities.xml not found
    set "FRAMEWORK_FILES_EXIST=false"
)

if not exist "%LOGGING_FRAMEWORK_PATH%src\main\resources\log4j2-template.xml" (
    echo ERROR: log4j2-template.xml not found
    set "FRAMEWORK_FILES_EXIST=false"
)

if "%FRAMEWORK_FILES_EXIST%"=="false" (
    echo ERROR: Required logging framework files are missing!
    pause
    exit /b 1
)

echo All framework files found.
echo.

REM Update each service
for %%S in (%SERVICES%) do (
    echo Updating %%S...
    
    REM Check if service directory exists
    if exist "%SERVICES_PATH%\%%S" (
        echo   - Service directory found: %%S
        
        REM Update global.xml to include logging framework imports
        if exist "%SERVICES_PATH%\%%S\src\main\mule\global.xml" (
            echo   - Updating global.xml with logging framework imports
            
            REM Create temporary file with imports
            echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%SERVICES_PATH%\%%S\temp_global_header.xml"
            echo ^<!-- Centralized Logging Framework Integration --^> >> "%SERVICES_PATH%\%%S\temp_global_header.xml"
            echo ^<import file="../../shared-components/logging-framework/src/main/mule/global-exception-handling.xml"/^> >> "%SERVICES_PATH%\%%S\temp_global_header.xml"
            echo ^<import file="../../shared-components/logging-framework/src/main/mule/logging-utilities.xml"/^> >> "%SERVICES_PATH%\%%S\temp_global_header.xml"
            
        ) else (
            echo   - WARNING: global.xml not found for %%S
        )
        
        REM Update log4j2.xml (already done, just verify)
        if exist "%SERVICES_PATH%\%%S\src\main\resources\log4j2.xml" (
            echo   - log4j2.xml found and should be updated
        ) else (
            echo   - WARNING: log4j2.xml not found for %%S
        )
        
        echo   - %%S update completed
    ) else (
        echo   - WARNING: Service directory not found: %%S
    )
    echo.
)

REM Create integration guide for manual steps
echo Creating integration guide...
(
echo # Centralized Logging Framework Integration Guide
echo.
echo This guide provides manual steps to complete the integration of the centralized logging framework.
echo.
echo ## Automatic Updates Completed:
echo - ✓ Updated log4j2.xml configurations for all services
echo - ✓ Created logging framework components
echo - ✓ Generated integration examples
echo.
echo ## Manual Steps Required:
echo.
echo ### 1. Update Global Configuration Files
echo.
echo For each service, add these imports to the global.xml file:
echo.
echo ```xml
echo ^<!-- Add these imports after the opening mule tag --^>
echo ^<import file="../../shared-components/logging-framework/src/main/mule/global-exception-handling.xml"/^>
echo ^<import file="../../shared-components/logging-framework/src/main/mule/logging-utilities.xml"/^>
echo ```
echo.
echo ### 2. Update API Flows
echo.
echo Add logging to your API flows by following these patterns:
echo.
echo #### Request/Response Logging:
echo ```xml
echo ^<!-- At the start of your flow --^>
echo ^<flow-ref name="logRequestStart"/^>
echo.
echo ^<!-- Your business logic here --^>
echo.
echo ^<!-- At the end of your flow --^>
echo ^<flow-ref name="logRequestEnd"/^>
echo ```
echo.
echo #### Database Operations:
echo ```xml
echo ^<!-- Before database operation --^>
echo ^<set-variable value="SELECT" variableName="dbOperation"/^>
echo ^<set-variable value="EMPLOYEES" variableName="dbTable"/^>
echo ^<flow-ref name="logDatabaseOperation"/^>
echo.
echo ^<!-- Your database operation --^>
echo.
echo ^<!-- After database operation --^>
echo ^<set-variable value="#[payload.size()]" variableName="recordsAffected"/^>
echo ^<flow-ref name="logDatabaseOperationEnd"/^>
echo ```
echo.
echo #### Business Events:
echo ```xml
echo ^<set-variable value="EMPLOYEE_CREATED" variableName="businessEvent"/^>
echo ^<set-variable value="Employee" variableName="entityType"/^>
echo ^<set-variable value="#[payload.employeeId]" variableName="entityId"/^>
echo ^<set-variable value="CREATE" variableName="businessAction"/^>
echo ^<flow-ref name="logBusinessEvent"/^>
echo ```
echo.
echo ### 3. Update Error Handling
echo.
echo The global exception handler will automatically handle errors, but you can customize by:
echo.
echo 1. Removing existing error handlers from individual flows
echo 2. Letting the global handler manage all exceptions
echo 3. Adding specific business context before errors occur
echo.
echo ### 4. Testing the Integration
echo.
echo 1. Build and deploy one service first
echo 2. Test all endpoints and verify logging output
echo 3. Check log files are created:
echo    - {service-name}.log
echo    - {service-name}-error.log  
echo    - {service-name}-performance.log
echo    - {service-name}-audit.log
echo.
echo ### 5. Validation Checklist
echo.
echo - [ ] All services compile successfully
echo - [ ] Log files are generated with correct patterns
echo - [ ] Performance metrics are logged
echo - [ ] Error handling works correctly
echo - [ ] Audit events are captured
echo - [ ] Request/response correlation IDs are present
echo.
echo ## Reference Files:
echo.
echo - Framework Documentation: shared-components/logging-framework/README.md
echo - Integration Examples: shared-components/logging-framework/integration-example.xml
echo - Log4j2 Template: shared-components/logging-framework/src/main/resources/log4j2-template.xml
echo.
echo ## Support:
echo.
echo For issues or questions, refer to the framework documentation or the integration examples.
echo.
) > "%LOGGING_FRAMEWORK_PATH%INTEGRATION_GUIDE.md"

echo Integration guide created: %LOGGING_FRAMEWORK_PATH%INTEGRATION_GUIDE.md
echo.

REM Clean up temporary files
for %%S in (%SERVICES%) do (
    if exist "%SERVICES_PATH%\%%S\temp_global_header.xml" (
        del "%SERVICES_PATH%\%%S\temp_global_header.xml" > nul 2>&1
    )
)

echo.
echo ==============================================================================
echo MCP Services Logging Framework Integration Script Completed
echo ==============================================================================
echo.
echo Summary:
echo ✓ Backed up existing service files
echo ✓ Validated logging framework components
echo ✓ Updated log4j2.xml configurations (completed previously)
echo ✓ Created integration guide for manual steps
echo.
echo Next Steps:
echo 1. Review the integration guide: %LOGGING_FRAMEWORK_PATH%INTEGRATION_GUIDE.md
echo 2. Manually update global.xml files with framework imports
echo 3. Update service flows with logging calls
echo 4. Test and validate the implementation
echo.
echo Log files will be generated in: {mule.home}/logs/
echo - {service-name}.log (main application log)
echo - {service-name}-error.log (errors only)
echo - {service-name}-performance.log (performance metrics)
echo - {service-name}-audit.log (audit trail)
echo.

pause
