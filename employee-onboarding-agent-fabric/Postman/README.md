# Employee Onboarding MCP Services - Postman Collection Guide

This directory contains a comprehensive Postman collection for testing and interacting with all Employee Onboarding MCP (Model Context Protocol) Services.

## 📋 Collection Overview

### File: `Employee-Onboarding-MCP-Services-Complete.postman_collection.json`

This collection provides complete API testing capabilities for the Employee Onboarding system with **4 integrated MCP services** and **25+ endpoints**.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Employee Onboarding System               │
├─────────────────────────────────────────────────────────────┤
│  Agent Broker MCP (Port 8084) - Central Orchestrator       │
│  ├─ Orchestrate complete onboarding workflow               │
│  ├─ Status tracking and monitoring                         │
│  └─ Error handling and retry mechanisms                    │
├─────────────────────────────────────────────────────────────┤
│  Employee Onboarding MCP (Port 8081) - HR Management       │
│  ├─ Employee CRUD operations                               │
│  ├─ Status management and lifecycle                        │
│  └─ Pagination and filtering                               │
├─────────────────────────────────────────────────────────────┤
│  Asset Allocation MCP (Port 8083) - IT Asset Management    │
│  ├─ Asset allocation and tracking                          │
│  ├─ Return and condition management                        │
│  └─ Availability and inventory checking                    │
├─────────────────────────────────────────────────────────────┤
│  Notification MCP (Port 8082) - Email Services             │
│  ├─ Welcome emails with personalization                    │
│  ├─ Asset allocation notifications                         │
│  └─ Onboarding completion messages                         │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start Guide

### 1. Import Collection
1. Open Postman
2. Click **Import**
3. Select `Employee-Onboarding-MCP-Services-Complete.postman_collection.json`
4. Click **Import**

### 2. Environment Setup
Configure these environment variables in Postman:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `agent_broker_url` | `http://localhost:8084` | Agent Broker MCP base URL |
| `employee_onboarding_url` | `http://localhost:8081/api` | Employee Onboarding MCP base URL |
| `asset_allocation_url` | `http://localhost:8083/api` | Asset Allocation MCP base URL |
| `notification_url` | `http://localhost:8082` | Notification MCP base URL |

### 3. Health Check Workflow
Start by running health checks to ensure all services are operational:

```
1. Agent Broker MCP → Health Check
2. Employee Onboarding MCP → Health Check  
3. Asset Allocation MCP → Health Check
4. Notification MCP → Health Check
```

## 📁 Collection Structure

### 1. Agent Broker MCP (Port 8084)
**Purpose**: Central orchestrator for complete employee onboarding workflow

#### Endpoints:
- **GET** `/health` - Health check
- **GET** `/mcp/info` - Server information
- **POST** `/mcp/tools/orchestrate-employee-onboarding` - Complete orchestration
- **POST** `/mcp/tools/get-onboarding-status` - Status tracking
- **POST** `/mcp/tools/retry-failed-step` - Error recovery

#### Key Features:
- Multi-service integration
- Comprehensive error handling
- Real-time status tracking
- Atomic operations across services

### 2. Employee Onboarding MCP (Port 8081)
**Purpose**: Employee lifecycle management and HR processes

#### Endpoints:
- **GET** `/health` - Health check
- **GET** `/mcp/info` - Server information
- **POST** `/mcp/tools/create-employee` - Create employee record
- **GET** `/mcp/tools/get-employee/{empId}` - Retrieve employee
- **GET** `/mcp/tools/list-employees` - List with pagination
- **PUT** `/mcp/tools/update-employee-status/{empId}/{status}` - Update status

#### Key Features:
- Multi-database support (PostgreSQL, H2, Mock)
- Pagination and filtering
- Status lifecycle management
- Comprehensive validation

### 3. Asset Allocation MCP (Port 8083)
**Purpose**: IT asset management and allocation

#### Endpoints:
- **GET** `/health` - Health check
- **GET** `/mcp/info` - Server information
- **POST** `/mcp/tools/allocate-assets` - Allocate assets to employee
- **POST** `/mcp/tools/return-asset` - Return asset
- **GET** `/mcp/tools/list-assets` - List all assets with filters
- **GET** `/mcp/tools/get-available-assets` - Available assets only
- **POST** `/mcp/tools/get-employee-assets` - Employee's allocated assets

#### Key Features:
- Intelligent asset allocation
- Real-time availability tracking
- Condition and lifecycle management
- Category-based filtering

### 4. Notification MCP (Port 8082)
**Purpose**: Email notification services for onboarding process

#### Endpoints:
- **GET** `/health` - Health check
- **GET** `/mcp/info` - Server information
- **POST** `/mcp/tools/send-welcome-email` - Welcome email with personalization
- **POST** `/mcp/tools/send-asset-notification` - Asset allocation confirmation
- **POST** `/mcp/tools/send-onboarding-complete` - Completion summary
- **POST** `/mcp/tools/test-email-config` - Email configuration testing

#### Key Features:
- Gmail SMTP integration
- Professional HTML templates
- Dynamic content replacement
- Configuration validation

### 5. End-to-End Workflow Examples
**Purpose**: Complete workflow demonstrations

#### Examples:
- **Complete Onboarding Workflow** - Full end-to-end process
- **Health Check All Services** - System verification

## 🔄 Complete Workflow Example

### Step 1: Orchestrated Onboarding (Recommended)
Use the Agent Broker for complete automation:

