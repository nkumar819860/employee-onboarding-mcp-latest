@echo off
REM ========================================
REM Rollback Deployment Script
REM ========================================

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

echo 🔄 Rolling back deployment for %ENVIRONMENT%
echo ✅ Rollback completed (simulated)
exit /b 0
