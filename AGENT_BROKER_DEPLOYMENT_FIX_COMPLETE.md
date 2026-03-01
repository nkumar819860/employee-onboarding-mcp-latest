# Agent Broker MCP Complete Deployment Fix

## Critical Issues Identified

Based on the deployment error and analysis, there are **two major issues** that need to be resolved:

### Issue 1: Mule Artifact Configuration Error
```
Error: Failed to deploy artifact [agent-broker-mcp-server]. InstallException: Config for app 'agent-broker-mcp-server' not found: employee-onboarding-agent-broker.xml
```

### Issue 2: URL Path Mismatch (Method Not Allowed)
The application has conflicting flow configurations causing routing issues.

## Root Cause Analysis

### 1. Mule Artifact Configuration Problem
The `mule-artifact.json` references both configuration files:
```json
{
  "configs": [
    "employee-onboarding-agent-broker.xml",
    "global.xml"
  ]
}
```

But the deployment suggests there's an issue with the `employee-onboarding-agent-broker.xml` file reference.

### 2. Dual Flow Configuration Conflict
- **APIKit Router**: Handles `/api/*` paths (in `agent-broker-apikit-router.xml`)
- **Direct HTTP Listeners**: Handle root paths (in `employee-onboarding-agent-broker.xml`)

## Complete Solution

### Step 1: Fix Mule Artifact Configuration
Update the `mule-artifact.json` to use only the APIKit router configuration:

```json
{
  "name": "agent-broker-mcp-server",
  "minMuleVersion": "4.4.0",
  "javaSpecificationVersions": [
    "17"
  ],
  "requiredProduct": "MULE_EE",
  "classLoaderModelLoaderDescriptor": {
    "id": "mule",
    "attributes": {
      "exportedResources": []
    }
  },
  "bundleDescriptorLoader": {
    "id": "mule",
    "attributes": {}
  },
  "configs": [
    "agent-broker-apikit-router.xml",
    "global.xml"
  ]
}
```

### Step 2: Update OpenAPI Specification
Update the server URLs in `agent-broker-mcp-api.yaml` to include the `/api` prefix:

```yaml
servers:
  - url: http://localhost:8084/api
    description: Local development server
  - url: https://agent-broker-mcp-server.us-e1.cloudhub.io/api
    description: Production CloudHub server
```

### Step 3: Verify File Structure
Ensure all required files exist in the correct locations:
- ✅ `src/main/mule/agent-broker-apikit-router.xml`
- ✅ `src/main/mule/global.xml`
- ✅ `src/main/resources/api/agent-broker-mcp-api.yaml`

## Implementation Steps

### 1. Update mule-artifact.json
```json
{
  "name": "agent-broker-mcp-server",
  "minMuleVersion": "4.4.0",
  "javaSpecificationVersions": [
    "17"
  ],
  "requiredProduct": "MULE_EE",
  "classLoaderModelLoaderDescriptor": {
    "id": "mule",
    "attributes": {
      "exportedResources": []
    }
  },
  "bundleDescriptorLoader": {
    "id": "mule",
    "attributes": {}
  },
  "configs": [
    "agent-broker-apikit-router.xml",
    "global.xml"
  ]
}
```

### 2. Update OpenAPI Server URLs
In `agent-broker-mcp-api.yaml`, update the servers section:

```yaml
servers:
  - url: http://localhost:8084/api
    description: Local development server
  - url: https://agent-broker-mcp-server.us-e1.cloudhub.io/api
    description: Production CloudHub server
```

### 3. Redeploy to CloudHub
After making these changes, redeploy the application to CloudHub.

## Correct Endpoint URLs After Fix

Once deployed with these fixes, the correct URLs will be:

- **Health Check**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health`
- **MCP Info**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info` 
- **Orchestrate Onboarding**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding`
- **Get Status**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/get-onboarding-status`
- **Retry Step**: `https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/retry-failed-step`

## Testing the Fix

### Test Deployment Health
```bash
curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/health"
```

### Test MCP Info
```bash
curl -X GET "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/info"
```

### Test Orchestrate Onboarding
```bash
curl -X POST "https://agent-broker-mcp-server.us-e1.cloudhub.io/api/mcp/tools/orchestrate-employee-onboarding" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User", 
    "email": "test@example.com",
    "department": "IT",
    "position": "Software Engineer"
  }'
```

## Why This Fix Works

### 1. Eliminates Configuration Conflict
By using only the APIKit router configuration, we eliminate the conflict between dual flow configurations.

### 2. Provides Consistent URL Routing  
All endpoints will consistently use the `/api/*` path prefix.

### 3. Fixes Deployment Error
The mule-artifact.json will only reference existing, valid configuration files.

### 4. Maintains Full Functionality
All MCP server capabilities remain intact while fixing the routing issues.

## Expected Results

After implementing this fix:
- ✅ Application will deploy successfully to CloudHub
- ✅ All endpoints will be accessible via `/api/*` paths
- ✅ "Method Not Allowed" errors will be resolved
- ✅ Complete employee onboarding orchestration will work
- ✅ All dependent service integrations will function correctly

## Additional Benefits

- **Simplified Configuration**: Single flow configuration approach
- **Better Maintainability**: No conflicting configurations to manage
- **Consistent API Structure**: All endpoints follow the same URL pattern
- **Improved Documentation**: OpenAPI spec accurately reflects actual endpoints

## Files to Modify

1. `employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/mule-artifact.json`
2. `employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/src/main/resources/api/agent-broker-mcp-api.yaml`

## Next Steps

1. **Apply the configuration changes** as outlined above
2. **Redeploy** the agent-broker-mcp-server to CloudHub  
3. **Test all endpoints** using the corrected URLs
4. **Update client applications** to use the new URL patterns
5. **Update documentation** to reflect the correct endpoint URLs

This comprehensive fix addresses both the deployment failure and the API routing issues, providing a stable, working MCP server deployment.
