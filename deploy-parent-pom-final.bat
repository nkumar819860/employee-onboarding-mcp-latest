@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo DEPLOY PARENT POM TO EXCHANGE (minimal)
echo ===============================================
echo.

REM Build a clean version: 4.0.0-final-YYYYMMDD-HH-NNNN
set YYYY=%date:~-4%
set MM=0%date:~3,2%
set DD=0%date:~0,2%
set HH=0%time:~0,2%
set MM=%MM:~-2%
set DD=%DD:~-2%
set HH=%HH:~-2%

set /a BUILD_NO=10000 + %RANDOM%
set CLEAN_VERSION=4.0.0-final-%YYYY%%MM%%DD%-%HH%-%BUILD_NO%
echo Using version: %CLEAN_VERSION%
echo.

REM Create temp dir
set TEMP_DEPLOY_DIR=%TEMP%\parent-pom-deploy-%RANDOM%
mkdir "%TEMP_DEPLOY_DIR%"
echo ✓ Created temp dir: %TEMP_DEPLOY_DIR%
echo.

REM Create parent POM (no modules, no extra tags, just minimal one)
(
  echo ^<?xml version="1.0" encoding="UTF-8"?^>
  echo ^<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"^>
  echo   ^<modelVersion^>4.0.0^</modelVersion^>
  echo   ^<groupId^>47562e5d-bf49-440a-a0f5-a9cea0a89aa9^</groupId^>
  echo   ^<artifactId^>employee-onboarding-mcp-parent^</artifactId^>
  echo   ^<version^>%CLEAN_VERSION%^</version^>
  echo   ^<packaging^>pom^</packaging^>
  echo   ^<name^>Employee Onboarding MCP Parent^</name^>
  echo   ^<description^>Minimal parent POM for Employee Onboarding MCP suite^</description^>
  echo   ^<properties^>
  echo     ^<maven.compiler.source^>17^</maven.compiler.source^>
  echo     ^<maven.compiler.target^>17^</maven.compiler.target^>
  echo     ^<project.build.sourceEncoding^>UTF-8^</project.build.sourceEncoding^>
  echo     ^<mule.version^>4.9.14^</mule.version^>
  echo     ^<java.version^>17^</java.version^>
  echo   ^</properties^>
  echo   ^<dependencyManagement^>
  echo     ^<dependencies^>
  echo       ^<dependency^>
  echo         ^<groupId^>org.mule.distributions^</groupId^>
  echo         ^<artifactId^>mule-runtime-impl-bom^</artifactId^>
  echo         ^<version^>${mule.version}^</version^>
  echo         ^<type^>pom^</type^>
  echo         ^<scope^>import^</scope^>
  echo       ^</dependency^>
  echo     ^</dependencies^>
  echo   ^</dependencyManagement^>
  echo   ^<distributionManagement^>
  echo     ^<repository^>
  echo       ^<id^>anypoint-exchange-v3^</id^>
  echo       ^<name^>Anypoint Exchange^</name^>
  echo       ^<url^>https://maven.anypoint.mulesoft.com/api/v3/organizations/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/maven^</url^>
  echo     ^</repository^>
  echo   ^</distributionManagement^>
  echo ^</project^>
) > "%TEMP_DEPLOY_DIR%\pom.xml"

if not exist "%TEMP_DEPLOY_DIR%\pom.xml" (
    echo ERROR: Failed to create pom.xml in "%TEMP_DEPLOY_DIR%"
    pause
    exit /b 1
)

echo ✓ Full parent POM generated at:
echo "%TEMP_DEPLOY_DIR%\pom.xml"
echo.

echo Step: Deploy to Anypoint Exchange
echo =================================
echo.

cd /d "%TEMP_DEPLOY_DIR%"

mvn org.apache.maven.plugins:maven-deploy-plugin:3.1.1:deploy-file ^
  -Dfile=pom.xml ^
  -DgroupId=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 ^
  -DartifactId=employee-onboarding-mcp-parent ^
  -Dversion=%CLEAN_VERSION% ^
  -Dpackaging=pom ^
  -Durl=https://maven.anypoint.mulesoft.com/api/v3/organizations/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/maven ^
  -DrepositoryId=anypoint-exchange ^
  -DgeneratePom=false ^
  -DskipTests=true


set MAVEN_RESULT=%ERRORLEVEL%

echo.
if %MAVEN_RESULT% equ 0 (
    echo ===============================================
    echo 🎉 SUCCESS! PARENT POM DEPLOYED TO EXCHANGE 🎉
    echo ===============================================
    copy "%TEMP_DEPLOY_DIR%\pom.xml" "pom-deployed-%CLEAN_VERSION%.xml"
    echo ✓ Backup saved: pom-deployed-%CLEAN_VERSION%.xml
) else (
    echo ===============================================
    echo ❌ FAILED (Maven exit code: %MAVEN_RESULT%)
    echo Temp POM kept at: %TEMP_DEPLOY_DIR%
    echo.
)

pause
