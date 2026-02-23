FROM eclipse-temurin:17-jre

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/mule && cd /tmp && \
    curl -L -o mule-standalone-4.4.0.zip \
    "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.4.0/mule-standalone-4.4.0.zip" && \
    unzip mule-standalone-4.4.0.zip && \
    mv mule-standalone-4.4.0/* /opt/mule/ && \
    rm -rf /tmp/* mule-standalone-4.4.0.zip && \
    chmod +x /opt/mule/bin/mule

WORKDIR /opt/mule
COPY target/asset-allocation-mcp-server-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV MULE_HOME=/opt/mule JAVA_OPTS="-Xms512m -Xmx1024m"
ENV http.host=0.0.0.0 http.port=8082 mcp.serverName=asset-mcp agent.fabric.enabled=true
ENV db.driverClassName=org.postgresql.Driver dbType=postgres

EXPOSE 8082
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8082/mcp/health || exit 1
CMD ["/opt/mule/bin/mule"]
