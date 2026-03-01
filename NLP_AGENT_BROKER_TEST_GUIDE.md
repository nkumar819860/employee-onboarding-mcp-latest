# NLP Agent Broker Testing Guide

## 🎯 Overview

This guide provides comprehensive information about testing the MCP Agent Broker with NLP (Natural Language Processing) capabilities using the `test-agent-broker-nlp.bat` script.

## 📋 Prerequisites

### Required Tools
- **curl**: Command-line tool for making HTTP requests
- **Windows Command Prompt**: For running the batch script
- **Internet Connection**: To reach CloudHub endpoints (or local server)

### System Requirements
- Windows 10/11 or Windows Server
- PowerShell or Command Prompt access
- Network access to CloudHub or local development environment

## 🚀 Quick Start

### Running the Test Suite

1. **Open Command Prompt** as Administrator (recommended)
2. **Navigate to the project directory**:
   ```cmd
   cd c:\Users\Pradeep\AI\employee-onboarding
   ```
3. **Execute the test script**:
   ```cmd
   test-agent-broker-nlp.bat
   ```

## 🧪 Test Cases Explained

### Test 1: System Health Check
**Purpose**: Verifies basic connectivity to the MCP Agent Broker
**NLP Simulation**: "Check system health via MCP"
**Expected Result**: HTTP 200 with health status JSON

```json
{
  "status": "UP",
  "service": "Employee Onboarding Agent Broker",
  "timestamp": "2024-03-01 17:30:00",
  "orchestrationEnabled": "true"
}
```

### Test 2: MCP Server Capabilities
**Purpose**: Retrieves available MCP tools and server information
**NLP Simulation**: "Show me MCP server capabilities"
**Expected Result**: List of available MCP tools

```json
{
  "name": "Employee Onboarding Agent Broker",
  "version": "1.0.0",
  "description": "Agent Broker MCP Server for Employee Onboarding Process Orchestration",
  "tools": [
    {
      "name": "orchestrate-employee-onboarding",
      "description": "Complete employee onboarding process orchestration",
      "endpoint": "/mcp/tools/orchestrate-employee-onboarding"
    }
  ]
}
```

### Test 3: NLP Employee Onboarding
**Purpose**: Simulates complete employee onboarding via natural language
**NLP Simulation**: "Create new employee Alice Johnson with MCP orchestration"
**Headers Used**:
- `X-NLP-Intent: CREATE_EMPLOYEE`
- `X-NLP-Entities: PERSON:Alice Johnson`
- `X-NLP-Confidence: 0.95`

### Test 4: NLP Status Check
**Purpose**: Tests employee status retrieval
**NLP Simulation**: "Check employee onboarding status for EMP001"
**Headers Used**:
- `X-NLP-Intent: GET_EMPLOYEE_STATUS`
- `X-NLP-Entities: EMPLOYEE_ID:EMP001`
- `X-NLP-Confidence: 0.90`

### Test 5: NLP Retry Failed Step
**Purpose**: Tests step retry functionality
**NLP Simulation**: "Retry asset allocation step for employee EMP001"
**Headers Used**:
- `X-NLP-Intent: RETRY_STEP`
- `X-NLP-Entities: EMPLOYEE_ID:EMP001,STEP:asset-allocation`

### Test 6: Complex NLP Scenario
**Purpose**: Tests multi-entity extraction and processing
**NLP Simulation**: "Onboard John Smith from HR department starting Monday"
**Headers Used**:
- `X-NLP-Entities: PERSON:John Smith,DEPARTMENT:HR,DATE:Monday`
- `X-NLP-Sentiment: 0.75`

### Test 7: Error Handling
**Purpose**: Validates error handling with invalid data
**Expected Result**: Proper error response with details

### Test 8: CORS Headers
**Purpose**: Tests browser compatibility for frontend integration
**Method**: OPTIONS preflight request
**Expected Result**: Proper CORS headers returned

### Test 9: Load Testing
**Purpose**: Simulates multiple concurrent NLP requests
**Method**: 3 concurrent health check requests
**Expected Result**: All requests should complete successfully

### Test 10: Voice Input Simulation
**Purpose**: Tests voice-based NLP requests
**NLP Simulation**: "Hey system, create employee Sarah Davis"
**Headers Used**:
- `X-NLP-Source: VOICE`
- `X-NLP-Language: en-US`

## 📊 Understanding Test Results

### Success Indicators
- **HTTP 200**: Successful request processing
- **HTTP 201**: Resource created successfully
- **Proper JSON Response**: Valid response structure
- **CORS Headers Present**: Browser compatibility confirmed

### Common Error Codes
- **HTTP 404**: Endpoint not found (check URL)
- **HTTP 500**: Server error (backend issues)
- **HTTP 502/504**: Gateway errors (CloudHub connectivity)
- **Connection Refused**: Server not running

## 🔧 Troubleshooting

### CloudHub Connectivity Issues
If CloudHub endpoints are unreachable, the script automatically falls back to local endpoints:
```
CloudHub: https://employee-onboarding-agent-broker.us-e1.cloudhub.io
Local: http://localhost:8084
```

### Local Testing Setup
For local testing, ensure:
1. Mule application is running on port 8084
2. All MCP servers are deployed and accessible
3. Database connections are configured
4. No firewall blocking HTTP traffic

