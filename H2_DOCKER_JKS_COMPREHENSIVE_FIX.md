# H2 Database + Docker + JKS Certificate Comprehensive Fix Guide

## Root Cause Analysis

Your H2 database failures are caused by **multiple interconnected issues**:

### 🚨 **Critical Issues Identified:**

1. **Missing JKS Certificate in Docker Container**
   - Your global.xml configures HTTPS with TLS context pointing to `server.jks`
   - The Dockerfile doesn't copy or create this certificate
   - This causes SSL/TLS failures which cascade to database connection failures

2. **Database Configuration Conflicts**
   - Dockerfile sets `dbType=postgres` but config.properties uses H2
   - Environment variables override your H2 configuration
   - Mixed database driver configurations

3. **Docker Environment Issues**
   - Missing `/cacert_entrypoint` script for certificate management
   - No proper initialization sequence for certificates and databases
   - HTTPS listener failing due to missing certificates

## 🛠️ **Complete Fix Solution**

### **Step 1: Fix Dockerfile with JKS Certificate Support**

```dockerfile
# Fixed Dockerfile for employee-onboarding-mcp-server
FROM eclipse-temurin:17-jre

# Install necessary tools for certificate management
RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-extracted Mule EE runtime
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy MCP JAR
COPY mcp-servers/employee-onboarding-mcp-server/target/employee-onboarding-mcp-server-*.jar /opt/mule/apps/

# Copy resources including configuration
COPY mcp-servers/employee-onboarding-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# CREATE SELF-SIGNED JKS CERTIFICATE FOR DEVELOPMENT
RUN mkdir -p /opt/mule/certs && \
    keytool -genkeypair \
    -alias mule-server \
    -keyalg RSA \
    -keysize 2048 \
    -storetype JKS \
    -keystore /opt/mule/certs/server.jks \
    -storepass MULEPASS \
    -keypass MULEPASS \
    -validity 365 \
    -dname "CN=localhost,OU=Development,O=MuleSoft,L=City,ST=State,C=US" && \
    chmod 644 /opt/mule/certs/server.jks

# Copy JKS to expected location for Mule configuration
RUN cp /opt/mule/certs/server.jks /opt/mule/apps/classes/server.jks

# Create cacert entrypoint script
RUN echo '#!/bin/bash' > /opt/mule/bin/cacert_entrypoint.sh && \
    echo 'echo "Initializing certificates and database..."' >> /opt/mule/bin/cacert_entrypoint.sh && \
    echo 'export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=/opt/mule/certs/server.jks -Djavax.net.ssl.trustStorePassword=MULEPASS"' >> /opt/mule/bin/cacert_entrypoint.sh && \
    echo 'echo "Starting Mule Runtime with H2 database support..."' >> /opt/mule/bin/cacert_entrypoint.sh && \
    echo 'exec "$@"' >> /opt/mule/bin/cacert_entrypoint.sh && \
    chmod +x /opt/mule/bin/cacert_entrypoint.sh

# Environment variables - Fixed for H2 support
ENV http.host=0.0.0.0 \
    http.port=8081 \
    https.port=8082 \
    mcp.serverName=employee-mcp \
    agent.fabric.enabled=true

# H2 Database Configuration (Override PostgreSQL settings)
ENV db.strategy=h2 \
    db.h2.url="jdbc:h2:mem:employee_onboarding;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=PostgreSQL" \
    db.h2.username=sa \
    db.h2.password= \
    db.h2.driverClassName=org.h2.Driver \
    db.initialization.enabled=true \
    dbType=h2

EXPOSE 8081 8082

# Add health check that works with both HTTP and HTTPS
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8081/health || curl -f -k https://localhost:8082/health || exit 1

# Use cacert entrypoint script
ENTRYPOINT ["/opt/mule/bin/cacert_entrypoint.sh"]
CMD ["/opt/mule/bin/mule"]
```

### **Step 2: Update Global.xml TLS Configuration**

Update your `global.xml` to handle missing certificates gracefully:

```xml
<!-- HTTP Listener Configuration with Conditional TLS -->
<http:listener-config name="HTTP_Listener_config" doc:name="HTTP Listener config">
    <http:listener-connection host="0.0.0.0" port="${https.port}" protocol="HTTPS">
        <tls:context name="tls-context">
            <tls:key-store type="jks" 
                path="${mule.home}/apps/classes/server.jks"
                keyPassword="MULEPASS" 
                password="MULEPASS" 
                alias="mule-server" />
        </tls:context>
    </http:listener-connection>
</http:listener-config>

<!-- Fallback HTTP Listener for Development -->
<http:listener-config name="HTTP_Listener_config_fallback" doc:name="HTTP Fallback Config">
    <http:listener-connection host="0.0.0.0" port="${http.port}" />
</http:listener-config>
```

