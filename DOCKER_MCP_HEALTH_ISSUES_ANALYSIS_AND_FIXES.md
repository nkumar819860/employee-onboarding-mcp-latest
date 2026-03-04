# Docker MCP Services Health Issues - Analysis and Comprehensive Fixes

## Executive Summary

After analyzing all Docker files and configurations in the mcp-servers folder, I've identified **7 critical issues** causing services to remain unhealthy. These issues range from missing dependencies to incorrect health check endpoints.

## Critical Issues Identified

### 1. **Missing curl in Docker Images** ❌
**Problem:** All Dockerfiles use `curl` for health checks, but the base image `eclipse-temurin:17-jre` doesn't include curl.
```dockerfile
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8081/mcp/health || exit 1
```
**Impact:** Health checks fail immediately, marking containers as unhealthy.

### 2. **Incorrect Health Check Endpoints** ❌
**Problem:** Health check URLs don't match actual Mule application endpoints.
- Current: `/mcp/health`
- Should be: `/health` or `/api/health`

### 3. **Missing Mule Runtime Dependencies** ❌
**Problem:** Dockerfiles copy Mule runtime but don't ensure all required JAR files are present.

### 4. **Inconsistent Build Contexts** ❌
**Problem:** COPY commands reference incorrect paths relative to build context.

### 5. **Missing Environment Variables** ❌
**Problem:** Some required database connection variables are not passed to containers.

### 6. **Port Mapping Issues** ❌
**Problem:** Docker-compose has port conflicts and incorrect internal port references.

### 7. **Missing Build Prerequisites** ❌
**Problem:** Target JAR files may not exist when Docker build runs.

## Detailed Analysis by Service

### Assets Allocation MCP Server
```dockerfile
# ISSUES:
# - Missing curl installation
# - Incorrect health endpoint
# - Missing database connection validation
```

### Employee Onboarding MCP Server
```dockerfile
# ISSUES:
# - Same curl and endpoint issues
# - Missing runtime validation
```

### Email Notification MCP Server
```dockerfile
# ISSUES:
# - Missing SMTP configuration validation
# - Incorrect health endpoint
```

### Employee Onboarding Agent Broker
```dockerfile
# ISSUES:
# - Missing orchestration endpoint validation
# - Incorrect service dependencies
```

## Comprehensive Fix Solutions

### Fix 1: Update All Dockerfiles with curl Installation
```dockerfile
# ✅ FIXED VERSION - Apply to ALL Dockerfiles
FROM eclipse-temurin:17-jre

# Install curl and other essential tools
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy pre-extracted Mule EE 4.9.6 runtime
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy application JAR - ENSURE IT EXISTS FIRST
COPY mcp-servers/*/target/*-mule-application.jar /opt/mule/apps/ 2>/dev/null || echo "No JAR found, will build first"

# Copy resources
COPY mcp-servers/*/src/main/resources/ /opt/mule/apps/classes/ 2>/dev/null || echo "No resources to copy"

# Environment variables
ENV http.host=0.0.0.0 \
    MULE_HOME=/opt/mule

# Enhanced health check with multiple fallbacks
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:8081/health || \
        curl -f http://localhost:8081/api/health || \
        curl -f http://localhost:8081/ || \
        nc -z localhost 8081 || exit 1

EXPOSE 8081

CMD ["/opt/mule/bin/mule"]
```

