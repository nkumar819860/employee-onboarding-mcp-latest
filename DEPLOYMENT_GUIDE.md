# Employee Onboarding System - Complete Deployment and Testing Guide

## Overview

This guide provides step-by-step instructions for deploying and testing the complete Employee Onboarding System with CloudHub, Flex Gateway, and NLP capabilities using Groq LLM.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Client Applications                          │
│              (Natural Language Processing Interface)                │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────────┐
│                    Flex Gateway Layer                               │
│        employee-onboarding-gateway.sandbox.anypoint.mulesoft.com   │
│                    (API Management & Routing)                       │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────────────┐
│                     CloudHub Applications                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────────┐   │
│  │ Employee        │ │ Asset           │ │ Notification        │   │
│  │ Onboarding      │ │ Allocation      │ │ MCP Server          │   │
│  │ MCP Server      │ │ MCP Server      │ │ (Email & Comms)     │   │
│  └─────────────────┘ └─────────────────┘ └─────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │        Employee Onboarding Agent Broker                    │   │
│  │         (Orchestration & Agent Network)                    │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### 1. Environment Setup
```bash
# Required environment variables
export ANYPOINT_USERNAME="your-anypoint-username"
export ANYPOINT_PASSWORD="your-anypoint-password"
export MULESOFT_ORG_ID="your-organization-id"
export FLEX_GATEWAY_TOKEN="your-flex-gateway-token"

# Database configuration
export DATABASE_HOST="your-postgresql-host"
export DATABASE_USERNAME="your-db-username"
export DATABASE_PASSWORD="your-db-password"

# Email configuration
export EMAIL_FROM_ADDRESS="noreply@yourcompany.com"
export EMAIL_PASSWORD="your-app-specific-password"
export NOTIFICATION_CC_HR="hr@yourcompany.com"
export NOTIFICATION_CC_IT="it@yourcompany.com"

# Groq API for NLP
export GROQ_API_KEY="your-groq-api-key"
```

### 2. Required Tools
```bash
# Install Anypoint CLI
npm install -g anypoint-cli

# Install kubectl for Kubernetes/Flex Gateway
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Python dependencies for testing
pip install groq requests
```

## Deployment Steps

### Step 1: Build and Deploy to CloudHub

```bash
# Make deployment script executable
chmod +x deploy-to-cloudhub.sh

# Run the deployment
./deploy-to-cloudhub.sh
```

**Expected Output:**
```
🚀 Starting CloudHub deployment for Employee Onboarding System...
📝 Logging into Anypoint Platform...
🔧 Building all applications...
📦 Building Employee Onboarding MCP Server...
📦 Building Asset Allocation MCP Server...
📦 Building Notification MCP Server...
📦 Building Employee Onboarding Agent Broker...
🚀 Starting CloudHub deployments...
📡 Deploying Employee Onboarding MCP Server...
📡 Deploying Asset Allocation MCP Server...
📡 Deploying Notification MCP Server...
📡 Deploying Employee Onboarding Agent Broker...
⏳ Waiting for applications to start...
🏥 Checking application health...
✅ employee-onboarding-mcp-server is healthy
✅ asset-allocation-mcp-server is healthy
✅ notification-mcp-server is healthy
✅ employee-onboarding-agent-broker is healthy
🎉 CloudHub deployment completed successfully!
```

### Step 2: Deploy Flex Gateway

```bash
# Apply Flex Gateway configuration
kubectl apply -f employee-onboarding-gateway-config.yaml

# Verify gateway deployment
kubectl get pods -l app=employee-onboarding-gateway
kubectl get services employee-onboarding-gateway-service
```

**Expected Output:**
```
NAME                                          READY   STATUS    RESTARTS   AGE
employee-onboarding-gateway-7d4b8c6f9-abc12   1/1     Running   0          2m
employee-onboarding-gateway-7d4b8c6f9-def34   1/1     Running   0          2m

NAME                                  TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE
employee-onboarding-gateway-service   LoadBalancer   10.96.123.45   203.0.113.10    80:31234/TCP,443:32567/TCP   2m
```

### Step 3: Verify System Health

```bash
# Test system health using Python script
python3 test-nlp-onboarding.py --health-only
```

