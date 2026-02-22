# MCP Services - Deployment Configuration Guide

This guide provides detailed instructions for configuring and deploying the MCP services to CloudHub and publishing them to Anypoint Exchange.

## Prerequisites

### Required Software
- **Maven 3.6+**: For building and deploying applications
- **Java 8+**: Runtime environment
- **Anypoint CLI v4** (optional): For additional management capabilities
- **Git**: For version control

### Anypoint Platform Access
- Valid Anypoint Platform account
- Access to target organization and environment
- Appropriate permissions for Exchange publishing and CloudHub deployment

## Environment Configuration

### Maven Settings Configuration

Create or update your `~/.m2/settings.xml` file with Anypoint Platform credentials:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
    
    <servers>
        <server>
            <id>anypoint-exchange</id>
            <username>your-anypoint-username</username>
            <password>your-anypoint-password</password>
        </server>
        <server>
            <id>anypoint-exchange-v3</id>
            <username>your-anypoint-username</username>
            <password>your-anypoint-password</password>
        </server>
    </servers>
    
    <profiles>
        <profile>
            <id>mcp-deployment</id>
            <properties>
                <!-- Gmail Configuration for Notification Service -->
                <gmail.username>your-gmail-username@gmail.com</gmail.username>
                <gmail.password>your-gmail-app-password</gmail.password>
                <email.from.address>your-company-email@company.com</email.from.address>
                <notification.cc.hr>hr@company.com</notification.cc.hr>
                <notification.cc.it>it@company.com</notification.cc.it>
                
                <!-- Database Configuration for Asset Allocation -->
                <db.postgres.url>jdbc:postgresql://your-db-host:5432/asset_allocation</db.postgres.url>
                <db.postgres.username>your-db-username</db.postgres.username>
                <db.postgres.password>your-db-password</db.postgres.password>
                <db.postgres.driverClassName>org.postgresql.Driver</db.postgres.driverClassName>
                
                <!-- H2 Fallback Database -->
                <db.h2.url>jdbc:h2:mem:asset_allocation;DB_CLOSE_DELAY=-1</db.h2.url>
                <db.h2.username>sa</db.h2.username>
                <db.h2.password></db.h2.password>
                <db.h2.driverClassName>org.h2.Driver</db.h2.driverClassName>
            </properties>
        </profile>
    </profiles>
    
    <activeProfiles>
        <activeProfile>mcp-deployment</activeProfile>
    </activeProfiles>
</settings>
```

## Service-Specific Configuration

### 1. Notification MCP Server

**Required Properties:**
- `gmail.username`: Gmail account for SMTP
- `gmail.password`: Gmail app password (not regular password)
- `email.from.address`: From address for emails
- `notification.cc.hr`: HR team CC address
- `notification.cc.it`: IT team CC address

**Gmail Setup Steps:**
1. Enable 2-factor authentication on Gmail account
2. Generate an App Password in Gmail settings
3. Use the App Password (not your regular password) in configuration

**CloudHub Properties:**
```properties
gmail.username=notifications@company.com
gmail.password=your-gmail-app-password
email.from.address=noreply@company.com
notification.cc.hr=hr@company.com
notification.cc.it=it@company.com
notification.employee.onboarding.enabled=true
```

### 2. Asset Allocation MCP Server

**Required Properties:**
- Database connection details (PostgreSQL primary)
- H2 fallback configuration
- Asset category configurations

**CloudHub Properties:**
```properties
db.postgres.url=jdbc:postgresql://your-db-host:5432/asset_allocation
db.postgres.username=asset_db_user
db.postgres.password=your-db-password
db.postgres.driverClassName=org.postgresql.Driver
db.h2.url=jdbc:h2:mem:asset_allocation;DB_CLOSE_DELAY=-1
db.h2.username=sa
db.h2.password=
db.h2.driverClassName=org.h2.Driver
asset.allocation.auto.init=true
```

### 3. Agent Broker MCP Server

**Required Properties:**
- Service endpoint configurations for integrated MCP servers
- Orchestration settings

**CloudHub Properties:**
```properties
employee.onboarding.mcp.host=employee-onboarding-mcp-server.us-e1.cloudhub.io
employee.onboarding.mcp.port=443
employee.onboarding.mcp.protocol=HTTPS
asset.allocation.mcp.host=asset-allocation-mcp-server.us-e1.cloudhub.io
asset.allocation.mcp.port=443
asset.allocation.mcp.protocol=HTTPS
notification.mcp.host=notification-mcp-server.us-e1.cloudhub.io
notification.mcp.port=443
notification.mcp.protocol=HTTPS
agent.broker.orchestration.enabled=true
```

## Deployment Process

### Step 1: Build and Test Locally

```bash
# Navigate to each service directory and build
cd mcp-servers/notification-mcp
mvn clean compile test

