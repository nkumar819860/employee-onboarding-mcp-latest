# ✅ FIXED - Java 17 Full Runtime (ALL 4 services)
FROM eclipse-temurin:17-jre-full

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download Mule CE 4.6 (matches Java 17)
RUN mkdir -p /opt/mule && cd /tmp && \
    curl -L -o mule-standalone-4.6.0.zip \
    "https://repository.mulesoft.org/nexus/content/repositories/releases/org/mule/distributions/mule-standalone/4.6.0/mule-standalone-4.6.0.zip" && \
    unzip mule-standalone-4.6.0.zip && \
    mv mule-standalone-4.6.0/* /opt/mule/ && \
    rm -rf /tmp/* mule-standalone-4.6.0.zip && \
    chmod +x /opt/mule/bin/mule

WORKDIR /opt/mule
COPY target/*.jar /opt/mule/apps/
COPY src/main/resources/ /opt/mule/apps/classes/

# Force Java 17
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

ENV MULE_HOME=/opt/mule JAVA_OPTS="-Xms1g -Xmx2g"
ENV http.host=0.0.0.0 http.port=8080

EXPOSE 8080
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8080/mcp/health || exit 1
CMD ["/opt/mule/bin/mule"]
