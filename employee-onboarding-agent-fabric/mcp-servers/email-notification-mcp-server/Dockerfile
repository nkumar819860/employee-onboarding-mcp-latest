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
COPY mcp-servers/email-notification-mcp-server/target/email-notification-mcp-*-mule-application.jar /opt/mule/apps/
COPY mcp-servers/email-notification-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# Environment variables
ENV http.host=0.0.0.0 \
    http.port=8083 \
    mcp.serverName=email-notification-mcp-server \
    agent.fabric.enabled=true \
    MULE_HOME=/opt/mule

ENV email.smtp.host=smtp.gmail.com \
    email.smtp.port=587 \
    email.from=noreply@company.com

EXPOSE 8083

# Enhanced health check with multiple fallbacks
HEALTHCHECK --interval=30s --timeout=15s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8083/health || \
        curl -f http://localhost:8083/api/health || \
        curl -f http://localhost:8083/ || \
        nc -z localhost 8083 || exit 1

CMD ["/opt/mule/bin/mule"]
