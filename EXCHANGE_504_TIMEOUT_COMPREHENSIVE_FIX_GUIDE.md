# Exchange 504 Gateway Timeout Comprehensive Fix Guide

## Problem Description

When running `deploy.bat` to publish MCP services to Anypoint Exchange, you encounter a **504 Gateway Timeout** error:

```
📤 Publishing agent-broker-mcp to Exchange...
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-deploy-plugin:3.1.1:deploy (default-deploy) on project agent-broker-mcp: Failed to deploy artifacts: Could not transfer artifact 47562e5d-bf49-440a-a0f5-a9cea0a89aa9:agent-broker-mcp:jar:mule-application:2.0.0 from/to anypoint-exchange (https://maven.anypoint.mulesoft.com/api/v3/organizations/47562e5d-bf49-440a-a0f5-a9cea0a89aa9/maven/runId/03fe7dd1-722b-471e-ac1a-b3d539120066): status code: 504, reason phrase: GATEWAY_TIMEOUT (504)
```

## Root Causes

### 1. **Maven HTTP Timeout Defaults**
- Default connection timeout: 30 seconds
- Default read timeout: 30 seconds  
- Large JAR files (MCP applications) take longer to upload

### 2. **Exchange Server Load**
- Peak usage times can cause delays
- Large artifact processing takes time
- Network connectivity issues

### 3. **Maven Deployment Configuration**
- Missing retry mechanisms
- No timeout optimization
- Standard `maven-deploy-plugin` limitations

## Solution Overview

The fix implements multiple layers of timeout handling:

1. **Extended HTTP Timeouts** (5-30 minutes)
2. **Retry Mechanisms** (3 attempts with different strategies)
3. **Optimized Maven Settings** (temporary configuration)
4. **Progressive Fallback Strategy** (multiple deployment approaches)

## Implementation Details

### 1. **Timeout Configuration**

```xml
<!-- Extended timeout configurations -->
<maven.wagon.http.connectionTimeout>300000</maven.wagon.http.connectionTimeout>
<maven.wagon.http.readTimeout>600000</maven.wagon.http.readTimeout>
<maven.wagon.httpconnectionManager.ttlSeconds>120</maven.wagon.httpconnectionManager.ttlSeconds>
<maven.wagon.http.retryHandler.count>5</maven.wagon.http.retryHandler.count>
```

**Timeout Values:**
- **Connection Timeout**: 300,000ms (5 minutes)
- **Read Timeout**: 600,000ms (10 minutes) 
- **Maximum Retry Timeout**: 1,800,000ms (30 minutes)
- **Retry Count**: 5-15 attempts

### 2. **Three-Tier Deployment Strategy**

#### **Attempt 1: Standard Deploy with Timeout Optimization**
```bash
mvn deploy -s "timeout-optimized-settings.xml" \
    -DskipMuleApplicationDeployment \
    -DskipTests \
    -Dmaven.wagon.http.connectionTimeout=300000 \
    -Dmaven.wagon.http.readTimeout=600000 \
    -Dmaven.wagon.http.retryHandler.count=5
```

#### **Attempt 2: Force Update with Extended Timeout**
```bash
mvn deploy -s "timeout-optimized-settings.xml" \
    -DforceUpdate=true \
    -Dmaven.wagon.http.connectionTimeout=600000 \
    -Dmaven.wagon.http.readTimeout=1200000 \
    -Dmaven.wagon.http.retryHandler.count=10
```

#### **Attempt 3: Minimal Deploy with Maximum Timeout**
```bash
mvn org.apache.maven.plugins:maven-deploy-plugin:3.1.1:deploy \
    -DretryFailedDeploymentCount=5 \
    -Dmaven.wagon.http.connectionTimeout=900000 \
    -Dmaven.wagon.http.readTimeout=1800000 \
    -Dmaven.wagon.http.retryHandler.count=15
```

### 3. **Dynamic Maven Settings Generation**

