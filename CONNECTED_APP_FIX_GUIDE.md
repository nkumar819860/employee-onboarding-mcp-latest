# Connected App Authentication Fix Guide

## Current Issue: "Missing credentials" Error
The HR-MCP-Deployment Connected App is not authenticating properly with Anypoint Platform.

## Root Cause Analysis
Based on the test results, the Connected App either:
1. **Missing required scopes** for CloudHub deployment
2. **Incorrect authentication endpoint** or method
3. **Connected App not properly activated**

## 🔧 IMMEDIATE FIX STEPS:

### Step 1: Verify Connected App Configuration
Login to Anypoint Platform → Access Management → Connected Apps → HR-MCP-Deployment

**REQUIRED SCOPES** (check ALL of these):
```
✅ openid
✅ profile
✅ read:full
✅ write:full
✅ cloudhub:applications:write
✅ cloudhub:applications:read
✅ cloudhub:application-logs:read
✅ runtime-manager:applications:write
✅ runtime-manager:applications:read
✅ anypoint-mq:applications:write
✅ exchange:assets:read
```

### Step 2: Alternative Authentication Test
Try this corrected curl command:
```cmd
curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "client_id=aec0b3117f7d4d4e8433a7d3d23bc80e&client_secret=9bc9D86a77b343b98a148C0313239aDA&grant_type=client_credentials"
```

### Step 3: Manual CloudHub Deployment (RECOMMENDED)
Since builds are working, deploy manually:

1. **Go to CloudHub Console**: https://anypoint.mulesoft.com/cloudhub
2. **Click "Deploy Application"**
3. **Upload JAR files** from these locations:
   - `employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp\target\employee-onboarding-mcp-1.0.3-mule-application.jar`
   - `employee-onboarding-agent-fabric\mcp-servers\asset-allocation-mcp\target\*-mule-application.jar`
   - `employee-onboarding-agent-fabric\mcp-servers\notification-mcp\target\*-mule-application.jar`
   - `employee-onboarding-agent-fabric\mcp-servers\agent-broker-mcp\target\*-mule-application.jar`

4. **Configure each application**:
   - **Application Name**: `employee-onboarding-mcp-server`, etc.
   - **Environment**: `Sandbox`
   - **Runtime Version**: `4.9.4`
   - **Worker Size**: `0.1 vCores (MICRO)`
   - **Workers**: `1`

## 🚀 ALTERNATIVE: Use Anypoint CLI
If Connected App still doesn't work:

```cmd
# Install Anypoint CLI
npm install -g anypoint-cli

# Login with your Anypoint credentials (username/password)
anypoint-cli-v4 account login

# Deploy using CLI
anypoint-cli-v4 runtime-mgr cloudhub-application deploy ^
  --applicationName employee-onboarding-mcp-server ^
  --environment Sandbox ^
  --runtime 4.9.4 ^
  --workers 1 ^
  --workerType MICRO ^
  --region us-east-1 ^
  employee-onboarding-agent-fabric\mcp-servers\employee-onboarding-mcp\target\employee-onboarding-mcp-1.0.3-mule-application.jar
```

## ✅ SUCCESS CRITERIA
After deployment, these URLs should be accessible:
- https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
- https://asset-allocation-mcp-server.us-e1.cloudhub.io/health  
- https://notification-mcp-server.us-e1.cloudhub.io/health
- https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health

## 🎯 RECOMMENDED ACTION
**Manual upload via CloudHub Console** is the fastest path to success since all JAR files are ready!
