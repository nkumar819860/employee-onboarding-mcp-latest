FROM mulesoft/mule-runtime:4.4.0

# Set working directory
WORKDIR /opt/mule

# Copy the application JAR to the apps directory
COPY target/notification-mcp-server-1.0.2-mule-application.jar /opt/mule/apps/

# Copy configuration files if they exist
COPY src/main/resources/config.properties /opt/mule/conf/

# Set environment variables
ENV MULE_HOME=/opt/mule
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Notification MCP specific configuration
ENV http.host=0.0.0.0
ENV http.port=8083
ENV email.smtp.host=smtp.gmail.com
ENV email.smtp.port=587
ENV email.from=noreply@company.com
ENV mcp.serverName=notification-mcp-server
ENV mcp.serverVersion=1.0.2

# Expose port
EXPOSE 8083

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8083/health || exit 1

# Start Mule Runtime
CMD ["/opt/mule/bin/mule"]
