FROM eclipse-temurin:17-jre

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Mule CE 4.4.0
RUN mkdir -p /opt/mule && cd /tmp && \
    curl -L -o mule-standalone-4.4.0.zip \
    "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.4.0/mule-standalone-4.4.0.zip" && \
    unzip mule-standalone-4.4.0.zip && \
    mv mule-standalone-4.4.0/* /opt/mule/ && \
    rm -rf /tmp/* mule-standalone-4.4.0.zip && \
    chmod +x /opt/mule/bin/mule

WORKDIR /opt/mule
COPY target/employee-onboarding-agent-broker-*-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV MULE_HOME=/opt/mule JAVA_OPTS="-Xms1g -Xmx2g"
ENV http.host=0.0.0.0 http.port=8080 agent.broker.orchestration.enabled=true
ENV mcp.serverName=agent-broker mcp.serverVersion=1.0.1 agent.fabric.enabled=true mcp.central.broker=true

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s CMD curl -f http://localhost:8080/mcp/health || exit 1
CMD ["/opt/mule/bin/mule"]
