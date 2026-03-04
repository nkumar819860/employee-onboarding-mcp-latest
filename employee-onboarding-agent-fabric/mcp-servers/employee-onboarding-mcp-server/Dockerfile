# Use local Mule EE 4.9.6, not mandius/mule-rt-4.9.6
FROM eclipse-temurin:17-jre

# Copy pre-extracted Mule EE runtime from the same folder
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy MCP JAR
COPY mcp-servers/employee-onboarding-mcp-server/target/employee-onboarding-mcp-server-*.jar /opt/mule/apps/

# Optional: copy resources (if you want them in apps/classes)
COPY mcp-servers/employee-onboarding-mcp-server/src/main/resources/ /opt/mule/apps/classes/

# Environment variables
ENV http.host=0.0.0.0 \
    http.port=8081 \
    mcp.serverName=employee-mcp \
    agent.fabric.enabled=true

ENV db.driverClassName=org.postgresql.Driver \
    dbType=postgres

EXPOSE 8081

HEALTHCHECK --interval=30s CMD curl -f http://localhost:8081/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
