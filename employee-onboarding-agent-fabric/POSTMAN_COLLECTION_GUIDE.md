# Employee Onboarding MCP Services - Postman Collection Guide

This guide explains how to use the comprehensive Postman collection for testing all Employee Onboarding MCP services.

## 📋 Collection Overview

The collection includes:
- **🏥 Health Checks**: Verify all services are running
- **🚀 MCP Agent Broker Orchestration**: Complete employee onboarding workflows
- **👥 Employee Service**: Direct employee CRUD operations
- **💼 Asset Allocation Service**: Asset management endpoints
- **📧 Notification Service**: Email notification endpoints
- **🔄 End-to-End Workflows**: Complete integration tests

## 🚀 Quick Start

### 1. Import the Collection
1. Open Postman
2. Click **Import**
3. Select `Employee-Onboarding-MCP-Services.postman_collection.json`
4. The collection will be imported with all requests and environments pre-configured

### 2. Environment Variables
The collection automatically sets these environment variables:
- `AGENT_BROKER_URL`: `http://agent-broker-mcp-server.us-e1.cloudhub.io`
- `EMPLOYEE_SERVICE_URL`: `http://employee-onboarding-mcp-server.us-e1.cloudhub.io`
- `ASSET_SERVICE_URL`: `http://asset-allocation-mcp-server.us-e1.cloudhub.io`
- `NOTIFICATION_SERVICE_URL`: `http://employee-notification-service.us-e1.cloudhub.io`

## 📚 Request Details

### 🏥 Health Checks

#### Agent Broker Health
- **URL**: `{{AGENT_BROKER_URL}}/health`
- **Method**: GET
- **Purpose**: Verify the MCP Agent Broker service is running
- **Expected Response**: 
  ```json
  {
    "status": "UP",
    "service": "Employee Onboarding Agent Broker"
  }
  ```

#### Individual Service Health Checks
Similar health checks for:
- Employee Service (`/health`)
- Asset Service (`/health`)
- Notification Service (`/health`)

### 🚀 MCP Agent Broker Orchestration

#### Complete Employee Onboarding Orchestration
- **URL**: `{{AGENT_BROKER_URL}}/mcp/tools/orchestrate-employee-onboarding`
- **Method**: POST
- **Purpose**: Execute complete employee onboarding workflow through MCP
- **Body**:
  ```json
  {
    "firstName": "John",
    "lastName": "Smith",
    "email": "john.smith@company.com",
    "phone": "+1-555-0123",
    "department": "Engineering",
    "position": "Senior Software Developer",
    "startDate": "2024-03-15",
    "salary": 95000,
    "manager": "Sarah Johnson",
    "managerEmail": "sarah.johnson@company.com",
    "companyName": "Tech Innovations Inc",
    "assets": ["laptop", "phone", "id-card", "monitor", "keyboard-mouse"]
  }
  ```
- **Response**: Creates employee, allocates assets, sends notifications
- **Auto-Variables**: Sets `GENERATED_EMPLOYEE_ID` for subsequent requests

#### Get Employee Onboarding Status
- **URL**: `{{AGENT_BROKER_URL}}/mcp/tools/get-onboarding-status?employeeId={{GENERATED_EMPLOYEE_ID}}`
- **Method**: GET
- **Purpose**: Check the status of an employee's onboarding process
- **Uses**: `GENERATED_EMPLOYEE_ID` from previous orchestration

#### Retry Failed Onboarding Step
- **URL**: `{{AGENT_BROKER_URL}}/mcp/tools/retry-failed-step`
- **Method**: POST
- **Purpose**: Retry a specific failed step in the onboarding process
- **Body**:
  ```json
  {
    "employeeId": "{{GENERATED_EMPLOYEE_ID}}",
    "step": "asset-allocation"
  }
  ```

#### Check MCP System Health
- **URL**: `{{AGENT_BROKER_URL}}/mcp/tools/check-system-health`
- **Method**: GET
- **Purpose**: Get comprehensive health status of all MCP services
- **Response**: Overall system status with individual service details

### 👥 Employee Service (Individual)

#### Create Employee Profile
- **URL**: `{{EMPLOYEE_SERVICE_URL}}/employees`
- **Method**: POST
- **Purpose**: Create employee profile directly (without orchestration)
- **Body**: Employee details
- **Auto-Variables**: Sets `DIRECT_EMPLOYEE_ID`

#### Get All Employees
- **URL**: `{{EMPLOYEE_SERVICE_URL}}/employees`
- **Method**: GET
- **Purpose**: Retrieve all employee records

### 💼 Asset Allocation Service

#### Get Available Assets
- **URL**: `{{ASSET_SERVICE_URL}}/assets/available`
- **Method**: GET
- **Purpose**: List all available assets for allocation

#### Allocate Asset to Employee
- **URL**: `{{ASSET_SERVICE_URL}}/assets/allocate`
- **Method**: POST
- **Purpose**: Directly allocate an asset to an employee
- **Body**:
  ```json
  {
    "employeeId": "{{DIRECT_EMPLOYEE_ID}}",
    "assetType": "laptop",
    "assetModel": "Dell XPS 13",
    "serialNumber": "DXP13-2024-001",
    "allocatedDate": "2024-03-20",
    "notes": "Standard laptop allocation for new employee"
  }
  ```

