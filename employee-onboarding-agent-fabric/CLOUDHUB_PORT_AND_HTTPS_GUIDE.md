# CloudHub Port and HTTPS Configuration Guide

## CloudHub Port Behavior

### Default CloudHub Ports:
- **HTTP**: Port 8081 (default internal port)
- **HTTPS**: Port 8082 (default internal port with CloudHub-managed certificates)
- **External Access**: CloudHub automatically maps these to standard ports:
  - HTTP external access: Port 80 (but redirects to HTTPS)
  - HTTPS external access: Port 443

## Certificate Management

### CloudHub Managed Certificates (Recommended):
- **Automatic**: CloudHub provides free SSL certificates for `*.cloudhub.io` domains
- **No Setup Required**: Certificates are automatically provisioned and renewed
- **Port 8082**: Internal applications should listen on port 8082 for HTTPS
- **External Access**: Automatically available on standard port 443

### Custom Certificates:
- **Custom Domains**: Required for custom domain names (not `*.cloudhub.io`)
- **Manual Setup**: You need to upload and manage your own certificates
- **Cost**: Additional charges may apply

## Configuration Options for MCP Services

### Option 1: CloudHub Default HTTPS (Recommended)
```properties
# Internal HTTPS with CloudHub certificates (port 8082 internally, 443 externally)
employee.onboarding.mcp.url=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
asset.allocation.mcp.url=https://asset-allocation-mcp-server.us-e1.cloudhub.io
notification.mcp.url=https://notification-mcp-server.us-e1.cloudhub.io
```

### Option 2: Explicit Port 8081 (HTTP Only - Not Recommended for Production)
```properties
# Internal HTTP (port 8081 internally, 80 externally)
employee.onboarding.mcp.url=http://employee-onboarding-mcp-server.us-e1.cloudhub.io:8081
asset.allocation.mcp.url=http://asset-allocation-mcp-server.us-e1.cloudhub.io:8081
notification.mcp.url=http://notification-mcp-server.us-e1.cloudhub.io:8081
```

### Option 3: Explicit Port 8082 (HTTPS with CloudHub Certificates)
```properties
# Internal HTTPS with explicit port
employee.onboarding.mcp.url=https://employee-onboarding-mcp-server.us-e1.cloudhub.io:8082
asset.allocation.mcp.url=https://asset-allocation-mcp-server.us-e1.cloudhub.io:8082
notification.mcp.url=https://notification-mcp-server.us-e1.cloudhub.io:8082
```

## Your Question: Port 8091 and HTTPS

**No, port 8091 will NOT automatically use HTTPS**. Here's why:

1. **Port Number ≠ Protocol**: The port number doesn't determine the protocol (HTTP vs HTTPS)
2. **URL Scheme Matters**: The `https://` vs `http://` in the URL determines the protocol
3. **CloudHub Standard Ports**: CloudHub uses 8081 (HTTP) and 8082 (HTTPS) as standard internal ports

## Recommendations for Your Setup

### For Production (Recommended):
```properties
# Use HTTPS without explicit ports (CloudHub handles certificate management)
employee.onboarding.mcp.url=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
asset.allocation.mcp.url=https://asset-allocation-mcp-server.us-e1.cloudhub.io
notification.mcp.url=https://notification-mcp-server.us-e1.cloudhub.io
```

### For Testing/Development (If HTTPS causes issues):
```properties
# Use HTTP with explicit port 8081
employee.onboarding.mcp.url=http://employee-onboarding-mcp-server.us-e1.cloudhub.io:8081
asset.allocation.mcp.url=http://asset-allocation-mcp-server.us-e1.cloudhub.io:8081
notification.mcp.url=http://notification-mcp-server.us-e1.cloudhub.io:8081
```

## Certificate Requirements

### For HTTPS (No Custom Setup Required):
- ✅ **CloudHub Managed**: Automatic SSL certificates for `*.cloudhub.io` domains
- ✅ **Free**: No additional cost
- ✅ **Automatic Renewal**: CloudHub handles certificate lifecycle
- ✅ **Standard Compliance**: Trusted by all browsers and HTTP clients

### When You Need Custom Certificates:
- 🔧 **Custom Domains**: Only if using custom domain names (not `*.cloudhub.io`)
- 🔧 **Corporate Policies**: If your organization requires specific certificate authorities
- 🔧 **Advanced Security**: For specific compliance requirements

## Troubleshooting the Original Port 80 Error

The error you encountered was likely because:
1. **Wrong Protocol**: Using `http://` instead of `https://`
2. **No Port Specified**: CloudHub tried to use default port 80 for HTTP
3. **Service Not Listening**: Your services are likely configured for port 8081 (HTTP) or 8082 (HTTPS)

## Next Steps

Choose one of these configurations based on your needs:
1. **Production**: Use HTTPS without explicit ports (current fix)
2. **Development**: Use HTTP with explicit port 8081 (alternative)
3. **Secure Development**: Use HTTPS with explicit port 8082
