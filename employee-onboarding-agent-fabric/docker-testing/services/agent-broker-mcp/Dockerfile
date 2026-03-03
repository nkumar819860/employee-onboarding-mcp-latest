FROM mandius/mule-rt-4.9.6:latest

WORKDIR /opt/mule

COPY target/agent-broker-mcp-*-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV http.host=0.0.0.0 \
    http.port=8084 \
    mcp.serverName=agent-broker \
    agent.fabric.enabled=true

EXPOSE 8084

HEALTHCHECK --interval=30s CMD curl -f http://localhost:8084/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
