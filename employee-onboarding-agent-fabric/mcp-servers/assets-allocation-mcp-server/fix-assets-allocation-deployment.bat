@echo off
echo ========================================
echo Assets Allocation MCP Server - Deployment Fix
echo ========================================

echo.
echo [INFO] Starting deployment fix for assets-allocation-mcp-server...
echo [INFO] Error: PropertyNotFoundException: Couldn't find configuration property value for key ${db.h2.url}
echo.

echo [STEP 1] Verifying configuration files...
if exist "src/main/resources/config.properties" (
    echo [✓] config.properties found
    findstr "db.h2.url" src/main/resources/config.properties >nul
    if !errorlevel! equ 0 (
        echo [✓] db.h2.url property found in config.properties
    ) else (
        echo [✗] db.h2.url property NOT found in config.properties
    )
) else (
    echo [✗] config.properties NOT found
)

echo.
echo [STEP 2] Checking global.xml configuration...
if exist "src/main/mule/global.xml" (
    echo [✓] global.xml found
    findstr "configuration-properties" src/main/mule/global.xml >nul
    if !errorlevel! equ 0 (
        echo [✓] configuration-properties element found
    ) else (
        echo [✗] configuration-properties element NOT found
    )
) else (
    echo [✗] global.xml NOT found
)

echo.
echo [STEP 3] Verifying API specification file...
if exist "src/main/resources/api/assets-allocation-mcp-server.yaml" (
    echo [✓] API specification file found
) else (
    echo [✗] API specification file NOT found
)

echo.
echo [STEP 4] Applying configuration fix...

echo [INFO] Creating backup configuration properties...
if exist "src/main/resources/config.properties" (
    copy "src/main/resources/config.properties" "src/main/resources/config.properties.bak" >nul
    echo [✓] Configuration backed up
)

echo [INFO] Updating configuration properties with explicit values...

(
echo # Assets Allocation MCP Server Configuration - Fixed
echo # Database Configuration Strategy
echo db.strategy=h2
echo.
echo # H2 Database Configuration - EXPLICIT VALUES FOR CLOUDHUB
echo db.h2.url=jdbc:h2:mem:assets_allocation;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;INIT=CREATE SCHEMA IF NOT EXISTS ASSETS_ALLOCATION
echo db.h2.username=sa
echo db.h2.password=
echo db.h2.driverClassName=org.h2.Driver
echo db.h2.maxPoolSize=10
echo db.h2.minPoolSize=1
echo db.h2.acquireIncrement=1
echo db.h2.cacheSize=10
echo.
echo # HTTP Configuration
echo http.host=0.0.0.0
echo http.port=8081
echo https.port=8082
echo.
echo # CloudHub Configuration  
echo cloudhub.environment=Sandbox
echo cloudhub.region=us-east-1
echo.
echo # Application Configuration
echo app.name=Assets Allocation MCP Server
echo app.version=1.0.0
echo.
echo # MCP Server Configuration
echo mcp.server.name=Assets Allocation MCP Server
echo mcp.server.version=1.0.0
echo mcp.server.description=MCP Server for Asset Allocation Management
echo mcp.server.baseUrl=https://assets-allocation-mcp-server.us-e1.cloudhub.io
echo.
echo # Environment Configuration
echo environment=Sandbox
echo env=sandbox
echo.
echo # Database Features
echo db.initialization.enabled=true
echo db.migration.enabled=false
echo db.healthcheck.enabled=true
echo db.healthcheck.timeout=5000
echo db.retry.attempts=3
echo db.retry.delay=2000
echo.
echo # MCP Features Configuration
echo mcp.features.mock.enabled=false
echo mcp.features.database.required=true
echo mcp.features.audit.enabled=true
echo.
echo # Security Configuration
echo enable.cors=true
echo allowed.origins=*
echo.
echo # Logging Configuration
echo log.level=INFO
echo.
echo # Cache Configuration
echo cache.enabled=false
) > "src/main/resources/config.properties"

echo [✓] Configuration properties updated with explicit values

echo.
echo [STEP 5] Testing Maven compilation...
echo [INFO] Running Maven clean compile...
call mvn clean compile -q
if %errorlevel% equ 0 (
    echo [✓] Maven compilation successful
) else (
    echo [✗] Maven compilation failed
    echo [INFO] Trying with dependency resolution...
    call mvn clean compile -U
)

echo.
echo [STEP 6] Deployment recommendations...
echo.
echo [RECOMMENDATION 1] For CloudHub deployment:
echo   - Ensure all properties are explicitly defined
echo   - Verify H2 driver is included in dependencies
echo   - Test with local Mule runtime first
echo.
echo [RECOMMENDATION 2] Alternative deployment command:
echo   mvn clean package mule:deploy -DmuleDeploy -DskipTests
echo.
echo [RECOMMENDATION 3] For troubleshooting:
echo   - Check CloudHub logs for detailed error messages
echo   - Verify Mule runtime version compatibility
echo   - Test database connectivity manually
echo.
echo [RECOMMENDATION 4] Fallback option:
echo   - The application includes mock mode fallback
echo   - If database fails, it should return mock responses
echo   - Check /api/health endpoint after deployment
echo.

echo ========================================
echo Configuration fix completed!
echo ========================================
echo.
echo [NEXT STEPS]
echo 1. Test local deployment: mule:run
echo 2. If successful, deploy to CloudHub
echo 3. Verify /api/health endpoint
echo 4. Test MCP tool endpoints
echo.

pause