**Expected Output:**
```
2024-02-21 23:55:00 - INFO - 🏥 Performing health checks on all services...
2024-02-21 23:55:01 - INFO - ✅ Employee Onboarding MCP is healthy
2024-02-21 23:55:01 - INFO - ✅ Asset Allocation MCP is healthy
2024-02-21 23:55:02 - INFO - ✅ Notification MCP is healthy
2024-02-21 23:55:02 - INFO - ✅ Agent Broker is healthy
🎉 All services are healthy!
```

## Testing the System

### 1. Manual API Testing

#### Test Individual Services
```bash
# Test Employee Service
curl -X POST https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/employee/mcp/tools/create-employee \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "department": "Engineering",
    "position": "Software Developer",
    "startDate": "2024-03-01"
  }'

# Test Asset Service
curl -X POST https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/assets/mcp/tools/allocate-assets \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "EMP001",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "department": "Engineering",
    "position": "Software Developer",
    "assets": [
      {"category": "laptop", "specifications": "MacBook Pro"},
      {"category": "monitor", "specifications": "27-inch 4K"}
    ]
  }'

# Test Notification Service
curl -X POST https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/notifications/mcp/tools/test-email-config \
  -H "Content-Type: application/json" \
  -d '{"testEmail": "test@company.com"}'
```

#### Test Complete Orchestration
```bash
curl -X POST https://employee-onboarding-gateway.sandbox.anypoint.mulesoft.com/broker/mcp/tools/orchestrate-employee-onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Smith",
    "email": "jane.smith@company.com",
    "department": "Marketing",
    "position": "Marketing Manager",
    "startDate": "2024-03-01",
    "manager": "Sarah Johnson",
    "managerEmail": "sarah.johnson@company.com",
    "companyName": "Tech Corp",
    "assets": [
      {"category": "laptop", "specifications": "MacBook Air"},
      {"category": "phone", "specifications": "iPhone 15"}
    ]
  }'
```

### 2. NLP-Based Testing

#### Run Default Test Cases
```bash
# Run comprehensive NLP tests with default test cases
python3 test-nlp-onboarding.py
```

**Expected Output:**
```
2024-02-21 23:56:00 - INFO - 🚀 Running default NLP test cases...

2024-02-21 23:56:00 - INFO - 📝 Test Case 1: I need to onboard Sarah Johnson as a Senior Software Engineer...
2024-02-21 23:56:00 - INFO - 🎯 Starting comprehensive NLP-based onboarding test...
2024-02-21 23:56:01 - INFO - 🧠 Parsing natural language request...
2024-02-21 23:56:03 - INFO - ✅ Parsed employee data: {
  "firstName": "Sarah",
  "lastName": "Johnson",
  "email": "sarah.johnson@techcorp.com",
  "department": "Engineering",
  "position": "Senior Software Engineer",
  "startDate": "2024-03-01",
  "manager": "Mike Chen",
  "managerEmail": "mike.chen@techcorp.com",
  "companyName": "TechCorp",
  "assets": [
    {"category": "laptop", "specifications": "MacBook Pro"},
    {"category": "monitor", "specifications": "27-inch monitor"},
    {"category": "keyboard", "specifications": "wireless keyboard"},
    {"category": "mouse", "specifications": "wireless mouse"}
  ]
}
2024-02-21 23:56:03 - INFO - 🏥 Performing health checks on all services...
2024-02-21 23:56:04 - INFO - ✅ Employee Onboarding MCP is healthy
2024-02-21 23:56:04 - INFO - ✅ Asset Allocation MCP is healthy
2024-02-21 23:56:05 - INFO - ✅ Notification MCP is healthy
2024-02-21 23:56:05 - INFO - ✅ Agent Broker is healthy
2024-02-21 23:56:05 - INFO - 🧪 Testing individual MCP services...
2024-02-21 23:56:06 - INFO - ✅ Employee service test passed
2024-02-21 23:56:07 - INFO - ✅ Asset service test passed
2024-02-21 23:56:08 - INFO - ✅ Notification service test passed
2024-02-21 23:56:08 - INFO - 📊 Individual service test results: {'employee_service': True, 'asset_service': True, 'notification_service': True}
2024-02-21 23:56:08 - INFO - 🚀 Starting employee onboarding orchestration for sarah.johnson@techcorp.com
2024-02-21 23:56:30 - INFO - ✅ Employee onboarding orchestration completed successfully!
2024-02-21 23:56:30 - INFO - 🎉 Complete orchestration test passed!
2024-02-21 23:56:32 - INFO - ✅ Status monitoring test passed!

🎉 All NLP test cases passed successfully!
```

