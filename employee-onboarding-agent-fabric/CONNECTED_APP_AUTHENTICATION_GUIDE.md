# Connected App Authentication Fix Guide

## Problem Description

When using the original deployment command:
```bash
mvn clean mule:deploy -Danypoint.client.id=aec0b3117f7d4d4e8433a7d3d23bc80e -Danypoint.client.secret=9bc9D86a77b343b98a148C0313239aDA
```

The issue was that Maven was treating the client ID and secret as **username/password credentials** instead of using the proper **Connected App authentication** configured in `settings.xml`.

## Root Cause

- When you pass `-Danypoint.client.id` and `-Danypoint.client.secret` as command-line parameters, Maven interprets them as direct credentials
- This bypasses the Connected App authentication mechanism configured in your Maven `settings.xml` file
- The Mule Maven plugin expects to use the server configuration from `settings.xml` for proper Connected App authentication

## Current Settings Configuration (✅ CORRECT)

Your `~/.m2/settings.xml` is properly configured for Connected App authentication:

```xml
<server>
  <id>CloudHub</id>
  <username>~~~Client~~~</username>
  <password>aec0b3117f7d4d4e8433a7d3d23bc80e~~~9bc9D86a77b343b98a148C0313239aDA</password>
</server>
```

The special format `~~~Client~~~` as username and `clientId~~~clientSecret` as password tells Maven to use Connected App authentication.

## Solution

### ✅ Use the Corrected Deployment Command

**Instead of passing client credentials on command line:**
```bash
# ❌ WRONG - This treats credentials as username/password
mvn clean mule:deploy -Danypoint.client.id=... -Danypoint.client.secret=...
```

**Use the corrected command that relies on settings.xml:**
```bash
# ✅ CORRECT - Uses Connected App from settings.xml
mvn clean mule:deploy \
    -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 \
    -Danypoint.environment=Sandbox \
    -DmuleDeploy \
    -DskipTests \
    -Dcloudhub.application.name=notification-mcp-server \
    -Dcloudhub.runtime=4.5.0 \
    -Dcloudhub.java.version=17 \
    -U -X
```

### ✅ Use the Deployment Script

Run the pre-configured script:
```bash
employee-onboarding-agent-fabric/deploy-notification-connected-app.bat
```

This script uses the correct parameters and lets Maven authenticate using your Connected App configuration from `settings.xml`.

## Key Differences

| Parameter | Old (Wrong) | New (Correct) |
|-----------|-------------|---------------|
| Authentication | Command line client.id/secret | settings.xml CloudHub server |
| Client ID | `-Danypoint.client.id=...` | From settings.xml server config |
| Client Secret | `-Danypoint.client.secret=...` | From settings.xml server config |
| Business Group | `-Danypoint.business.group=...` | `-Danypoint.businessGroup=...` |

## Verification Steps

1. **Check Maven Settings**: Ensure your `~/.m2/settings.xml` has the CloudHub server configuration
2. **Remove Command Line Credentials**: Don't pass client.id/secret as -D parameters
3. **Use Business Group Parameter**: Use `-Danypoint.businessGroup` (not business.group)
4. **Test Authentication**: Run the deployment and verify it uses Connected App authentication

## Expected Behavior

When using the corrected approach:
- Maven will authenticate using the Connected App credentials from `settings.xml`
- No "username/password" authentication attempts
- Proper CloudHub deployment using Connected App permissions
- Clean deployment logs without authentication errors

## Additional Notes

- The `CloudHub` server ID in `settings.xml` must match the server reference in your deployment configuration
- Connected App must have proper permissions for CloudHub deployment in your organization
- Business Group ID must be correct and accessible by your Connected App

---

**Status**: ✅ **RESOLVED** - Use `deploy-notification-connected-app.bat` script or follow the corrected command format above.
