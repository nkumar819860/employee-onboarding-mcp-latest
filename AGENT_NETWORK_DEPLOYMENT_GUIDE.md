# Employee Onboarding Agent Network - Deployment and Configuration Guide

## Overview

The `employee-onboarding-agent-network.yaml` file defines a comprehensive agent network for automating employee onboarding processes using Groq LLM and MCP (Model Context Protocol) servers. This guide provides detailed instructions for deployment, configuration, and troubleshooting.

## Prerequisites

### Required Services
1. **Groq API Access**
   - Sign up at [Groq](https://groq.com)
   - Obtain API key for LLM access
   - Set environment variable: `GROQ_API_KEY`

2. **MCP Servers (CloudHub Deployed)**
   - Employee Onboarding Agent Broker
   - Employee Management Service
   - Asset Allocation Service  
   - Notification Service

3. **Infrastructure Requirements**
   - Kubernetes cluster (for production deployment)
   - Docker environment (for development)
   - Database servers (PostgreSQL/MySQL for production, H2 for development)

## Configuration Structure

### Core Components

#### 1. LLM Configuration
```yaml
llm:
  primary:
    provider: groq
    model: llama3-8b-8192
    api_key: "${GROQ_API_KEY}"
    temperature: 0.7
    max_tokens: 4096
```

#### 2. Agent Definitions
- **onboarding-master-orchestrator**: Primary coordination agent
- **employee-data-specialist**: Data validation and compliance
- **intelligent-asset-allocator**: Asset management and optimization
- **intelligent-communication-manager**: Multi-channel notifications
- **nlp-query-processor**: Natural language interface

#### 3. MCP Server Integration
- **employee-onboarding-agent-broker**: Main orchestration service
- **employee-onboarding-mcp-server**: Employee data management
- **asset-allocation-mcp-server**: Asset allocation logic
- **notification-mcp-server**: Communication services

## Environment Variables

Create a `.env` file with the following variables:

### Development Environment
```bash
# Groq LLM Configuration
GROQ_API_KEY=your_groq_api_key_here

# Database Configuration
DATABASE_URL=jdbc:h2:mem:testdb
DATABASE_USERNAME=sa
DATABASE_PASSWORD=

# Email Configuration
EMAIL_FROM_ADDRESS=dev-noreply@company.com
EMAIL_SMTP_HOST=localhost
EMAIL_SMTP_PORT=1025

# Communication Channels
SLACK_WEBHOOK_URL=https://hooks.slack.com/your/webhook/url

# MCP Services (Development)
MCP_BROKER_URL=http://localhost:8080
EMPLOYEE_SERVICE_URL=http://localhost:8081
ASSET_SERVICE_URL=http://localhost:8082
NOTIFICATION_SERVICE_URL=http://localhost:8083
```

### Production Environment
```bash
# Groq LLM Configuration
GROQ_API_KEY=your_production_groq_api_key

# Database Configuration  
DATABASE_URL=jdbc:postgresql://prod-db:5432/employee_onboarding
DATABASE_USERNAME=employee_app
DATABASE_PASSWORD=secure_password_here

# Email Configuration
EMAIL_FROM_ADDRESS=noreply@company.com
EMAIL_SMTP_HOST=smtp.company.com
EMAIL_SMTP_PORT=587
EMAIL_USERNAME=smtp_user
EMAIL_PASSWORD=smtp_password

# Communication Channels
SLACK_WEBHOOK_URL=https://hooks.slack.com/production/webhook
TEAMS_WEBHOOK_URL=https://company.webhook.office.com/teams

# MCP Services (CloudHub Production)
MCP_BROKER_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io
EMPLOYEE_SERVICE_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
ASSET_SERVICE_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
NOTIFICATION_SERVICE_URL=https://notification-mcp-server.us-e1.cloudhub.io

# Security Configuration
ENCRYPTION_KEY=your_256_bit_encryption_key
JWT_SECRET=your_jwt_secret_key
OAUTH2_CLIENT_ID=your_oauth2_client_id
OAUTH2_CLIENT_SECRET=your_oauth2_client_secret
```

## Deployment Steps

### 1. Local Development Deployment

#### Step 1: Set up Local Environment
```bash
# Clone the repository
git clone https://github.com/your-org/employee-onboarding-agent-network.git
cd employee-onboarding-agent-network

# Create environment file
cp .env.example .env
# Edit .env with your configuration

# Install dependencies
npm install
```

#### Step 2: Start MCP Services Locally
```bash
# Start all MCP services using Docker Compose
docker-compose -f docker-compose-dev.yml up -d

# Verify services are running
curl http://localhost:8080/health
curl http://localhost:8081/health  
curl http://localhost:8082/health
curl http://localhost:8083/health
```

#### Step 3: Deploy Agent Network
```bash
# Deploy using agent network configuration
agent-network deploy --config employee-onboarding-agent-network.yaml --env development

# Verify deployment
agent-network status --config employee-onboarding-agent-network.yaml
```

### 2. Production Deployment

#### Step 1: Deploy MCP Services to CloudHub
```bash
# Deploy all MCP services to CloudHub
./deploy-all-mcp-servers.bat

# Or deploy individually
mvn clean deploy -f employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/pom.xml
mvn clean deploy -f employee-onboarding-agent-fabric/mcp-servers/employee-onboarding-mcp/pom.xml
mvn clean deploy -f employee-onboarding-agent-fabric/mcp-servers/asset-allocation-mcp/pom.xml
mvn clean deploy -f employee-onboarding-agent-fabric/mcp-servers/notification-mcp/pom.xml
```

#### Step 2: Configure Production Environment
```bash
# Set production environment variables
export GROQ_API_KEY=your_production_key
export DATABASE_URL=your_production_db_url
# ... other production variables

# Update agent network configuration
agent-network config set --env production
```

#### Step 3: Deploy to Production
```bash
# Deploy to production Kubernetes cluster
kubectl apply -f k8s/agent-network-production.yaml

# Or deploy to managed service
agent-network deploy --config employee-onboarding-agent-network.yaml --env production --target kubernetes
```

## Usage Examples

### 1. Complete Employee Onboarding

#### Using the Master Orchestrator
```javascript
// Example: Complete onboarding process
const onboardingRequest = {
  firstName: "John",
  lastName: "Doe",
  email: "john.doe@company.com",
  phone: "+1-555-123-4567",
  department: "Engineering",
  position: "Software Engineer",
  startDate: "2026-03-10",
  salary: 75000,
  manager: "Jane Smith",
  managerEmail: "jane.smith@company.com",
  companyName: "TechCorp Inc",
  assets: ["laptop", "monitor", "keyboard", "mouse"]
};

// Initiate onboarding through MCP broker
const result = await mcpClient.call(
  'employee-onboarding-agent-broker',
  'orchestrate-employee-onboarding',
  onboardingRequest
);

console.log('Onboarding Result:', result);
```

#### Monitoring Progress
```javascript
// Check onboarding status
const status = await mcpClient.call(
  'employee-onboarding-agent-broker',
  'get-onboarding-status',
  { email: "john.doe@company.com" }
);

console.log('Onboarding Status:', status);
```

### 2. Natural Language Queries

```javascript
// Process natural language query
const nlpResponse = await agentNetwork.query(
  "What's the status of John Doe's onboarding?",
  { agent: "nlp-query-processor" }
);

console.log('NLP Response:', nlpResponse);
```

### 3. Asset Management

```javascript
// Intelligent asset allocation
const assetRequest = {
  employeeId: "emp-123",
  department: "Engineering", 
  position: "Senior Software Engineer",
  location: "New York",
  specialRequirements: ["dual monitors", "mechanical keyboard"]
};

const allocation = await agentNetwork.execute(
  "intelligent-asset-allocator",
  "allocate-assets",
  assetRequest
);

console.log('Asset Allocation:', allocation);
```

## Monitoring and Troubleshooting

### Health Checks

#### 1. System Health Monitoring
```bash
# Check overall system health
agent-network health-check --config employee-onboarding-agent-network.yaml

# Check specific MCP service health  
curl https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health
```

#### 2. Agent Status Monitoring
```javascript
// Monitor agent performance
const agentMetrics = await agentNetwork.getMetrics([
  "onboarding-master-orchestrator",
  "employee-data-specialist", 
  "intelligent-asset-allocator"
]);

console.log('Agent Metrics:', agentMetrics);
```

### Common Issues and Solutions

#### 1. MCP Service Connectivity Issues

**Problem**: HTTP 504 errors when calling MCP services
```bash
Error: Request failed with status code 504
```

**Solutions**:
```bash
# Check service status
curl -v https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health

# Verify network connectivity
ping employee-onboarding-agent-broker.us-e1.cloudhub.io

# Check CloudHub application logs
anypoint-cli cloudhub application logs --name employee-onboarding-agent-broker

# Restart services if needed
anypoint-cli cloudhub application restart --name employee-onboarding-agent-broker
```

#### 2. Authentication/Authorization Errors

**Problem**: 401 Unauthorized errors
```bash
Error: Authentication failed
```

**Solutions**:
```bash
# Verify API keys and credentials
echo $GROQ_API_KEY
echo $OAUTH2_CLIENT_ID

# Check token expiration
agent-network auth check-token

# Refresh tokens if needed
agent-network auth refresh-token
```

#### 3. Performance Issues

**Problem**: Slow response times or timeouts

**Solutions**:
```yaml
# Adjust timeout settings in configuration
mcp_servers:
  - name: employee-onboarding-agent-broker
    timeout: 60000  # Increase timeout to 60 seconds
    retry_attempts: 5  # Increase retry attempts
```

#### 4. Data Validation Errors

**Problem**: Employee data validation failures

**Solutions**:
```javascript
// Check data format and required fields
const validationResult = await agentNetwork.validate({
  firstName: "John",
  lastName: "Doe", 
  email: "john.doe@company.com",  // Must be valid email format
  startDate: "2026-03-10"  // Must be valid date format
});

if (!validationResult.valid) {
  console.log('Validation Errors:', validationResult.errors);
}
```

### Logging and Debugging

#### 1. Enable Debug Logging
```yaml
# Update configuration for debug logging
monitoring:
  enabled: true
  level: debug  # Change from 'comprehensive' to 'debug'
  
environments:
  - name: development
    configuration:
      monitoring_level: "debug"
```

#### 2. Access Logs
```bash
# View agent network logs
tail -f /var/log/agent-network/agent-network.log

# View MCP service logs
kubectl logs -f deployment/employee-onboarding-broker

# View specific agent logs
tail -f /var/log/agent-network/onboarding-master-orchestrator.log
```

## Performance Optimization

### 1. Caching Configuration
```yaml
performance:
  caching:
    enabled: true
    layers: ["memory", "redis"]
    strategies:
      employee_data: 
        ttl: 300  # 5 minutes
      asset_data: 
        ttl: 600  # 10 minutes
```

### 2. Load Balancing
```yaml
performance:
  load_balancing:
    enabled: true
    algorithm: "weighted_round_robin_with_health_checks"
    health_check_interval: 30
```

### 3. Auto Scaling
```yaml
performance:
  auto_scaling:
    enabled: true
    scaling_policies:
      cpu_threshold: 70
      memory_threshold: 80
    scaling_parameters:
      min_instances: 2
      max_instances: 10
```

## Security Best Practices

### 1. Environment Variable Security
```bash
# Use secure storage for production secrets
kubectl create secret generic agent-network-secrets \
  --from-literal=GROQ_API_KEY="$GROQ_API_KEY" \
  --from-literal=DATABASE_PASSWORD="$DATABASE_PASSWORD"
```

### 2. Network Security
```yaml
security:
  encryption_and_protection:
    data_in_transit: 
      protocol: "TLS_1_3"
    data_at_rest:
      algorithm: "AES-256-GCM"
```

### 3. Access Control
```yaml
security:
  authorization:
    model: "RBAC_with_ABAC"
    roles:
      - hr_admin:
          permissions: ["onboarding:*", "employee:*"]
          session_timeout: 60
```

## Compliance and Governance

### 1. Data Privacy Compliance
```yaml
compliance:
  frameworks:
    - name: "GDPR"
      controls: ["data_minimization", "consent_management"]
    - name: "CCPA" 
      controls: ["consumer_rights", "data_transparency"]
```

### 2. Audit Logging
```yaml
monitoring:
  analytics_and_reporting:
    custom_reporting: true
    executive_dashboards: true
  
security:
  privacy_and_compliance:
    audit_retention: "7_years"
    breach_notification: true
```

## Support and Maintenance

### Regular Maintenance Tasks

#### 1. Weekly Tasks
```bash
# Check system health
agent-network health-check --comprehensive

# Review performance metrics
agent-network metrics --timeframe week

# Update security patches
agent-network update --security-only
```

#### 2. Monthly Tasks
```bash
# Full system backup
agent-network backup --full

# Performance optimization review
agent-network optimize --analyze

# Security audit
agent-network security-audit
```

#### 3. Quarterly Tasks
```bash
# Disaster recovery testing
agent-network dr-test

# Compliance review
agent-network compliance-check --all-frameworks

# Capacity planning
agent-network capacity-plan --forecast 6-months
```

### Getting Help

#### 1. Documentation Resources
- [Agent Network Documentation](https://docs.agent-network.com)
- [MCP Protocol Specification](https://modelcontextprotocol.io/docs)
- [Groq API Documentation](https://docs.groq.com)

#### 2. Support Channels
- GitHub Issues: [Project Repository Issues](https://github.com/your-org/employee-onboarding-agent-network/issues)
- Community Discord: [Agent Network Community](https://discord.gg/agent-network)
- Enterprise Support: support@agent-network.com

#### 3. Emergency Contacts
- Critical System Issues: emergency@agent-network.com
- Security Incidents: security@agent-network.com
- Data Privacy Concerns: privacy@agent-network.com

## Conclusion

This comprehensive agent network provides a robust, scalable solution for employee onboarding automation. The configuration supports multi-environment deployments, advanced security features, and comprehensive monitoring capabilities.

For additional customization or enterprise features, please consult the [Advanced Configuration Guide](ADVANCED_CONFIGURATION.md) or contact our support team.