### 📧 Notification Service

#### Send Welcome Email
- **URL**: `{{NOTIFICATION_SERVICE_URL}}/notifications/send`
- **Method**: POST
- **Purpose**: Send welcome email to new employee
- **Body**:
  ```json
  {
    "employeeId": "{{DIRECT_EMPLOYEE_ID}}",
    "employeeName": "Maria Garcia",
    "employeeEmail": "maria.garcia@company.com",
    "notificationType": "welcome",
    "templateData": {
      "companyName": "Tech Innovations Inc",
      "position": "Marketing Manager",
      "startDate": "2024-03-20",
      "manager": "Robert Chen"
    }
  }
  ```

#### Send Asset Allocation Notification
- **URL**: `{{NOTIFICATION_SERVICE_URL}}/notifications/send`
- **Method**: POST
- **Purpose**: Notify employee about asset allocation
- **Body**: Asset allocation details with pickup instructions

## 🔄 Testing Workflows

### Complete End-to-End Test
1. **Health Checks**: Run all health check requests to verify services are up
2. **MCP Orchestration**: Execute "Complete Employee Onboarding Orchestration"
3. **Status Check**: Use "Get Employee Onboarding Status" to verify completion
4. **Individual Services**: Test direct service calls if needed

### Automated Testing
The collection includes test scripts that:
- Verify response status codes
- Check response structure
- Set environment variables for chaining requests
- Validate business logic responses

## 🛠️ Customization

### Custom Environment Variables
You can override the default URLs by setting:
- `AGENT_BROKER_URL` - Your custom Agent Broker URL
- `EMPLOYEE_SERVICE_URL` - Your custom Employee Service URL
- `ASSET_SERVICE_URL` - Your custom Asset Service URL
- `NOTIFICATION_SERVICE_URL` - Your custom Notification Service URL

### Local Development
For local testing, update the environment variables to:
- `AGENT_BROKER_URL`: `http://localhost:8081`
- `EMPLOYEE_SERVICE_URL`: `http://localhost:8082`
- `ASSET_SERVICE_URL`: `http://localhost:8083`
- `NOTIFICATION_SERVICE_URL`: `http://localhost:8084`

## 🧪 Test Scenarios

### Scenario 1: Complete MCP Orchestration
1. Run "Agent Broker Health" to ensure service is up
2. Execute "Complete Employee Onboarding Orchestration"
3. Check "Get Employee Onboarding Status"
4. Verify all steps completed successfully

### Scenario 2: Individual Service Testing
1. Run all health checks
2. Create employee via "Create Employee Profile"
3. Allocate asset via "Allocate Asset to Employee"
4. Send welcome email via "Send Welcome Email"

### Scenario 3: Error Handling
1. Execute orchestration with invalid data
2. Test "Retry Failed Onboarding Step"
3. Verify error responses and retry mechanisms

## 📊 Expected Response Formats

### Successful MCP Orchestration
```json
{
  "status": "success",
  "message": "Employee onboarding orchestration completed successfully",
  "employeeId": "d9324b88",
  "employeeName": "John Smith",
  "email": "john.smith@company.com",
  "onboardingSteps": [
    {
      "step": "profile-creation",
      "status": "completed",
      "timestamp": "2024-03-15T10:30:00Z"
    },
    {
      "step": "asset-allocation",
      "status": "completed",
      "timestamp": "2024-03-15T10:31:00Z"
    },
    {
      "step": "welcome-email",
      "status": "completed",
      "timestamp": "2024-03-15T10:32:00Z"
    }
  ]
}
```

### Health Check Response
```json
{
  "status": "UP",
  "service": "Employee Onboarding Agent Broker",
  "timestamp": "2024-03-15T10:30:00Z",
  "version": "1.0.10"
}
```

## 🔍 Troubleshooting

### Common Issues

1. **Service Unreachable**
   - Check if CloudHub services are running
   - Verify environment variable URLs
   - Test individual health checks

2. **Authentication Errors**
   - Ensure proper headers are set
   - Check if any authentication tokens are needed

3. **Data Validation Errors**
   - Verify request body format
   - Check required fields are provided
   - Validate data types and formats

### Debug Tips
- Use Postman Console to view request/response details
- Check the Tests tab for automated validation results
- Review environment variables for correct URLs
- Monitor CloudHub application logs for detailed error information

## 📈 Performance Testing

The collection can be used with Postman's Collection Runner for:
- Load testing multiple employee onboardings
- Performance benchmarking of individual services
- Stress testing the MCP orchestration workflow

## 🔐 Security Considerations

- All requests use HTTP for CloudHub compatibility
- No authentication tokens are required for testing
- In production, consider adding proper authentication headers
- Sensitive data should be masked in test requests

---

This collection provides comprehensive testing capabilities for the entire Employee Onboarding MCP system, from individual service testing to complete end-to-end workflow validation.
