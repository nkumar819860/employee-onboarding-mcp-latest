FROM eclipse-temurin:17-jre

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/mule && cd /tmp && \
    curl -L -o mule-standalone-4.6.0.zip \
    "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.6.0/mule-standalone-4.6.0.zip" && \
    unzip mule-standalone-4.6.0.zip && \
    mv mule-standalone-4.6.0/* /opt/mule/ && \
    rm -rf /tmp/* mule-standalone-4.6.0.zip && \
    chmod +x /opt/mule/bin/mule

WORKDIR /opt/mule
COPY target/notification-mcp-server-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV MULE_HOME=/opt/mule JAVA_OPTS="-Xms512m -Xmx1024m"
ENV http.host=0.0.0.0 http.port=8083 mcp.serverName=notification-mcp agent.fabric.enabled=true
ENV email.smtp.host=smtp.gmail.com email.smtp.port=587 email.from=noreply@company.com
ENV db.driverClassName=org.postgresql.Driver

EXPOSE 8083
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8083/mcp/health || exit 1
CMD ["/opt/mule/bin/mule"]
