# CloudHub Deployment Guide - Employee Onboarding MCP Servers

## Overview

This guide explains how to deploy all Employee Onboarding MCP servers to Anypoint Platform CloudHub using connected app credentials.

## Prerequisites

### 1. Anypoint Platform Account
- Access to Anypoint Platform with CloudHub subscription
- Sandbox environment available
- Permissions to deploy applications

### 2. Connected App Setup
You need to create a Connected App in Anypoint Platform with the following scopes:
- **Design Center Developer**
- **Cloudhub Application Admin** 
- **Cloudhub Organization Admin**

#### Steps to create Connected App:
1. Go to Anypoint Platform → Access Management → Connected Apps
2. Click "Create App"
3. Fill in the application details
4. Select the required scopes mentioned above
5. Save and note down:
   - **Client ID**
   - **Client Secret** 
   - **Organization ID**

### 3. Local Development Environment
- Maven 3.6+ installed
- Java 11 JDK installed
- Git (for version control)

## Deployment Process

### Step 1: Set Environment Variables

Before running the deployment script, set your connected app credentials as environment variables:

```batch
set ANYPOINT_CLIENT_ID=your-client-id-here
set ANYPOINT_CLIENT_SECRET=your-client-secret-here  
set ANYPOINT_ORG_ID=your-org-id-here
```

**Alternative**: Create a batch file `set-credentials.bat`:
```batch
@echo off
set ANYPOINT_CLIENT_ID=12345678-abcd-1234-efgh-123456789012
set ANYPOINT_CLIENT_SECRET=your-secret-key-here
set ANYPOINT_ORG_ID=abcd1234-5678-90ef-ghij-klmnopqrstuv
echo Credentials set successfully!
```

### Step 2: Run CloudHub Deployment

Execute the deployment script:
```batch
.\cloudhub-deploy.bat
```

The script will:
1. Validate your credentials
2. Deploy each MCP server sequentially:
   - Employee Onboarding MCP Server
   - Asset Allocation MCP Server  
   - Notification MCP Server
   - Agent Broker MCP Server

### Step 3: Monitor Deployment

During deployment, you'll see:
- Build progress for each server
- Upload status to CloudHub
- Application startup status

## Deployed Applications

After successful deployment, the following applications will be available:

| Service | CloudHub URL | Purpose |
|---------|--------------|---------|
| Employee Onboarding MCP | `https://employee-onboarding-mcp-server.us-e1.cloudhub.io` | Employee profile management |
| Asset Allocation MCP | `https://asset-allocation-mcp-server.us-e1.cloudhub.io` | Asset allocation (laptops, ID cards) |
| Notification MCP | `https://notification-mcp-server.us-e1.cloudhub.io` | Email notifications |
| Agent Broker MCP | `https://employee-onboarding-agent-broker.us-e1.cloudhub.io` | Process orchestration |

## Post-Deployment Configuration

### 1. Update React Client Configuration

Update your React client environment variables to point to CloudHub URLs:

```javascript
// In your .env file or environment configuration
REACT_APP_API_BASE_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io
REACT_APP_EMPLOYEE_API_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
REACT_APP_ASSET_API_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
REACT_APP_NOTIFICATION_API_URL=https://notification-mcp-server.us-e1.cloudhub.io
```

### 2. Database Configuration

The CloudHub applications are currently configured to use H2 in-memory database for demonstration purposes. For production:

1. Set up a cloud database (e.g., AWS RDS, Azure SQL)
2. Update the database connection properties in each application
3. Redeploy with production database settings

### 3. Email Configuration

For the Notification MCP server, configure production email settings:
- Update Gmail SMTP settings or use enterprise email service
- Set proper authentication credentials
- Configure email templates as needed

## Monitoring and Management

### Anypoint Platform Console
Access your applications at: `https://anypoint.mulesoft.com/cloudhub/`

### Application Logs
View real-time logs for each application through the CloudHub console.

### Health Checks
Each application exposes health endpoints:
- `/health` - Application health status
- `/info` - Application information

## Troubleshooting

### Common Issues

**1. Authentication Failed**
- Verify connected app credentials are correct
- Check that the connected app has required scopes
- Ensure organization ID is correct

**2. Build Failures**
- Check Maven is properly installed
- Verify Java 11 JDK is available
- Review build logs for specific errors

**3. Deployment Timeout**
- CloudHub deployments can take 5-10 minutes
- Check application status in CloudHub console
- Review application logs for startup issues

**4. Application Not Starting**
- Check Mule runtime version compatibility
- Verify all required connectors are included
- Review configuration properties

### Support Contacts

- **Anypoint Platform Support**: Contact MuleSoft support through your subscription
- **Application Issues**: Check application logs and contact development team

## Security Considerations

### Production Deployment Checklist

- [ ] Use dedicated production connected app credentials
- [ ] Enable HTTPS for all endpoints
- [ ] Configure proper firewall rules
- [ ] Set up monitoring and alerting
- [ ] Use encrypted database connections
- [ ] Configure secure email authentication
- [ ] Regular security updates and patches

### Environment Separation

- **Sandbox**: For development and testing
- **Production**: For live employee onboarding operations

## Scaling and Performance

### CloudHub Worker Configuration

Current configuration:
- **Worker Type**: MICRO (0.1 vCores)
- **Workers**: 1 per application
- **Region**: US East (N. Virginia)

For production, consider:
- Upgrading to SMALL or MEDIUM workers
- Increasing worker count for high availability
- Deploying to multiple regions if needed

## Backup and Recovery

### Application Artifacts
- Source code is stored in Git repository
- Application JARs are built during deployment
- CloudHub maintains deployment history

### Data Backup
- Configure database backups for production
- Export configuration settings
- Document integration endpoints and dependencies

---

**Next Steps**: After successful CloudHub deployment, your Employee Onboarding MCP servers will be running on enterprise-grade infrastructure with automatic scaling, monitoring, and high availability.