The fix creates a temporary, optimized Maven settings file:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <servers>
    <server>
      <id>anypoint-exchange</id>
      <username>~~~Client~~~</username>
      <password>CLIENT_ID~?~CLIENT_SECRET</password>
    </server>
  </servers>
  <profiles>
    <profile>
      <id>timeout-fix</id>
      <properties>
        <!-- Timeout configurations -->
        <maven.wagon.http.connectionTimeout>300000</maven.wagon.http.connectionTimeout>
        <maven.wagon.http.readTimeout>600000</maven.wagon.http.readTimeout>
        <!-- Retry configurations -->
        <maven.wagon.http.retryHandler.count>5</maven.wagon.http.retryHandler.count>
        <!-- Pool configurations -->
        <maven.wagon.http.pool>true</maven.wagon.http.pool>
      </properties>
    </profile>
  </profiles>
</settings>
```

## Usage Instructions

### Step 1: Use the 504 Timeout Fix Script

```bash
cd employee-onboarding-agent-fabric
deploy-504-timeout-fix.bat
```

### Step 2: Monitor Progress

The script provides detailed progress information:
- ✅ Successful uploads
- ⚠️ Retry attempts  
- ❌ Failed attempts with troubleshooting info

### Step 3: Fallback Options

If the fix still fails:

1. **Network Check**: Verify stable internet connection
2. **Timing**: Try during off-peak hours (early morning/late evening)
3. **Alternative Method**: Use Anypoint CLI
4. **Support**: Contact MuleSoft Support

## Advanced Troubleshooting

### Large Artifact Optimization

If your JAR files are particularly large:

1. **Check JAR Size**:
   ```bash
   dir mcp-servers\*\target\*.jar
   ```

2. **Optimize Dependencies**: Remove unused dependencies from `pom.xml`

3. **Use Anypoint CLI Alternative**:
   ```bash
   anypoint-cli exchange asset upload --organization-id "ORG_ID" --asset-id "ASSET_ID" --asset-version "VERSION" --files @jar-file-path
   ```

### Network Optimization

1. **Disable VPN**: Temporarily disable VPN during uploads
2. **Use Wired Connection**: Ethernet instead of WiFi
3. **Check Corporate Proxy**: Configure Maven proxy settings if needed

### Authentication Troubleshooting

1. **Token Refresh**: Regenerate Connected App credentials
2. **Scope Validation**: Ensure proper Exchange permissions
3. **Organization Access**: Verify business group permissions

## Prevention Strategies

### 1. **Regular Maintenance**
- Clean `target` directories regularly
- Monitor JAR file sizes
- Update Maven and plugin versions

### 2. **CI/CD Integration**
- Use the timeout fix in automated pipelines
- Implement retry logic in Jenkins/GitHub Actions
- Schedule deployments during low-traffic periods

### 3. **Monitoring**
- Track deployment success rates
- Monitor Exchange service status
- Set up alerts for repeated failures

## Success Indicators

✅ **Successful Fix Application:**
```
✅ agent-broker-mcp published successfully on first attempt
✅ employee-onboarding-mcp published successfully on first attempt  
✅ asset-allocation-mcp published successfully on second attempt
✅ notification-mcp published successfully on first attempt
```

✅ **Exchange Verification:**
- Assets visible in Anypoint Exchange
- Correct versions published
- Metadata properly configured

## Alternative Solutions

### Method 1: Anypoint CLI
```bash
# Install Anypoint CLI
npm install -g @mulesoft/anypoint-cli-v4

# Login
anypoint-cli auth login

# Upload assets
anypoint-cli exchange asset upload \
    --organization-id "47562e5d-bf49-440a-a0f5-a9cea0a89aa9" \
    --asset-id "agent-broker-mcp" \
    --asset-version "2.0.0" \
    --classifier "mule-application" \
    --files @target/agent-broker-mcp-2.0.0-mule-application.jar
```

### Method 2: Manual Upload
1. Build JARs locally: `mvn clean package`
2. Use Anypoint Exchange web interface
3. Upload JAR files manually
4. Configure metadata through UI

### Method 3: Staged Deployment
1. Deploy to CloudHub first (skip Exchange)
2. Use CloudHub-deployed apps for testing
3. Publish to Exchange during maintenance windows

## Support and Resources

- **MuleSoft Documentation**: https://docs.mulesoft.com/exchange/
- **Maven Wagon HTTP**: https://maven.apache.org/wagon/wagon-providers/wagon-http/
- **Anypoint CLI**: https://docs.mulesoft.com/runtime-manager/anypoint-platform-cli

---

**Created**: March 2026  
**Last Updated**: March 2026  
**Status**: ✅ Tested and Verified  
**Compatibility**: Maven 3.x, Mule 4.x, Java 17
