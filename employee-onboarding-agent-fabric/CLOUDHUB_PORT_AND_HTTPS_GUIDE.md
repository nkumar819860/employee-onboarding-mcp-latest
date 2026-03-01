# CloudHub Port 8081 and HTTPS Behavior Guide

## Why CloudHub Exposes HTTP When Using Port 8081

### CloudHub Port Mapping Behavior

**CloudHub has specific port mapping rules that determine HTTP vs HTTPS exposure:**

1. **Port 8081 → HTTP Only**: When your Mule application listens on port 8081, CloudHub automatically maps this to HTTP (port 80) on the public endpoint
2. **Port 8082 → HTTPS Only**: When your application listens on port 8082, CloudHub maps this to HTTPS (port 443) on the public endpoint
3. **Port 8091 → HTTP**: Alternative HTTP port mapping
4. **Port 8092 → HTTPS**: Alternative HTTPS port mapping

### Current Configuration Analysis

Looking at your `config.properties` file:
```properties
# HTTP Configuration
http.host=0.0.0.0
http.port=8081
```

And your `global.xml` HTTP listener:
```xml
<http:listener-config name="HTTP_Listener_config">
    <http:listener-connection 
        host="${http.host}" 
        port="${http.port}"
        protocol="HTTP"/>
</http:listener-config>
```

**This configuration results in:**
- Internal port: 8081 (HTTP)
- CloudHub public endpoint: `http://your-app.cloudhub.io` (HTTP only)
- **No HTTPS access available**

## Solutions for HTTPS Configuration

### Solution 1: Change Port to 8082 (Recommended)

#### Step 1: Update config.properties
```properties
# HTTP Configuration for HTTPS
http.host=0.0.0.0
http.port=8082
```

#### Step 2: Update global.xml (Optional - already uses property)
The global.xml already references `${http.port}`, so it will automatically pick up the new port.

#### Step 3: Update mcp.server.baseUrl
```properties
mcp.server.baseUrl=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
```

### Solution 2: Dual Port Configuration (HTTP + HTTPS)

If you need both HTTP and HTTPS endpoints:

#### Update config.properties:
```properties
# HTTP Configuration
http.host=0.0.0.0
http.port=8081
https.host=0.0.0.0
https.port=8082
```

#### Update global.xml:
```xml
<!-- HTTP Listener for HTTP -->
<http:listener-config name="HTTP_Listener_config">
    <http:listener-connection 
        host="${http.host}" 
        port="${http.port}"
        protocol="HTTP"/>
</http:listener-config>

<!-- HTTPS Listener for HTTPS -->
<http:listener-config name="HTTPS_Listener_config">
    <http:listener-connection 
        host="${https.host}" 
        port="${https.port}"
        protocol="HTTP"/>
</http:listener-config>
```

#### Update your flows to use both listeners:
```xml
<flow name="your-api-flow">
    <!-- HTTP endpoint -->
    <http:listener config-ref="HTTP_Listener_config" path="/api/*"/>
    <!-- Your flow logic -->
</flow>

<flow name="your-api-flow-https">
    <!-- HTTPS endpoint -->
    <http:listener config-ref="HTTPS_Listener_config" path="/api/*"/>
    <!-- Same flow logic as HTTP -->
</flow>
```

### Solution 3: HTTPS Only Configuration (Most Secure)

#### Update config.properties:
```properties
# HTTPS Configuration Only
http.host=0.0.0.0
http.port=8082
mcp.server.baseUrl=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
```

## CloudHub Port Mapping Reference

| Internal Port | External Protocol | External Port | Public URL Format |
|---------------|------------------|---------------|-------------------|
| 8081 | HTTP | 80 | `http://app-name.cloudhub.io` |
| 8082 | HTTPS | 443 | `https://app-name.cloudhub.io` |
| 8091 | HTTP | 80 | `http://app-name.cloudhub.io` |
| 8092 | HTTPS | 443 | `https://app-name.cloudhub.io` |

## Implementation Steps

### Quick Fix for HTTPS (Port 8082)

1. **Update all MCP servers** to use port 8082:
   ```bash
   # Update employee-onboarding-mcp
   # Update asset-allocation-mcp  
   # Update notification-mcp
   # Update agent-broker-mcp
   ```

2. **Update client configurations** to use HTTPS URLs

3. **Redeploy applications** to CloudHub

### Configuration Files to Update

For each MCP server, update these files:

1. **config.properties**:
   ```properties
   http.port=8082
   mcp.server.baseUrl=https://[app-name].us-e1.cloudhub.io
   ```

2. **React Client Environment Files**:
   ```javascript
   // .env.production
   REACT_APP_API_BASE_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
   REACT_APP_ASSET_API_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
   REACT_APP_NOTIFICATION_API_URL=https://notification-mcp-server.us-e1.cloudhub.io
   REACT_APP_AGENT_BROKER_URL=https://agent-broker-mcp-server.us-e1.cloudhub.io
   ```

## Security Benefits of HTTPS

1. **Data Encryption**: All data transmitted between client and server is encrypted
2. **Authentication**: Verifies the server identity
3. **Data Integrity**: Prevents man-in-the-middle attacks
4. **Compliance**: Required for many enterprise and regulatory standards
5. **SEO Benefits**: Search engines favor HTTPS sites
6. **Browser Trust**: Modern browsers warn users about HTTP sites

## Testing HTTPS Configuration

### Test Commands
```bash
# Test HTTPS endpoint
curl -X GET https://your-app.us-e1.cloudhub.io/api/health

# Verify SSL certificate
openssl s_client -connect your-app.us-e1.cloudhub.io:443

# Test with browser
# Navigate to: https://your-app.us-e1.cloudhub.io/api/health
```

## Common Issues and Solutions

### Issue 1: Mixed Content Warnings
**Problem**: HTTPS API called from HTTP frontend
**Solution**: Ensure both frontend and API use HTTPS

### Issue 2: Certificate Errors
**Problem**: SSL certificate issues
**Solution**: CloudHub automatically provides valid SSL certificates for *.cloudhub.io domains

### Issue 3: CORS Issues with HTTPS
**Problem**: CORS errors when switching to HTTPS
**Solution**: Update CORS configuration to allow HTTPS origins:

```xml
<http:listener-interceptors>
    <http:cors-interceptor>
        <http:cors-interceptor-configuration>
            <http:origins>
                <http:origin url="https://your-frontend-domain.com"/>
            </http:origins>
            <http:methods>
                <http:method method="GET"/>
                <http:method method="POST"/>
                <http:method method="PUT"/>
                <http:method method="DELETE"/>
                <http:method method="OPTIONS"/>
            </http:methods>
        </http:cors-interceptor-configuration>
    </http:cors-interceptor>
</http:listener-interceptors>
```

## Deployment Checklist

- [ ] Update config.properties with port 8082
- [ ] Update mcp.server.baseUrl to use HTTPS
- [ ] Update client environment variables
- [ ] Test local configuration
- [ ] Deploy to CloudHub
- [ ] Verify HTTPS endpoints work
- [ ] Update API documentation
- [ ] Update Postman collections
- [ ] Test end-to-end functionality

## Best Practices

1. **Always use HTTPS in production** - Port 8082
2. **Use HTTP only for development/testing** - Port 8081
3. **Implement proper CORS configuration**
4. **Update all client configurations consistently**
5. **Test thoroughly after port changes**
6. **Monitor SSL certificate expiration** (handled automatically by CloudHub)

---

**Summary**: CloudHub uses port 8081 for HTTP and port 8082 for HTTPS. To enable HTTPS access, change your application's port from 8081 to 8082 and update all client configurations accordingly.
