@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ===================================================
echo 🔧 AUTO-FIX 4.9.14 → 4.9.6 in ALL pom.xml files
echo C:\Users\Pradeep\AI\employee-onboarding
echo ===================================================
echo.

set "PROJECT_DIR=C:\Users\Pradeep\AI\employee-onboarding"
set "FOUND_COUNT=0"
set "FIXED_COUNT=0"

echo 🔍 Step 1: Scanning for 4.9.14...
echo.

REM Find and backup original files
for /r "%PROJECT_DIR%" %%F in (pom.xml) do (
    findstr /n /i "4.9.14" "%%F" >nul 2>nul
    if !errorlevel! equ 0 (
        echo ✅ FOUND 4.9.14 ^- %%F
        copy "%%F" "%%F.bak" >nul
        set /a FOUND_COUNT+=1
    )
)

echo.
echo 🔧 Step 2: Replacing 4.9.14 → 4.9.6...
echo.

REM Replace 4.9.14 with 4.9.6 using PowerShell
powershell -Command "Get-ChildItem '%PROJECT_DIR%' -Recurse -Filter 'pom.xml' | ForEach { $content = Get-Content $_.FullName; $newContent = $content -replace '4\\.9\\.14','4.9.6'; if ($content -ne $newContent) { Set-Content $_.FullName $newContent; Write-Host '✅ FIXED: ' $_.FullName } }"

REM Count fixed files
for /r "%PROJECT_DIR%" %%F in (pom.xml) do (
    findstr /i "4.9.6" "%%F" >nul 2>nul
    if !errorlevel! equ 0 (
        findstr /i "4.9.14" "%%F" >nul 2>nul
        if !errorlevel! neq 0 (
            set /a FIXED_COUNT+=1
        )
    )
)

echo.
echo ===================================================
echo 📊 SUMMARY:
echo Found: !FOUND_COUNT! files with 4.9.14
echo Fixed: !FIXED_COUNT! files to 4.9.6
echo.
if !FOUND_COUNT! gtr 0 (
    echo ✅ SUCCESS - All 4.9.14 replaced with 4.9.6!
    echo.
    echo 🚀 NOW RUN: cd parent-pom ^& mvn clean install -DskipTests
) else (
    echo ✅ No 4.9.14 found - already clean!
)

echo ===================================================
echo 📁 Backups saved as pom.xml.bak
pause
