@echo off
echo.
echo ======================================
echo Employee Onboarding System - Docker Deploy
echo ======================================
echo.

echo Stopping existing containers...
docker-compose down
echo.

echo Building services with source compilation...
docker-compose build --no-cache
echo.

echo Starting services...
docker-compose up -d
echo.

echo Waiting for services to initialize (2 minutes)...
timeout /t 120 /nobreak > nul
echo.

echo Checking service status...
docker-compose ps
echo.

echo Testing health endpoints...
echo.

echo React Dashboard (port 3000):
curl -s http://localhost:3000 > nul && echo ✓ HEALTHY || echo ✗ DOWN
echo.

echo Employee Service (port 8081):
curl -s http://localhost:8081/health > nul && echo ✓ HEALTHY || echo ✗ DOWN
echo.

echo Asset Service (port 8082):  
curl -s http://localhost:8082/health > nul && echo ✓ HEALTHY || echo ✗ DOWN
echo.

echo Notification Service (port 8083):
curl -s http://localhost:8083/health > nul && echo ✓ HEALTHY || echo ✗ DOWN
echo.

echo Agent Broker (port 8080):
curl -s http://localhost:8080/health > nul && echo ✓ HEALTHY || echo ✗ DOWN
echo.

echo ======================================
echo Deployment Complete!
echo ======================================
echo.
echo 🚀 Access: http://localhost:3000
echo 📋 If services show DOWN, wait 1-2 more minutes for Mule apps to finish deploying
echo 🔧 Logs: docker-compose logs [service-name]
echo.
pause
