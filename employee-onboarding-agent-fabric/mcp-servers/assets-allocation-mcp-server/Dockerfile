FROM mandius/mule-rt-4.9.6:latest

WORKDIR /opt/mule

COPY target/assets-allocation-mcp-*-*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

ENV http.host=0.0.0.0 \
    http.port=8082 \
    mcp.serverName=asset-mcp \
    agent.fabric.enabled=true

ENV db.driverClassName=org.postgresql.Driver \
    dbType=postgres

EXPOSE 8082

HEALTHCHECK --interval=30s CMD curl -f http://localhost:8082/mcp/health || exit 1

CMD ["/opt/mule/bin/mule"]
