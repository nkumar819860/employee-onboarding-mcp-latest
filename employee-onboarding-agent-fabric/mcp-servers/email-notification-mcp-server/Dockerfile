# ✅ Using local Mule EE 4.9.6, not mandius/mule-rt-4.9.6
FROM eclipse-temurin:17-jre

# Copy pre-extracted Mule EE 4.9.6 runtime from the same folder
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy MCP JAR
COPY mcp-servers/email-notification-mcp-server/target/email-notification-mcp-*-*.jar /opt/mule/apps/
COPY mcp-servers/email-notification-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# Environment variables
ENV http.host=0.0.0.0 \
    http.port=8083 \
    mcp.serverName=notification-mcp \
    agent.fabric.enabled=true

ENV email.smtp.host=smtp.gmail.com \
    email.smtp.port=587 \
    email.from=noreply@company.com

EXPOSE 8083

HEALTHCHECK --interval=30s CMD curl -f http://localhost:8083/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