#### Run Custom NLP Test
```bash
# Test with custom natural language request
python3 test-nlp-onboarding.py -r "Please onboard David Wilson as a DevOps Engineer in the Infrastructure team. His email is david.wilson@cloudtech.com, starting March 15th. He needs a powerful laptop, dual monitors, and development tools."
```

### 3. Agent Network Testing

The agent network automatically leverages the Groq LLM for:
- **Natural Language Understanding**: Parsing complex onboarding requests
- **Process Reasoning**: Determining optimal workflow steps
- **Error Recovery**: Intelligent retry and fallback mechanisms
- **Status Interpretation**: Converting system responses to human-readable status

## Monitoring and Observability

### Application Monitoring
```bash
# Check application status in Anypoint Runtime Manager
anypoint-cli cloudhub application list --environment Sandbox

# View application logs
anypoint-cli cloudhub application tail-logs employee-onboarding-agent-broker
anypoint-cli cloudhub application tail-logs employee-onboarding-mcp-server
anypoint-cli cloudhub application tail-logs asset-allocation-mcp-server
anypoint-cli cloudhub application tail-logs notification-mcp-server
```

### Gateway Monitoring
```bash
# Check gateway metrics
kubectl port-forward service/employee-onboarding-gateway-service 9090:9090
curl http://localhost:9090/metrics

# View gateway logs
kubectl logs -l app=employee-onboarding-gateway -f
```

## Success Criteria

The deployment is successful when:

✅ **All Health Checks Pass**: All 4 MCP servers respond with HTTP 200 on `/health`
✅ **Gateway Routing Works**: Flex Gateway successfully routes requests to appropriate services
✅ **NLP Processing Functions**: Groq LLM successfully parses natural language requests
✅ **Complete Orchestration Works**: End-to-end employee onboarding completes successfully
✅ **Email Notifications Sent**: All notification emails are delivered successfully
✅ **Status Monitoring Active**: Process status can be retrieved and monitored

## Troubleshooting

### Common Issues

#### 1. Health Check Failures
```bash
# Check application status
anypoint-cli cloudhub application describe [app-name] --environment Sandbox

# Check application logs for errors
anypoint-cli cloudhub application tail-logs [app-name] --environment Sandbox
```

#### 2. Gateway Connection Issues
```bash
# Verify gateway pod status
kubectl describe pod -l app=employee-onboarding-gateway

# Check gateway service endpoints
kubectl get endpoints employee-onboarding-gateway-service
```

#### 3. NLP Processing Errors
- Verify `GROQ_API_KEY` is set correctly
- Check Groq API rate limits and quotas
- Ensure natural language requests are clear and structured

#### 4. Email Notification Failures
- Verify Gmail SMTP credentials
- Check app-specific password configuration
- Ensure recipient email addresses are valid

### Performance Optimization

#### CloudHub Scaling
```bash
# Scale applications for higher load
anypoint-cli cloudhub application modify employee-onboarding-agent-broker \
  --workers 2 --workerType SMALL --environment Sandbox
```

#### Gateway Scaling
```bash
# Scale gateway replicas
kubectl scale deployment employee-onboarding-gateway --replicas=3
```

## Security Considerations

1. **API Authentication**: Basic authentication enabled on all gateway endpoints
2. **Rate Limiting**: Implemented per service with appropriate limits
3. **TLS Encryption**: All communication encrypted in transit
4. **Secret Management**: Sensitive credentials stored in Kubernetes secrets
5. **CORS Configuration**: Properly configured for web client access

## Next Steps

1. **Production Deployment**: Adapt configurations for production environment
2. **Custom Workflows**: Extend agent network for specific business requirements
3. **Integration**: Connect with existing HR and IT systems
4. **Analytics**: Implement comprehensive monitoring and analytics
5. **Mobile Support**: Develop mobile applications using the same APIs

---

**🎉 Congratulations!** You have successfully deployed a complete, intelligent employee onboarding system with CloudHub, Flex Gateway, and advanced NLP capabilities using agent network architecture.

For support and further development, contact the MCP Development Team.
