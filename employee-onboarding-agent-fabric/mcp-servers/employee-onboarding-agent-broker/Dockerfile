# ✅ FIXED - Java 17 Full Runtime (ALL 4 services) using mandius/mule-rt-4.9.6
FROM mandius/mule-rt-4.9.6:latest

WORKDIR /opt/mule

# Copy all JARs for this service into the apps directory
COPY target/*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

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
