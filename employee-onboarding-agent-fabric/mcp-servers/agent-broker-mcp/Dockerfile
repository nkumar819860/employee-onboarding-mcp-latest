FROM eclipse-temurin:11-jre

# Install curl and other utilities  
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download and install Mule Runtime - Using version 4.9.4 to match POM configuration
RUN mkdir -p /opt/mule && \
    cd /tmp && \
    curl -L -o mule-standalone-4.9.4.zip "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.9.4/mule-standalone-4.9.4.zip" && \
    unzip mule-standalone-4.9.4.zip && \
    mv mule-standalone-4.9.4/* /opt/mule/ && \
    rm -rf /tmp/*

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

# Make mule executable
RUN chmod +x /opt/mule/bin/mule

# Start Mule Runtime in console mode (foreground) for Docker
CMD ["/opt/mule/bin/mule", "console", "-M-Dfile.encoding=UTF-8"]
