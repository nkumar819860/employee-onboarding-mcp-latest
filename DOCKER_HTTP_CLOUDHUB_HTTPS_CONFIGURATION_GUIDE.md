# Docker HTTP vs CloudHub HTTPS Configuration Guide

## Overview

This guide explains the dual HTTP/HTTPS configuration strategy for the Employee Onboarding MCP services, where:
- **Docker Environment**: Uses HTTP for development and testing
- **CloudHub Environment**: Uses HTTPS with self-signed JKS certificates for production

## Configuration Architecture

### 1. Environment-Aware HTTP Listener Configuration

The `global.xml` files now contain two listener configurations:

```xml
<!-- HTTP Listener for Docker/Development Environment -->
<http:listener-config name="HTTP_Listener_config" doc:name="HTTP Listener config">
    <http:listener-connection host="${http.host}" port="${http.port}" protocol="HTTP"/>
</http:listener-config>

<!-- HTTPS Listener for CloudHub/Production (with JKS) -->
<http:listener-config name="HTTPS_Listener_config" doc:name="HTTPS Listener config">
    <http:listener-connection host="${http.host}" port="${https.port}" protocol="HTTPS">
        <tls:context name="tls-context">
            <tls:key-store type="jks" path="server.jks"
                keyPassword="MULEPASS" password="MULEPASS" alias="mule-server" />
        </tls:context>
    </http:listener-connection>
</http:listener-config>
```

### 2. Environment-Specific Properties

#### Docker Configuration (`config.properties`)
```properties
# Environment Configuration
env=Docker
deployment.target=docker

# Protocol Strategy
protocol.strategy=http
tls.enabled=false

# HTTP Configuration
http.host=0.0.0.0
http.port=8081
https.port=8082
```

#### CloudHub Configuration (Runtime Properties)
```properties
# Environment Configuration
env=Production
deployment.target=cloudhub

# Protocol Strategy
protocol.strategy=https
tls.enabled=true

# HTTPS Configuration
http.host=0.0.0.0
http.port=8081
https.port=443
```

## Port Mapping Strategy

### Docker Environment
| Service | Internal Port | External Port | Protocol |
|---------|---------------|---------------|----------|
| Employee Onboarding MCP | 8081 | 8081 | HTTP |
| Assets Allocation MCP | 8082 | 8082 | HTTP |
| Email Notification MCP | 8083 | 8083 | HTTP |
| Agent Broker MCP | 8080 | 8080 | HTTP |
| React Client | 3000 | 3000 | HTTP |

### CloudHub Environment
| Service | Port | Protocol | JKS Required |
|---------|------|----------|--------------|
| Employee Onboarding MCP | 443 | HTTPS | Yes |
| Assets Allocation MCP | 443 | HTTPS | Yes |
| Email Notification MCP | 443 | HTTPS | Yes |
| Agent Broker MCP | 443 | HTTPS | Yes |

## JKS Certificate Configuration

### Self-Signed JKS Creation
For CloudHub deployment, create self-signed JKS certificates:

```bash
keytool -genkey -alias mule-server -keyalg RSA -keystore server.jks -keysize 2048 -validity 365
```

### JKS Properties
- **File Location**: `src/main/resources/server.jks`
- **Keystore Password**: `MULEPASS`
- **Key Password**: `MULEPASS`
- **Alias**: `mule-server`

## Docker Compose Configuration

The `docker-compose.yml` is configured for HTTP-only communication:

```yaml
employee-onboarding-mcp-server:
  ports:
    - "${EMPLOYEE_HTTP_PORT:-8081}:8081"
  environment:
    - http.host=0.0.0.0
    - http.port=8081
    - protocol.strategy=http
    - tls.enabled=false
```

## Flow Configuration

### Using the Correct Listener

For flows that need to work in both environments, use the appropriate listener reference:

#### Docker Flows (HTTP)
```xml
<http:listener config-ref="HTTP_Listener_config" path="/api/*" doc:name="HTTP Listener"/>
```

#### CloudHub Flows (HTTPS)
```xml
<http:listener config-ref="HTTPS_Listener_config" path="/api/*" doc:name="HTTPS Listener"/>
```

## Testing Configuration

### Docker HTTP Testing
Use the provided test script:
```bash
./test-docker-http-endpoints-fixed.bat
```

This tests all HTTP endpoints:
- http://localhost:8081 (Employee Onboarding)
- http://localhost:8082 (Assets Allocation)
- http://localhost:8083 (Email Notification)
- http://localhost:8080 (Agent Broker)
- http://localhost:3000 (React Client)

### CloudHub HTTPS Testing
CloudHub endpoints will be:
- https://employee-onboarding-mcp-server.us-e1.cloudhub.io
- https://assets-allocation-mcp-server.us-e1.cloudhub.io
- https://email-notification-mcp-server.us-e1.cloudhub.io
- https://agent-broker-mcp-server.us-e1.cloudhub.io

## Deployment Workflows

### Docker Deployment
1. Use HTTP listeners only
2. No JKS certificates required
3. Standard Docker port mapping
4. Environment variables set for HTTP mode

```bash
docker-compose up -d
```

### CloudHub Deployment
1. Package JKS certificates in JAR
2. Configure HTTPS listeners
3. Set CloudHub runtime properties
4. Deploy with TLS enabled

```bash
mvn clean package deploy -DmuleDeploy \
  -Dmule.env=Production \
  -Dprotocol.strategy=https \
  -Dtls.enabled=true
```

## Security Considerations

### Docker Environment
- ✅ HTTP is acceptable for local development
- ✅ No certificate management overhead
- ✅ Fast iteration and testing
- ⚠️ Not suitable for production traffic

### CloudHub Environment
- ✅ HTTPS ensures data encryption in transit
- ✅ Self-signed certificates acceptable for internal services
- ✅ Production-grade security
- ⚠️ Certificate lifecycle management required

## Troubleshooting

### Common Docker Issues
1. **Port Conflicts**: Ensure no other services use ports 8080-8083, 3000
2. **Protocol Mismatch**: Verify flows use HTTP_Listener_config
3. **Container Health**: Check Docker health status

### Common CloudHub Issues
1. **JKS Not Found**: Ensure server.jks is in src/main/resources
2. **Certificate Errors**: Verify keystore and key passwords match
3. **Port 443**: CloudHub automatically maps to port 443

## Best Practices

### Development Workflow
1. Develop and test locally with Docker HTTP
2. Use consistent API contracts between environments
3. Validate with Postman collections for both protocols
4. Test environment switching frequently

### Production Deployment
1. Always use HTTPS for CloudHub
2. Regularly rotate JKS certificates
3. Monitor certificate expiration
4. Implement proper error handling for TLS issues

### Configuration Management
1. Use environment-specific property files
2. Externalize sensitive configuration (passwords, certificates)
3. Implement configuration validation
4. Document environment differences clearly

## Conclusion

This dual-protocol approach provides:
- **Flexibility**: Easy switching between development and production
- **Security**: Proper HTTPS for production while maintaining development simplicity
- **Performance**: Optimal configuration for each environment
- **Maintainability**: Clear separation of concerns and configuration

The configuration supports your preferred approach of using HTTPS with self-signed JKS in production while allowing HTTP for Docker-based development and testing.