```json
POST {{agent_broker_url}}/mcp/tools/orchestrate-employee-onboarding
{
    "firstName": "John",
    "lastName": "Smith",
    "email": "john.smith@company.com",
    "department": "Engineering",
    "position": "Senior Software Engineer",
    "startDate": "2024-01-15",
    "manager": "Sarah Johnson",
    "managerName": "Sarah Johnson",
    "managerEmail": "sarah.johnson@company.com",
    "orientationDate": "2024-01-16",
    "companyName": "TechCorp Inc",
    "assets": [
        {
            "category": "LAPTOP",
            "priority": "HIGH"
        },
        {
            "category": "ID_CARD", 
            "priority": "HIGH"
        }
    ]
}
```

This single request will:
1. ✅ Create employee profile
2. ✅ Allocate requested assets
3. ✅ Send welcome email
4. ✅ Send asset allocation notification
5. ✅ Send onboarding completion summary

### Step 2: Manual Step-by-Step Process (Alternative)
For granular control, use individual services:

1. **Create Employee**:
   ```
   POST {{employee_onboarding_url}}/mcp/tools/create-employee
   ```

2. **Allocate Assets**:
   ```
   POST {{asset_allocation_url}}/mcp/tools/allocate-assets
   ```

3. **Send Notifications**:
   ```
   POST {{notification_url}}/mcp/tools/send-welcome-email
   POST {{notification_url}}/mcp/tools/send-asset-notification
   POST {{notification_url}}/mcp/tools/send-onboarding-complete
   ```

## 🧪 Testing Scenarios

### 1. Basic Health Verification
```
✓ All services respond to health checks
✓ MCP server info returns correct capabilities
✓ Environment variables are configured correctly
```

### 2. Employee Management Testing
```
✓ Create employee with valid data
✓ Retrieve employee by ID
✓ List employees with pagination
✓ Update employee status
✓ Handle duplicate email validation
```

### 3. Asset Allocation Testing
```
✓ Allocate multiple assets to employee
✓ Check asset availability before allocation
✓ Return asset with condition tracking
✓ List employee's allocated assets
✓ Handle insufficient asset scenarios
```

### 4. Notification Testing
```
✓ Send welcome email with personalization
✓ Send asset allocation confirmation
✓ Send completion summary with full details
✓ Test email configuration connectivity
✓ Handle email delivery failures
```

### 5. End-to-End Integration Testing
```
✓ Complete orchestrated onboarding workflow
✓ Status tracking throughout process
✓ Error handling and recovery
✓ Data consistency across services
```

## 🛠️ Environment Configuration

### Local Development
```
agent_broker_url: http://localhost:8084
employee_onboarding_url: http://localhost:8081/api
asset_allocation_url: http://localhost:8083/api
notification_url: http://localhost:8082
```

### CloudHub Production
```
agent_broker_url: https://agent-broker-mcp.cloudhub.io
employee_onboarding_url: https://employee-onboarding-mcp.cloudhub.io/api
asset_allocation_url: https://asset-allocation-mcp.cloudhub.io/api
notification_url: https://notification-mcp.cloudhub.io
```

### Staging Environment
```
agent_broker_url: https://agent-broker-mcp-staging.cloudhub.io
employee_onboarding_url: https://employee-onboarding-mcp-staging.cloudhub.io/api
asset_allocation_url: https://asset-allocation-mcp-staging.cloudhub.io/api
notification_url: https://notification-mcp-staging.cloudhub.io
```

## 📊 Automated Testing

The collection includes global test scripts for:

### Response Validation
```javascript
pm.test('Response time is less than 5000ms', function () {
    pm.expect(pm.response.responseTime).to.be.below(5000);
});

pm.test('Response has valid JSON structure', function () {
    pm.response.to.have.jsonBody();
});
```

### Debug Logging
```javascript
console.log('Response Status:', pm.response.status);
console.log('Response Time:', pm.response.responseTime + 'ms');
if (pm.response.json()) {
    console.log('Response Body:', JSON.stringify(pm.response.json(), null, 2));
}
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Connection Refused
**Problem**: Cannot connect to MCP services
**Solution**: 
- Verify services are running on correct ports
- Check environment variable configuration
- Ensure no port conflicts

#### 2. Authentication Errors
**Problem**: 401/403 responses
**Solution**:
- Verify API key configuration (if required)
- Check OAuth2 token validity
- Ensure proper headers are set

#### 3. Invalid JSON Responses
**Problem**: Unexpected response format
**Solution**:
- Check service health endpoints
- Verify API specification alignment
- Check for service deployment issues

#### 4. Timeout Errors
**Problem**: Requests timing out
**Solution**:
- Increase request timeout in Postman
- Check database connectivity
- Verify service performance

### Debug Steps
1. **Service Health**: Start with health check endpoints
2. **Network**: Verify connectivity and DNS resolution
3. **Configuration**: Validate environment variables
4. **Logs**: Check service logs for detailed error information
5. **Data**: Verify request payload format and required fields

## 📚 Additional Resources

### API Documentation
- Agent Broker MCP: OpenAPI 3.0.3 specification
- Employee Onboarding MCP: OpenAPI 3.0.3 specification  
- Asset Allocation MCP: OpenAPI 3.0.3 specification
- Notification MCP: OpenAPI 3.0.3 specification

### Related Files
- `../mcp-servers/*/src/main/resources/api/*.yaml` - OpenAPI specifications
- `../docker-compose.yml` - Local development setup
- `../README.md` - Project overview and setup instructions

### Support
For issues or questions:
1. Check service health endpoints
2. Review API specifications
3. Verify environment configuration
4. Check application logs
5. Contact the development team

---

**Created**: January 15, 2024  
**Version**: 1.0.0  
**Last Updated**: January 15, 2024

*This collection provides comprehensive testing capabilities for the Employee Onboarding MCP Services ecosystem. Use the Agent Broker for complete workflow orchestration or individual services for granular control.*