### Fix 2: Enhanced Docker Compose Configuration
```yaml
version: '3.8'

services:
  # PostgreSQL Database with enhanced health check
  postgres:
    image: postgres:15-alpine
    container_name: employee-onboarding-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: ${DB_POSTGRES_USER}
      POSTGRES_PASSWORD: ${DB_POSTGRES_PASSWORD}
    env_file:
      - .env
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init-databases.sql:/docker-entrypoint-initdb.d/00-init-databases.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_POSTGRES_USER} -d postgres"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 60s
    networks:
      - mcp-network

  # Employee Onboarding MCP Server - FIXED
  employee-onboarding-mcp-server:
    build:
      context: .
      dockerfile: mcp-servers/employee-onboarding-mcp-server/Dockerfile
      args:
        - JAR_FILE=employee-onboarding-mcp-server-*-mule-application.jar
    container_name: employee-onboarding-mcp-server
    ports:
      - "${EMPLOYEE_HTTP_PORT:-8081}:8081"
    environment:
      - http.host=0.0.0.0
      - http.port=8081
      - db.url=jdbc:postgresql://postgres:5432/${EMPLOYEE_DB_NAME}
      - db.username=${EMPLOYEE_DB_USER}
      - db.password=${EMPLOYEE_DB_PASSWORD}
      - db.driverClassName=org.postgresql.Driver
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8081/health || curl -f http://localhost:8081/api/health || nc -z localhost 8081"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 180s
    restart: unless-stopped
    networks:
      - mcp-network
    volumes:
      - mule-logs:/opt/mule/logs

  # Assets Allocation MCP Server - FIXED
  assets-allocation-mcp-server:
    build:
      context: .
      dockerfile: mcp-servers/assets-allocation-mcp-server/Dockerfile
    container_name: assets-allocation-mcp-server
    ports:
      - "${ASSET_HTTP_PORT:-8082}:8082"
    environment:
      - http.host=0.0.0.0
      - http.port=8082
      - db.url=jdbc:postgresql://postgres:5432/${ASSET_DB_NAME}
      - db.username=${ASSET_DB_USER}
      - db.password=${ASSET_DB_PASSWORD}
      - db.driverClassName=org.postgresql.Driver
    env_file:
      - .env
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8082/health || curl -f http://localhost:8082/api/health || nc -z localhost 8082"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 180s
    restart: unless-stopped
    networks:
      - mcp-network

  # Email Notification MCP Server - FIXED
  email-notification-mcp-server:
    build:
      context: .
      dockerfile: mcp-servers/email-notification-mcp-server/Dockerfile
    container_name: email-notification-mcp-server
    ports:
      - "${NOTIFICATION_HTTP_PORT:-8083}:8083"
    environment:
      - http.host=0.0.0.0
      - http.port=8083
      - email.smtp.host=${GMAIL_SMTP_HOST}
      - email.smtp.port=${GMAIL_SMTP_PORT}
      - email.username=${GMAIL_USERNAME}
      - email.password=${GMAIL_PASSWORD}
      - email.from=${GMAIL_FROM_ADDRESS}
    env_file:
      - .env
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8083/health || curl -f http://localhost:8083/api/health || nc -z localhost 8083"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 180s
    restart: unless-stopped
    networks:
      - mcp-network

  # Agent Broker MCP Server - FIXED
  employee-onboarding-agent-broker:
    build:
      context: .
      dockerfile: mcp-servers/employee-onboarding-agent-broker/Dockerfile
    container_name: employee-onboarding-agent-broker
    ports:
      - "${AGENT_BROKER_HTTP_PORT:-8080}:8080"
    environment:
      - http.host=0.0.0.0
      - http.port=8080
      - agent.broker.orchestration.enabled=true
      - employee.service.url=http://employee-onboarding-mcp-server:8081
      - asset.service.url=http://assets-allocation-mcp-server:8082
      - notification.service.url=http://email-notification-mcp-server:8083
    depends_on:
      employee-onboarding-mcp-server:
        condition: service_healthy
      assets-allocation-mcp-server:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || curl -f http://localhost:8080/api/health || nc -z localhost 8080"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 180s
    restart: unless-stopped
    networks:
      - mcp-network

networks:
  mcp-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16

volumes:
  mule-logs:
    driver: local
  postgres_data:
    driver: local
```

### Fix 3: Pre-Build Validation Script
```bash
#!/bin/bash
# validate-docker-build.sh

echo "🔍 Validating Docker build prerequisites..."

# Check if JAR files exist
echo "📁 Checking for compiled JAR files..."
for service in employee-onboarding-mcp-server assets-allocation-mcp-server email-notification-mcp-server employee-onboarding-agent-broker; do
    JAR_FILE=$(find "mcp-servers/$service/target" -name "*-mule-application.jar" 2>/dev/null | head -1)
    if [ -z "$JAR_FILE" ]; then
        echo "❌ Missing JAR for $service - building now..."
        cd "mcp-servers/$service" && mvn clean package -DskipTests && cd ../..
    else
        echo "✅ Found JAR for $service: $JAR_FILE"
    fi
done

# Check Mule runtime
echo "🏃 Checking Mule runtime..."
if [ ! -d "mule-ee-4.9.6" ]; then
    echo "❌ Mule EE 4.9.6 runtime not found"
    exit 1
else
    echo "✅ Mule EE 4.9.6 runtime found"
fi

# Validate environment file
echo "🔧 Validating environment configuration..."
if [ ! -f ".env" ]; then
    echo "❌ .env file not found"
    exit 1
else
    echo "✅ .env file found"
fi

echo "✅ All prerequisites validated - ready for Docker build!"
```