cd ../asset-allocation-mcp
mvn clean compile test

cd ../agent-broker-mcp
mvn clean compile test
```

### Step 2: Publish to Exchange

Run the comprehensive deployment script:

```bash
# From the employee-onboarding-agent-fabric directory
./deploy-and-publish-to-exchange.bat
```

Or deploy each service individually:

```bash
# Notification MCP
cd mcp-servers/notification-mcp
mvn deploy -DskipTests

# Asset Allocation MCP
cd ../asset-allocation-mcp
mvn deploy -DskipTests

# Agent Broker MCP
cd ../agent-broker-mcp
mvn deploy -DskipTests
```

### Step 3: Deploy to CloudHub

Deploy with Maven plugin:

```bash
# For each service
mvn deploy -DmuleDeploy -DskipTests
```

Or use Anypoint CLI:

```bash
# Login to Anypoint CLI
anypoint-cli-v4 auth login

# Deploy each application
anypoint-cli-v4 runtime-mgr application deploy notification-mcp-server target/notification-mcp-server-1.0.0-mule-application.jar --target CloudHub-US-East-1
```

## Post-Deployment Verification

### 1. Exchange Verification

1. Login to Anypoint Platform
2. Navigate to Exchange
3. Verify all three assets are published:
   - `notification-mcp-server`
   - `asset-allocation-mcp-server`
   - `employee-onboarding-agent-broker`
4. Check that OpenAPI specifications are included as documentation

### 2. CloudHub Deployment Verification

1. Navigate to Runtime Manager
2. Verify all applications are deployed and running
3. Check application logs for any errors
4. Test health check endpoints

### 3. Service Integration Testing

```bash
# Test Notification MCP
curl -X GET https://notification-mcp-server.us-e1.cloudhub.io/health

# Test Asset Allocation MCP
curl -X GET https://asset-allocation-mcp-server.us-e1.cloudhub.io/health

# Test Agent Broker MCP
curl -X GET https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health
```

### 4. End-to-End Testing

Test the complete onboarding workflow:

```bash
curl -X POST https://employee-onboarding-agent-broker.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "department": "Engineering",
    "position": "Software Engineer",
    "startDate": "2024-01-15"
  }'
```

## Troubleshooting

### Common Issues

1. **Maven Build Failures**
   - Verify Java version compatibility
   - Check Maven dependencies
   - Ensure proper settings.xml configuration

2. **Exchange Publishing Failures**
   - Verify Anypoint Platform credentials
   - Check organization permissions
   - Ensure unique artifact naming

3. **CloudHub Deployment Failures**
   - Verify environment variables
   - Check application naming conflicts
   - Validate security policies

4. **Service Integration Issues**
   - Verify service endpoint configurations
   - Check network connectivity
   - Validate authentication credentials

### Log Analysis

Monitor application logs in CloudHub:
1. Runtime Manager → Applications → [App Name] → Logs
2. Look for startup errors, configuration issues, or integration failures
3. Check MCP connector initialization

### Support Resources

- **MuleSoft Documentation**: https://docs.mulesoft.com/
- **Anypoint Exchange**: https://www.mulesoft.com/exchange/
- **CloudHub Documentation**: https://docs.mulesoft.com/runtime-manager/cloudhub
- **MCP Connector Documentation**: Available in Anypoint Exchange

## Security Considerations

1. **Secure Properties**: Use CloudHub secure properties for sensitive data
2. **API Policies**: Apply appropriate API policies in API Manager
3. **Network Security**: Configure VPC and firewall rules as needed
4. **Monitoring**: Enable CloudHub Insights for monitoring and alerting

## Maintenance

1. **Regular Updates**: Keep dependencies and Mule runtime updated
2. **Monitoring**: Monitor application performance and logs
3. **Backup**: Maintain configuration backups
4. **Documentation**: Keep deployment documentation current

---

For additional support or questions, contact the MCP Development Team at mcp-dev@company.com.
