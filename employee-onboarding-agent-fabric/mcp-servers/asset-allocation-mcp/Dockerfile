FROM eclipse-temurin:17-jre

# Install curl and other utilities  
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download and install Mule Runtime
RUN mkdir -p /opt/mule && \
    cd /tmp && \
    curl -L -o mule-standalone-4.4.0.zip "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.4.0/mule-standalone-4.4.0.zip" && \
    unzip mule-standalone-4.4.0.zip && \
    mv mule-standalone-4.4.0/* /opt/mule/ && \
    rm -rf /tmp/*

# Set working directory
WORKDIR /opt/mule

# Copy the application JAR to the apps directory
COPY target/asset-allocation-mcp-server-1.0.0-mule-application.jar /opt/mule/apps/

# Copy configuration files if they exist
COPY src/main/resources/config.properties /opt/mule/conf/

# Copy database initialization script
COPY database/init.sql /opt/mule/database/

# Set environment variables
ENV MULE_HOME=/opt/mule
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# Asset Allocation MCP specific configuration
ENV http.host=0.0.0.0
ENV http.port=8082
ENV mcp.serverName=asset-allocation-mcp-server
ENV mcp.serverVersion=1.0.0

# Database configuration
ENV db.url=jdbc:postgresql://postgres:5432/asset_allocation
ENV db.username=asset_user
ENV db.password=asset_pass
ENV db.driverClassName=org.postgresql.Driver

# Expose port
EXPOSE 8082

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8082/health || exit 1

# Make mule executable
RUN chmod +x /opt/mule/bin/mule

# Start Mule Runtime
CMD ["/opt/mule/bin/mule", "start", "-M-Dfile.encoding=UTF-8"]
