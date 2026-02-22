# Employee Onboarding Agent Fabric - Deployment Guide

## 🚀 Overview

This guide provides comprehensive instructions for deploying the Employee Onboarding Agent Fabric, a standardized Mule Agent Fabric implementation that orchestrates the complete employee onboarding process using MCP (Model Context Protocol) servers and intelligent agents.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Deployment](#detailed-deployment)
- [Configuration Management](#configuration-management)
- [Monitoring and Health Checks](#monitoring-and-health-checks)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🏗️ Architecture Overview

The Employee Onboarding Agent Fabric follows Mule Agent Fabric standards and consists of:

### Core Components

1. **MCP Servers**
   - `employee-onboarding-mcp`: Employee management and profile creation
   - `asset-allocation-mcp`: Asset management and allocation
   - `notification-mcp`: Email notifications and communications
   - `agent-broker-mcp`: Agent orchestration and process coordination

2. **Fabric Configuration**
   - `agent-network.yaml`: Agent network and LLM configuration
   - `gateway-config.yaml`: Flex Gateway routing and policies
   - `deployment-config.yaml`: Deployment orchestration settings

3. **Shared Resources**
   - Email templates (HTML)
   - Data validation schemas
   - Security policies
   - Global configurations

### Agent Network Structure

```
Agent Fabric Gateway (Flex Gateway)
├── Agent Broker (/broker)
├── Employee Management (/employee)
├── Asset Allocation (/assets)
└── Notifications (/notifications)
```

## ⚙️ Prerequisites

### System Requirements

- **Java 17+** (Required for Mule Runtime)
- **Maven 3.6+** (For building MCP servers)
- **Python 3.8+** (For deployment scripts and health checks)
- **Anypoint Platform Account** (For CloudHub deployment)
- **Git** (For version control)

### Environment Variables

Create a `.env` file in the fabric root directory:

```env
# Anypoint Platform Configuration
ANYPOINT_USERNAME=your-username
ANYPOINT_PASSWORD=your-password
ANYPOINT_ORG_ID=your-org-id
ANYPOINT_ENV_ID=your-env-id

# LLM Configuration
GROQ_API_KEY=your-groq-api-key

# Database Configuration
DATABASE_URL=your-database-url

# Email Configuration
EMAIL_FROM_ADDRESS=noreply@yourcompany.com
EMAIL_PASSWORD=your-email-password

# Notification Settings
NOTIFICATION_CC_HR=hr@yourcompany.com
NOTIFICATION_CC_IT=it@yourcompany.com

# Monitoring and Alerting
ALERT_WEBHOOK_URL=your-webhook-url
ALERT_EMAIL=alerts@yourcompany.com
SLACK_WEBHOOK_URL=your-slack-webhook

# Security
KEY_VAULT_NAME=your-key-vault
```

### Required Dependencies

Install Python dependencies:
```bash
pip install requests groq urllib3
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Navigate to the agent fabric directory
cd employee-onboarding-agent-fabric

# Copy environment template
cp .env.template .env

# Edit .env with your configuration
notepad .env
```

### 2. Deploy to Development

```bash
# Run the automated deployment script
.\deployment\scripts\deploy-agent-fabric.bat development
```

### 3. Verify Deployment

```bash
# Run health checks
.\deployment\scripts\health-check-all.bat development
```

## 📖 Detailed Deployment

### Phase 1: Pre-deployment Preparation

1. **Configuration Validation**
   ```bash
   .\deployment\scripts\validate-config.bat development
   ```

2. **Prerequisites Check**
   ```bash
   .\deployment\scripts\check-prerequisites.bat
   ```

3. **Backup Creation**
   ```bash
   .\deployment\scripts\backup-deployments.bat development
   ```

### Phase 2: Build All MCP Servers

```bash
.\deployment\scripts\build-all.bat
```

This script builds all MCP server applications:
- Employee Onboarding MCP Server
- Asset Allocation MCP Server  
- Notification MCP Server
- Agent Broker MCP Server

### Phase 3: Deploy Core MCP Servers

Deploy servers in dependency order:

1. **Employee Onboarding MCP**
   ```bash
   .\deployment\scripts\deploy-single-mcp.bat employee-onboarding-mcp development
   ```

2. **Asset Allocation MCP**
   ```bash
   .\deployment\scripts\deploy-single-mcp.bat asset-allocation-mcp development
   ```

3. **Notification MCP**
   ```bash
   .\deployment\scripts\deploy-single-mcp.bat notification-mcp development
   ```

### Phase 4: Deploy Orchestration Layer

```bash
.\deployment\scripts\deploy-single-mcp.bat agent-broker-mcp development
```

### Phase 5: Configure Flex Gateway

```bash
.\deployment\scripts\deploy-gateway.bat development
```

### Phase 6: Post-deployment Verification

1. **Health Checks**
   ```bash
   .\deployment\scripts\health-check-all.bat development
   ```

2. **Integration Tests**
   ```bash
   .\deployment\scripts\run-integration-tests.bat development
   ```

3. **Agent Network Validation**
   ```bash
   .\deployment\scripts\validate-agent-network.bat development
   ```

## 🔧 Configuration Management

### Environment-Specific Configuration

The fabric supports multiple environments:

- **Development**: `development` (Default)
- **Staging**: `staging`  
- **Production**: `production`

### Configuration Files

1. **Agent Network Configuration**
   - File: `fabric-config/agent-network.yaml`
   - Purpose: Define agents, LLM settings, and MCP servers

2. **Gateway Configuration**
   - File: `fabric-config/gateway-config.yaml`
   - Purpose: Flex Gateway routing and API policies

3. **Deployment Configuration**
   - File: `fabric-config/deployment-config.yaml`
   - Purpose: Deployment orchestration and environment settings

### Customizing Configuration

#### Adding New Agents

Edit `fabric-config/agent-network.yaml`:

```yaml
agents:
  - name: new-agent-name
    description: "New agent description"
    type: specialist
    capabilities:
      - new_capability
    tools:
      - new-tool
    mcp_servers:
      - new-mcp-server
```

#### Adding New MCP Servers

1. Add to `fabric-config/deployment-config.yaml`:
   ```yaml
   mcpServers:
     - name: "new-mcp-server"
       displayName: "New MCP Server"
       path: "./mcp-servers/new-mcp-server"
       buildCommand: "mvn clean package -DskipTests"
   ```

2. Add to deployment sequence in appropriate phase.

## 📊 Monitoring and Health Checks

### Automated Health Monitoring

The fabric includes comprehensive health monitoring:

1. **Service Health Checks**
   - HTTP endpoint availability
   - Response time measurement
   - Error rate tracking

2. **MCP Tool Validation**
   - Tool endpoint verification
   - MCP info availability check
   - Agent network connectivity

3. **Performance Metrics**
   - Response time analysis
   - Throughput monitoring
   - Resource utilization

### Health Check Reports

Health check results are logged to:
- File: `deployment/monitoring/health-check-log.csv`
- Format: Timestamp, Environment, Health %, Status, Healthy Count, Unhealthy Count

### Setting Up Continuous Monitoring

1. **Scheduled Health Checks**
   ```bash
   # Create a scheduled task (Windows)
   schtasks /create /tn "Agent Fabric Health Check" /tr "C:\path\to\health-check-all.bat development" /sc minute /mo 5
   ```

2. **Alerting Configuration**
   - Configure webhook URLs in `.env`
   - Set up Slack notifications
   - Configure email alerts

## 🔍 Troubleshooting

### Common Issues

#### 1. Build Failures

**Problem**: Maven build fails
```bash
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin
```

**Solution**:
- Verify Java 17+ is installed and in PATH
- Check Maven configuration in `pom.xml`
- Ensure all dependencies are available

#### 2. Deployment Failures

**Problem**: CloudHub deployment fails
```bash
[ERROR] Deployment failed: Authentication error
```

**Solution**:
- Verify Anypoint Platform credentials in `.env`
- Check organization and environment IDs
- Ensure sufficient CloudHub capacity

#### 3. Health Check Failures

**Problem**: Services return 502/503 errors
```bash
❌ Service: UNHEALTHY (Status: 502)
```

**Solution**:
- Check CloudHub application status
- Verify Flex Gateway configuration
- Review application logs in CloudHub

#### 4. Agent Network Issues

**Problem**: Agent broker cannot connect to MCP servers
```bash
❌ Agent Broker MCP Info: Unavailable
```

**Solution**:
- Verify MCP server URLs in agent network configuration
- Check network connectivity between services
- Validate MCP server health endpoints

### Log Analysis

#### Application Logs

1. **CloudHub Logs**
   - Access via Anypoint Platform Runtime Manager
   - Filter by application name and time range
   - Look for ERROR and WARN level messages

2. **Deployment Logs**
   - Local deployment logs in `deployment/logs/`
   - Build logs for each MCP server
   - Health check history

#### Health Check Logs

View health check trends:
```bash
type deployment\monitoring\health-check-log.csv
```

### Rollback Procedures

#### Automatic Rollback

The deployment script includes automatic rollback on failure:
- Triggered by health check failures
- Restores previous stable deployment
- Sends failure notifications

#### Manual Rollback

```bash
.\deployment\scripts\rollback-deployment.bat development
```

## 🏆 Best Practices

### Development Best Practices

1. **Code Organization**
   - Follow Mule Agent Fabric standards
   - Use consistent naming conventions
   - Implement proper error handling

2. **Configuration Management**
   - Use environment-specific configurations
   - Externalize sensitive data to environment variables
   - Version control all configuration files

3. **Testing Strategy**
   - Unit tests for individual MCP servers
   - Integration tests for end-to-end workflows
   - Performance testing for high-load scenarios

### Deployment Best Practices

1. **Environment Progression**
   - Development → Staging → Production
   - Validate each environment before promotion
   - Use infrastructure as code

2. **Monitoring and Alerting**
   - Set up comprehensive monitoring
   - Configure appropriate alerting thresholds
   - Regular health check reviews

3. **Security**
   - Use secure secrets management
   - Implement proper authentication and authorization
   - Regular security assessments

### Operational Best Practices

1. **Backup Strategy**
   - Regular configuration backups
   - Database backup procedures
   - Disaster recovery planning

2. **Performance Optimization**
   - Monitor response times
   - Optimize database queries
   - Implement caching where appropriate

3. **Capacity Planning**
   - Monitor resource utilization
   - Plan for growth and scale
   - Regular capacity reviews

## 🆘 Support and Maintenance

### Regular Maintenance Tasks

1. **Weekly**
   - Review health check logs
   - Check for security updates
   - Monitor performance trends

2. **Monthly**
   - Update dependencies
   - Review and optimize configurations
   - Capacity planning review

3. **Quarterly**
   - Security assessment
   - Disaster recovery testing
   - Performance optimization review

### Getting Support

1. **Documentation**: Review this guide and architecture documentation
2. **Logs**: Collect relevant logs before contacting support
3. **Health Checks**: Run comprehensive health checks
4. **Issue Reproduction**: Document steps to reproduce issues

### Contributing

To contribute to the Agent Fabric:

1. Follow the established coding standards
2. Add appropriate tests for new features
3. Update documentation
4. Submit pull requests with clear descriptions

---

## 📚 Additional Resources

- [Mule Agent Fabric Documentation](https://docs.mulesoft.com/agent-fabric/)
- [MCP Protocol Specification](https://spec.modelcontextprotocol.io/)
- [Anypoint Platform Documentation](https://docs.mulesoft.com/anypoint-platform/)
- [CloudHub 2.0 Documentation](https://docs.mulesoft.com/cloudhub-2/)

---

**Last Updated**: February 2026  
**Version**: 1.0.0  
**Maintainer**: Agent Fabric Team
