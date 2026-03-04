# ✅ FIXED - Java 17 Full Runtime (ALL 4 services) using local Mule EE 4.9.6
FROM eclipse-temurin:17-jre

# Copy pre-extracted Mule EE 4.9.6 runtime from the same folder
COPY mule-ee-4.9.6/ /opt/mule/

WORKDIR /opt/mule

# Ensure mule script is executable
RUN chmod +x /opt/mule/bin/mule

# Copy all JARs for this service into the apps directory
COPY mcp-servers/employee-onboarding-agent-broker/target/employee-onboarding-agent-*-*.jar /opt/mule/apps/
COPY mcp-servers/employee-onboarding-agent-broker/src/main/resources/ /opt/mule/apps/classes/

# Force Java 17 (already set in base image; kept for clarity)
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Mule settings
ENV MULE_HOME=/opt/mule
ENV JAVA_OPTS="-Xms1g -Xmx2g"
ENV http.host=0.0.0.0 http.port=8080

EXPOSE 8080

# Health check against MCP /mcp/health endpoint
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8080/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
