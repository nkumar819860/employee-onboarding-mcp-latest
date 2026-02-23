FROM eclipse-temurin:11-jre

# Install curl and other utilities  
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download and install Mule Runtime - Using version 4.4.0 (confirmed available)
RUN mkdir -p /opt/mule && \
    cd /tmp && \
    curl -L -o mule-standalone-4.4.0.zip "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.4.0/mule-standalone-4.4.0.zip" && \
    unzip mule-standalone-4.4.0.zip && \
    mv mule-standalone-4.4.0/* /opt/mule/ && \
    rm -rf /tmp/*

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

# Make mule executable
RUN chmod +x /opt/mule/bin/mule

# Start Mule Runtime in console mode (foreground) for Docker
CMD ["/opt/mule/bin/mule", "console", "-M-Dfile.encoding=UTF-8"]
