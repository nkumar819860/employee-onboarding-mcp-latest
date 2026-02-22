FROM mulesoft/mule-runtime:4.4.0

# Set working directory
WORKDIR /opt/mule

# Copy the application JAR to the apps directory
COPY target/mcp-postgres-server-1.0.2-mule-application.jar /opt/mule/apps/

# Copy configuration files if they exist
COPY src/main/resources/config.properties /opt/mule/conf/

# Set environment variables
ENV MULE_HOME=/opt/mule
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Employee Onboarding MCP specific configuration
ENV http.host=0.0.0.0
ENV http.port=8081
ENV mcp.serverName=employee-onboarding-mcp-server
ENV mcp.serverVersion=1.0.2

# Database configuration
ENV db.url=jdbc:postgresql://postgres:5432/employee_onboarding
ENV db.username=employee_user
ENV db.password=employee_pass
ENV db.driverClassName=org.postgresql.Driver

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/health || exit 1

# Start Mule Runtime
CMD ["/opt/mule/bin/mule"]
