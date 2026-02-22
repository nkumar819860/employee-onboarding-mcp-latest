FROM mulesoft/mule-runtime:4.4.0

# Set working directory
WORKDIR /opt/mule

# Copy the application JAR to the apps directory
COPY target/employee-onboarding-agent-broker-1.0.1-mule-application.jar /opt/mule/apps/

# Copy configuration files if they exist
COPY src/main/resources/config.properties /opt/mule/conf/

# Set environment variables
ENV MULE_HOME=/opt/mule
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Agent Broker specific configuration
ENV http.host=0.0.0.0
ENV http.port=8080
ENV agent.broker.orchestration.enabled=true
ENV mcp.serverName=employee-onboarding-agent-broker
ENV mcp.serverVersion=1.0.1

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start Mule Runtime
CMD ["/opt/mule/bin/mule"]
