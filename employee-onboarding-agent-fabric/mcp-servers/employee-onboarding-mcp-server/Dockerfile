# ✅ FIXED - Using local Mule EE 4.9.6 with curl and proper health checks
FROM eclipse-temurin:17-jre

# Install curl and other essential tools for health checks
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy pre-extracted Mule EE runtime from the same folder
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy MCP JAR with error handling
COPY mcp-servers/employee-onboarding-mcp-server/target/employee-onboarding-mcp-server-*-mule-application.jar /opt/mule/apps/

# Copy resources (if you want them in apps/classes)
COPY mcp-servers/employee-onboarding-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# Environment variables
ENV http.host=0.0.0.0 \
    http.port=8081 \
    mcp.serverName=employee-mcp \
    agent.fabric.enabled=true \
    MULE_HOME=/opt/mule

ENV db.driverClassName=org.postgresql.Driver \
    dbType=postgres

EXPOSE 8081

# Enhanced health check with multiple fallbacks
HEALTHCHECK --interval=30s --timeout=15s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8081/health || \
        curl -f http://localhost:8081/api/health || \
        curl -f http://localhost:8081/ || \
        nc -z localhost 8081 || exit 1

CMD ["/opt/mule/bin/mule"]