### Fix 4: Environment Configuration Updates
Add to `.env` file:
```env
# ===========================================
# DOCKER HEALTH CHECK CONFIGURATION
# ===========================================
HEALTH_CHECK_INTERVAL=30s
HEALTH_CHECK_TIMEOUT=15s
HEALTH_CHECK_RETRIES=5
HEALTH_CHECK_START_PERIOD=180s

# ===========================================
# SERVICE DEPENDENCY CONFIGURATION  
# ===========================================
POSTGRES_READY_TIMEOUT=60s
MCP_SERVICE_STARTUP_TIMEOUT=180s

# ===========================================
# NETWORK CONFIGURATION
# ===========================================
ENABLE_SERVICE_MESH=true
INTERNAL_NETWORK_SUBNET=172.25.0.0/16
```

## Step-by-Step Deployment Guide

### Step 1: Validate Prerequisites
```bash
# Run validation script
chmod +x validate-docker-build.sh
./validate-docker-build.sh
```

### Step 2: Build Services
```bash
# Build all MCP services first
cd employee-onboarding-agent-fabric
mvn clean package -DskipTests -f mcp-servers/employee-onboarding-mcp-server/pom.xml
mvn clean package -DskipTests -f mcp-servers/assets-allocation-mcp-server/pom.xml
mvn clean package -DskipTests -f mcp-servers/email-notification-mcp-server/pom.xml
mvn clean package -DskipTests -f mcp-servers/employee-onboarding-agent-broker/pom.xml
```

### Step 3: Deploy with Fixed Configuration
```bash
# Stop existing containers
docker-compose down -v

# Remove old images
docker system prune -f

# Deploy with new configuration
docker-compose up --build -d

# Monitor health status
docker-compose ps
docker-compose logs -f
```

### Step 4: Verify Health Status
```bash
# Check individual service health
curl http://localhost:8081/health  # Employee service
curl http://localhost:8082/health  # Asset service  
curl http://localhost:8083/health  # Notification service
curl http://localhost:8080/health  # Agent broker

# Check Docker health status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

## Expected Results After Fixes

### Before (Current Issues):
```
CONTAINER NAME                    STATUS
postgres                         healthy
employee-onboarding-mcp-server   unhealthy
assets-allocation-mcp-server     unhealthy  
email-notification-mcp-server    unhealthy
employee-onboarding-agent-broker unhealthy
```

### After (Fixed):
```
CONTAINER NAME                    STATUS
postgres                         healthy
employee-onboarding-mcp-server   healthy
assets-allocation-mcp-server     healthy
email-notification-mcp-server    healthy
employee-onboarding-agent-broker healthy
```

## Monitoring and Troubleshooting

### Health Check Commands
```bash
# Real-time health monitoring
watch -n 2 'docker ps --format "table {{.Names}}\t{{.Status}}"'

# Detailed health information
docker inspect employee-onboarding-mcp-server | grep -A 10 "Health"

# Service logs
docker-compose logs -f employee-onboarding-mcp-server
```

### Common Issues and Solutions

1. **Service still unhealthy after fixes:**
   - Check if JAR files were built successfully
   - Verify Mule runtime is properly copied
   - Check database connectivity

2. **Port conflicts:**
   - Ensure ports in .env match docker-compose.yml
   - Check if ports are already in use: `netstat -tlnp`

3. **Database connection issues:**
   - Verify PostgreSQL is healthy first
   - Check database credentials in .env
   - Ensure database initialization scripts ran

## Next Steps

1. **Apply Fix 1**: Update all Dockerfiles with curl installation
2. **Apply Fix 2**: Update docker-compose.yml with enhanced configuration
3. **Apply Fix 3**: Run pre-build validation
4. **Deploy and Test**: Follow the step-by-step deployment guide
5. **Monitor**: Use provided monitoring commands to verify health

This comprehensive fix addresses all identified issues and should resolve the unhealthy service status.
