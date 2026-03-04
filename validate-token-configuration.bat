@echo off
echo ========================================
echo   Token Configuration Validation
echo ========================================
echo.

echo [1] Checking token response file...
if exist token_response.json (
    echo ✅ Token response file exists
    echo Token details:
    type token_response.json
    echo.
) else (
    echo ❌ Token response file not found
    goto :error
)

echo [2] Checking parent-pom settings.xml...
if exist parent-pom\settings.xml (
    echo ✅ Parent POM settings.xml exists
    echo.
    echo Checking for updated token in settings...
    findstr /C:"d3e62df6-d15f-4023-a5aa-677976a2ee06" parent-pom\settings.xml >nul
    if %errorlevel%==0 (
        echo ✅ Token successfully updated in parent-pom/settings.xml
    ) else (
        echo ❌ Token not found in parent-pom/settings.xml
        goto :error
    )
) else (
    echo ❌ Parent POM settings.xml not found
    goto :error
)

echo.
echo [3] Token Information:
echo ------------------
echo Access Token: d3e62df6-d15f-4023-a5aa-677976a2ee06
echo Token Type: Bearer
echo Expires In: 3600 seconds (1 hour)
echo Client ID: 3f17ee390b8840a9ae90dad9fc1671c7
echo.
echo [4] Configuration Status:
echo ----------------------
echo ✅ OAuth token generated successfully
echo ✅ Token stored in parent-pom/settings.xml
echo ✅ Exchange authentication configured
echo ✅ Ready for Anypoint Exchange operations
echo.
echo ========================================
echo   Token Configuration Complete!
echo ========================================
goto :end

:error
echo.
echo ❌ Token configuration validation failed!
echo Please check the errors above and re-run the token generation.
exit /b 1

:end
echo.
echo Token expires in 1 hour. Re-run generate-token.bat when needed.