### Common Issues and Solutions

#### Issue: "curl command not found"
**Solution**: Install curl or use PowerShell Invoke-WebRequest
```powershell
Invoke-WebRequest -Uri "http://localhost:8084/health" -Method GET
```

#### Issue: Connection timeout
**Solution**: Check if services are running
```cmd
netstat -an | findstr :8084
```

#### Issue: CORS errors in browser
**Solution**: Verify CORS headers in Test 8 output

## 🎨 Customizing Tests

### Adding New Test Cases
1. Create new test section in the batch file
2. Define appropriate NLP headers
3. Set expected payload structure
4. Add to test summary

### NLP Header Reference
```
X-NLP-Intent: Intent classification (CREATE_EMPLOYEE, GET_STATUS, etc.)
X-NLP-Entities: Extracted entities (PERSON:Name, ID:Value, etc.)
X-NLP-Confidence: Confidence score (0.0-1.0)
X-NLP-Sentiment: Sentiment analysis score (-1.0 to 1.0)
X-NLP-Source: Input source (TEXT, VOICE, etc.)
X-NLP-Language: Language code (en-US, es-ES, etc.)
```

### Sample Employee JSON Payload
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@company.com",
  "phone": "+1-555-0123",
  "department": "Engineering",
  "position": "Software Developer",
  "startDate": "2024-03-15",
  "salary": 75000,
  "manager": "Jane Smith",
  "managerEmail": "jane.smith@company.com",
  "companyName": "Tech Corp",
  "assets": ["laptop", "monitor", "phone"]
}
```

## 📈 Performance Expectations

### Response Times
- **Health Check**: < 2 seconds
- **MCP Info**: < 3 seconds
- **Employee Onboarding**: < 60 seconds (full workflow)
- **Status Check**: < 10 seconds
- **Retry Operations**: < 30 seconds

### Throughput
- **Concurrent Requests**: Up to 10 simultaneous
- **Request Rate**: 1-2 requests per second recommended
- **Timeout Settings**: 30-60 seconds per request

## 🔒 Security Considerations

### Headers for Production
```
Authorization: Bearer <token>
X-API-Key: <api-key>
X-Client-ID: <client-id>
Content-Type: application/json
User-Agent: <your-app-name>
```

### Rate Limiting
- Implement request throttling
- Use authentication tokens
- Monitor for abuse patterns
- Log all requests for audit

## 📝 Test Output Analysis

### Successful Test Run Example
```
========================================
           TEST SUMMARY
========================================

✓ Health Check
✓ MCP Server Info
✓ Employee Onboarding (NLP)
✓ Status Check (NLP)
✓ Retry Failed Step (NLP)
✓ Complex NLP Scenario
✓ Error Handling
✓ CORS Headers
✓ Load Testing
✓ Voice Input Simulation

All NLP-style tests completed!
```

### Failed Test Analysis
Look for:
- HTTP error codes in response
- Connection timeout messages
- JSON parsing errors
- Missing CORS headers

## 🔄 Integration with NLP Frontend

### React Component Integration
The test script simulates how the React NLP component calls the agent broker:

```javascript
// Example from NLPChat.js
const result = await mcpService.orchestrateEmployeeOnboarding(employeeData);
```

### API Service Layer
The `mcpService.js` handles:
- Intent classification
- Entity extraction
- MCP tool invocation
- Error handling

### Natural Language Processing Flow
1. **User Input**: "Create employee John Smith"
2. **NLP Processing**: Extract intent and entities
3. **MCP Translation**: Convert to MCP tool call
4. **Agent Broker**: Execute orchestration
5. **Response**: Return structured result

## 🎯 Best Practices

### Test Execution
1. Run tests in isolated environment first
2. Verify all services are healthy before testing
3. Monitor logs during test execution
4. Clean up test data after completion

### Result Validation
1. Check HTTP status codes
2. Validate JSON response structure
3. Verify business logic results
4. Confirm error handling works

### Documentation
1. Record test results with timestamps
2. Document any failures or issues
3. Track performance metrics over time
4. Update test cases as system evolves

## 📞 Support and Troubleshooting

### Getting Help
- Check CloudHub application logs
- Review Mule application console output
- Verify network connectivity
- Validate configuration files

### Common Support Requests
1. **Connection Issues**: Check firewall and network settings
2. **Authentication Errors**: Verify credentials and tokens
3. **Performance Issues**: Monitor resource usage
4. **Data Issues**: Validate input payload format

---

## 🏃‍♂️ Quick Reference Commands

### Run Full Test Suite
```cmd
test-agent-broker-nlp.bat
```

### Test Individual Endpoint
```cmd
curl -X GET "http://localhost:8084/health"
```

### Check Service Status
```cmd
curl -X GET "http://localhost:8084/mcp/info"
```

### Manual Employee Creation
```cmd
curl -X POST "http://localhost:8084/mcp/tools/orchestrate-employee-onboarding" ^
     -H "Content-Type: application/json" ^
     -d "{\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"test@company.com\"}"
```

This comprehensive test suite validates the complete MCP Agent Broker integration with NLP capabilities, ensuring robust natural language processing for employee onboarding workflows.
