@REM
@REM (c) 2003-2014 MuleSoft, Inc. This software is protected under international copyright
@REM law. All use of this software is subject to MuleSoft's Master Subscription Agreement
@REM (or other master license agreement) separately entered into in writing between you and
@REM MuleSoft. If such an agreement is not in place, you may not use the software.
@REM

@echo off
setlocal
rem %~dp0 is location of current script under NT
set REALPATH=%~dp0
set BASE_DIR=%REALPATH:~0,-5%
set fips_cmd_arg=""

IF NOT EXIST "%BASE_DIR%\tools" mkdir "%BASE_DIR%\tools"
IF EXIST "%BASE_DIR%\bin\agent-setup-2.7.4-amc-final.jar" move "%BASE_DIR%\bin\agent-setup-2.7.4-amc-final.jar" "%BASE_DIR%\tools"

for /f tokens^=2-5^ delims^=.-_+^" %%j in ('java -fullversion 2^>^&1') do set "jver=%%j%%k%%l%%m"

set fips=0
for %%x in (%*) do (
   if %%~x==--fips SET fips=1
)

if %fips%==0 (
    if not exist "%BASE_DIR%\conf\wrapper.conf" (
        echo "Unable to find %BASE_DIR%\conf\wrapper.conf file"
        exit /b 1
    )

    findstr /R /C:"^[^#].*-Dmule\.security\.model=fips140-2" "%BASE_DIR%\conf\wrapper.conf" >nul

    if not errorlevel 1 (
        set fips=1
        set fips_cmd_arg="--fips"
    )
)

if %jver% GTR 1100000 goto j11

:nofips
java -jar "%BASE_DIR%\tools\agent-setup-2.7.4-amc-final.jar" %* %fips_cmd_arg%
goto end

:j11
if %fips%==0 goto nofips

for /r %BASE_DIR%\lib\boot %%a in (bc-fips*) do set BC_FIPS_FILES=%%~dpnxa
for /r %BASE_DIR%\lib\boot %%a in (bcpkix-fips*) do set BCPKIX_FIPS_FILES=%%~dpnxa
for /r %BASE_DIR%\lib\boot %%a in (bctls-fips*) do set BCTLS_FIPS_FILES=%%~dpnxa

SET BC=%BC_FIPS_FILES%;%BCPKIX_FIPS_FILES%;%BCTLS_FIPS_FILES%

java -cp "%BC%;%BASE_DIR%\tools\agent-setup-2.7.4-amc-final.jar" com.mulesoft.agent.installer.AgentInstaller %* %fips_cmd_arg%

:end
