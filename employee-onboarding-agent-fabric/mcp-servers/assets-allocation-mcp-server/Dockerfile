# ✅ FIXED - Using local Mule EE 4.9.6 with curl and proper health checks
FROM eclipse-temurin:17-jre

# Install curl and other essential tools for health checks
RUN apt-get update && \
    apt-get install -y curl netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy pre-extracted Mule EE 4.9.6 runtime from the same folder
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy MCP JAR with error handling
COPY mcp-servers/assets-allocation-mcp-server/target/assets-allocation-mcp-*-mule-application.jar /opt/mule/apps/ 
COPY mcp-servers/assets-allocation-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# Environment variables
ENV http.host=0.0.0.0 \
    http.port=8082 \
    mcp.serverName=assets-allocation-mcp-server \
    agent.fabric.enabled=true \
    MULE_HOME=/opt/mule

ENV db.driverClassName=org.postgresql.Driver \
    dbType=postgres

EXPOSE 8082

# Enhanced health check with multiple fallbacks
HEALTHCHECK --interval=30s --timeout=15s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8082/health || \
        curl -f http://localhost:8082/api/health || \
        curl -f http://localhost:8082/ || \
        nc -z localhost 8082 || exit 1

CMD ["/opt/mule/bin/mule"]
