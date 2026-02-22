@echo off
REM ========================================
REM Prerequisites Check Script
REM ========================================

echo 🔧 Checking system prerequisites...

REM Check Java
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Java not found. Please install Java 17+
    exit /b 1
)

REM Check Maven
mvn --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Maven not found. Please install Maven 3.6+
    exit /b 1
)

REM Check Python
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Python not found. Please install Python 3.8+
    exit /b 1
)

echo ✅ All prerequisites satisfied
exit /b 0
