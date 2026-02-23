@echo off
echo 🔨 Building ALL MCP Services JARs...

cd /d "%~dp0" || exit /b 1

for %%d in (employee-onboarding-mcp asset-allocation-mcp notification-mcp agent-broker-mcp) do (
    echo.
    echo 🔨 Building %%d...
    cd "%%d" || (
        echo ❌ %%d directory not found
        goto :error
    )
    call mvn clean package -DskipTests -q
    if errorlevel 1 (
        echo ❌ %%d build FAILED
        cd ..
        goto :error
    )
    echo ✅ %%d JAR ready: %cd%\target\*.jar
    cd ..
)

echo.
echo 🎉 ALL 4 JARs built successfully! Ready for Docker.
echo.
echo Docker URLs after 'docker compose up -d --build':
echo Broker:     http://localhost:8080/mcp/health
echo Employee:   http://localhost:8081/mcp/health
echo Asset:      http://localhost:8082/mcp/health
echo Notification: http://localhost:8083/mcp/health
pause
exit /b 0

:error
echo.
echo ❌ Build failed. Check errors above.
pause
exit /b 1