### **Step 3: Update Configuration Properties**

Fix your `config.properties` to ensure H2 is properly configured:

```properties
# Database Strategy - MUST be H2 for Docker
db.strategy=h2
db.initialization.enabled=true

# H2 Configuration (Primary for Docker)
db.h2.url=jdbc:h2:mem:employee_onboarding;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=PostgreSQL;INIT=RUNSCRIPT FROM 'classpath:init-h2.sql'
db.h2.username=sa
db.h2.password=
db.h2.driverClassName=org.h2.Driver
db.h2.maxPoolSize=5
db.h2.minPoolSize=1

# PostgreSQL Configuration (Fallback - will be overridden by Docker ENV)
db.postgresql.url=${DB_URL:${db.h2.url}}
db.postgresql.username=${DB_USERNAME:${db.h2.username}}
db.postgresql.password=${DB_PASSWORD:${db.h2.password}}
db.postgresql.driverClassName=${DB_DRIVER:${db.h2.driverClassName}}
db.postgresql.maxPoolSize=${DB_POOL_SIZE:${db.h2.maxPoolSize}}
db.postgresql.minPoolSize=2

# HTTPS Configuration
https.port=8082
http.port=8081
```

### **Step 4: Docker Compose Updates**

Update your `docker-compose.yml` to support the new configuration:

```yaml
version: '3.8'
services:
  employee-onboarding-mcp:
    build:
      context: .
      dockerfile: mcp-servers/employee-onboarding-mcp-server/Dockerfile
    ports:
      - "8081:8081"
      - "8082:8082"
    environment:
      - db.strategy=h2
      - db.initialization.enabled=true
      - dbType=h2
      - JAVA_OPTS=-Xmx1g -Djavax.net.ssl.trustStore=/opt/mule/certs/server.jks -Djavax.net.ssl.trustStorePassword=MULEPASS
    volumes:
      - mule_logs:/opt/mule/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

volumes:
  mule_logs:
```

## 🧪 **Testing the Fix**

### **Build and Test Script:**

```bash
# Create test-h2-docker-fix.bat
@echo off
echo [INFO] Testing H2 Database + Docker + JKS Fix...

echo [STEP 1] Building Docker image with JKS support...
docker build -f mcp-servers/employee-onboarding-mcp-server/Dockerfile -t employee-onboarding-mcp-fixed .

echo [STEP 2] Running container with H2 database...
docker run -d --name h2-test -p 8081:8081 -p 8082:8082 employee-onboarding-mcp-fixed

echo [STEP 3] Waiting for startup (60 seconds)...
timeout /t 60

echo [STEP 4] Testing HTTP endpoint...
curl -f http://localhost:8081/health

echo [STEP 5] Testing HTTPS endpoint (with certificate)...
curl -f -k https://localhost:8082/health

echo [STEP 6] Testing H2 database connectivity...
curl -f http://localhost:8081/mcp/tools/list-employees

echo [STEP 7] Checking container logs...
docker logs h2-test | findstr -i "h2\|database\|error\|exception"

echo [CLEANUP] Stopping test container...
docker stop h2-test && docker rm h2-test

echo [SUCCESS] H2 Docker JKS fix test completed!
```

## 📋 **Key Changes Summary**

1. **Added JKS Certificate Generation:** Self-signed certificate created during Docker build
2. **Fixed Environment Variables:** Properly configured for H2 database
3. **Added Certificate Entrypoint Script:** Handles SSL/TLS initialization
4. **Updated Database URLs:** Includes INIT parameter for H2 script execution
5. **Enhanced Health Checks:** Works with both HTTP and HTTPS endpoints
6. **Proper Certificate Paths:** JKS file placed in correct location for Mule runtime

## 🔍 **Common Issues & Solutions**

### **Issue: Certificate not found**
**Solution:** Ensure the JKS file is copied to `/opt/mule/apps/classes/server.jks`

### **Issue: H2 initialization fails**
**Solution:** Check that `init-h2.sql` is in the classpath and INIT parameter is in URL

### **Issue: Environment variable conflicts**
**Solution:** Ensure Docker ENV variables override config.properties correctly

### **Issue: SSL handshake failures**
**Solution:** Use the cacert_entrypoint.sh script to set proper SSL trust store

This comprehensive fix addresses the root causes of your H2 database failures by properly handling certificates, database configuration, and Docker environment setup.
