# Agent Broker MCP URL Path Issue - Complete Solution

## Problem Identified

The URL `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding` is returning a "Method Not Allowed" error because of a **URL path mismatch** in the Mule application configuration.

## Root Cause Analysis

After analyzing the agent broker MCP server configuration, I found the following issues:

### 1. Dual Flow Configuration Problem
The application has **two different flow configurations**:

**Configuration A: Direct HTTP Listeners (employee-onboarding-agent-broker.xml)**
- Path: `/mcp/tools/orchestrate-employee-onboarding`
- Full URL: `https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding`

**Configuration B: APIKit Router (agent-broker-apikit-router.xml)**
- Path: `/api/*` (APIKit router)
- Full URL: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding`

### 2. Path Conflict
The OpenAPI specification defines the endpoint as:
```yaml
/mcp/tools/orchestrate-employee-onboarding
```

But the APIKit router is configured to handle:
```xml
<http:listener config-ref="http-config" path="/api/*" />
```

This creates a path conflict where:
- **Direct flows** expect: `/mcp/tools/orchestrate-employee-onboarding`
- **APIKit flows** expect: `/api/mcp/tools/orchestrate-employee-onboarding`

### 3. Current Status
The application appears to be using the APIKit router configuration, which means the correct URLs should be:

- **Health Check**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health`
- **MCP Info**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info`
- **Orchestrate Onboarding**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding`
- **Get Status**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/get-onboarding-status`
- **Retry Step**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/retry-failed-step`

## Solutions

### Solution 1: Update OpenAPI Specification (Recommended)
Update the OpenAPI specification to include the `/api` prefix:

```yaml
paths:
  /api/health:
    get:
      # ... existing configuration

  /api/mcp/info:
    get:
      # ... existing configuration

  /api/mcp/tools/orchestrate-employee-onboarding:
    post:
      # ... existing configuration

  /api/mcp/tools/get-onboarding-status:
    post:
      # ... existing configuration

  /api/mcp/tools/retry-failed-step:
    post:
      # ... existing configuration
```

### Solution 2: Update APIKit Router Path
Change the APIKit router to handle the root path:

```xml
<http:listener config-ref="http-config" path="/*" doc:name="HTTP Listener">
```

### Solution 3: Remove Dual Configuration
Choose one configuration approach and remove the other:

**Option A: Keep APIKit Router Only**
- Remove the direct HTTP listener flows in `employee-onboarding-agent-broker.xml`
- Keep the APIKit router configuration
- Update all client URLs to include `/api` prefix

**Option B: Keep Direct HTTP Listeners Only**
- Remove the APIKit router configuration
- Keep the direct HTTP listener flows
- Update URLs to remove `/api` prefix

## Recommended Implementation

### Step 1: Update OpenAPI Specification
Update `employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/src/main/resources/api/agent-broker-mcp-api.yaml`:

```yaml
servers:
  - url: http://localhost:8084/api
    description: Local development server
  - url: https://agent-broker-mcp.cloudhub.io/api
    description: Production CloudHub server

paths:
  /health:
    get:
      # ... existing configuration

  /mcp/info:
    get:
      # ... existing configuration

  /mcp/tools/orchestrate-employee-onboarding:
    post:
      # ... existing configuration
```

### Step 2: Update Client Applications
Update all client applications and documentation to use the correct URLs with `/api` prefix.

### Step 3: Test the Corrected Endpoints

**Test Health Check:**
```bash
curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
```

**Test MCP Info:**
```bash
curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info"
```

**Test Orchestrate Onboarding:**
```bash
curl -X POST "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"test@example.com"}'
```

## Implementation Priority

1. **High Priority**: Update OpenAPI specification and redeploy
2. **Medium Priority**: Update client applications and documentation
3. **Low Priority**: Consider consolidating to single configuration approach

## Expected Outcomes

After implementing these changes:
- The "Method Not Allowed" error will be resolved
- All endpoints will be accessible via the correct `/api/*` paths
- The application will have consistent URL routing
- Client applications will work correctly with the updated URLs

## Testing Validation

Once deployed, validate using these URLs:
- `GET https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health`
- `GET https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info`
- `POST https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding`

## Additional Notes

- The 504 Gateway Timeout error suggests the application may also have connectivity issues with downstream services
- Ensure all dependent MCP servers (Employee Onboarding, Asset Allocation, Notification) are running and accessible
- Review CloudHub application logs for additional error details
- Consider implementing health checks for dependent services

## Files to Update

1. `employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/src/main/resources/api/agent-broker-mcp-api.yaml`
2. Client applications using these endpoints
3. Documentation and integration guides
4. Postman collections and test scripts
