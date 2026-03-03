FROM mandius/mule-rt-4.9.6:latest

WORKDIR /opt/mule

COPY target/email-notification-mcp-*-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV http.host=0.0.0.0 \
    http.port=8083 \
    mcp.serverName=notification-mcp \
    agent.fabric.enabled=true

ENV email.smtp.host=smtp.gmail.com \
    email.smtp.port=587 \
    email.from=noreply@company.com

EXPOSE 8083

HEALTHCHECK --interval=30s CMD curl -f http://localhost:8083/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
