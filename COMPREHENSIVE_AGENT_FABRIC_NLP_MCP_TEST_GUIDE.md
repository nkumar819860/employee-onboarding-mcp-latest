# Comprehensive Agent Fabric NLP + MCP Test Suite

## 🎯 Overview

This comprehensive test suite validates the complete integration between **Agent Fabric**, **MCP (Model Context Protocol)** servers, and **NLP (Natural Language Processing)** capabilities. It provides end-to-end testing for employee onboarding workflows with intelligent natural language understanding.

## 🏗️ Architecture Components Tested

### 1. **Agent Fabric MCP Servers**
- **Agent Broker** (Port 8081) - Central orchestration hub
- **Employee Onboarding** (Port 8082) - Profile management
- **Asset Allocation** (Port 8083) - IT asset management  
- **Email Notification** (Port 8084) - Communication services

### 2. **NLP Processing Engine**
- Intent classification with 6 core business intents
- Named entity recognition (Person, Email, Employee ID, Assets)
- Confidence scoring and contextual understanding
- Multi-turn conversational processing

### 3. **Integration Workflows**
- NLP → MCP command translation
- Multi-service orchestration
- Error handling and recovery
- Asynchronous operation support

## 🧪 Test Coverage

### Health Check Tests
```bash
✅ Agent Broker Health Check
✅ Employee Onboarding Health Check  
✅ Asset Allocation Health Check
✅ Email Notification Health Check
```

### MCP Orchestration Tests
```bash
✅ Complete Onboarding Orchestration
✅ Individual MCP Endpoint Testing
✅ Async Operations Testing
✅ Error Handling Validation
✅ Data Flow Consistency
```

### NLP Integration Tests  
```bash
✅ Intent Classification (70%+ accuracy target)
✅ Entity Extraction (60%+ accuracy target)
✅ NLP to MCP Workflow Translation
✅ Conversational Context Processing
✅ Confidence Score Validation
```

### Load & Performance Tests
```bash
✅ Concurrent Request Handling (5 parallel)
✅ NLP Processing Throughput (50+ phrases/sec)
✅ MCP Orchestration Load (3 concurrent workflows)
```

## 🚀 Quick Start

### Prerequisites
```bash
# Required
- Node.js 14+
- npm or yarn
- Active MCP servers (local or CloudHub)

# Optional
- Docker for containerized testing
- Postman for manual API validation
```

### Installation
```bash
# Install dependencies
npm install axios

# Make script executable (Unix/Mac)
chmod +x test-agent-fabric-comprehensive-nlp-mcp.js

# Run basic test
node test-agent-fabric-comprehensive-nlp-mcp.js
```

## 🎮 Usage Examples

### Local Testing
```bash
# Test against local MCP servers (default)
node test-agent-fabric-comprehensive-nlp-mcp.js --local

# With custom endpoints
AGENT_BROKER_URL=http://localhost:9001 \
EMPLOYEE_ONBOARDING_URL=http://localhost:9002 \
node test-agent-fabric-comprehensive-nlp-mcp.js
```

### CloudHub Testing
```bash
# Test against CloudHub deployments
node test-agent-fabric-comprehensive-nlp-mcp.js --cloudhub

# With environment variable
USE_CLOUDHUB=true node test-agent-fabric-comprehensive-nlp-mcp.js
```

### Programmatic Usage
```javascript
const { 
    runComprehensiveTests, 
    NLPProcessor,
    HealthCheckTests 
} = require('./test-agent-fabric-comprehensive-nlp-mcp.js');

// Run full suite
await runComprehensiveTests();

// Use individual components
const nlp = new NLPProcessor();
const result = nlp.processText("Create employee John Smith");
console.log(result.intent); // "CREATE_EMPLOYEE"
```

## 🎭 NLP Intent Classification

### Supported Business Intents

#### CREATE_EMPLOYEE
**Purpose**: Employee profile creation and onboarding initiation
```javascript
// Sample phrases
"Create a new employee John Smith with email john.smith@company.com"
"Add new hire Sarah Johnson to the system"  
"Register employee Mike Davis for onboarding"

// Extracted entities: PERSON, EMAIL
// Confidence threshold: 0.7+
```

#### ALLOCATE_ASSET  
**Purpose**: IT asset assignment and allocation
```javascript
// Sample phrases
"Allocate laptop to employee EMP001"
"Assign phone to John Smith"
"Provide computer equipment for new hire"

// Extracted entities: EMPLOYEE_ID, ASSET_TYPE, PERSON
// Confidence threshold: 0.6+
```

#### GET_ASSETS
**Purpose**: Asset inventory and availability queries
```javascript
// Sample phrases  
"Show me all available assets"
"What equipment is available for allocation?"
"List current asset inventory"

// Extracted entities: None typically required
// Confidence threshold: 0.6+
```

#### GET_EMPLOYEE_STATUS
**Purpose**: Onboarding progress and employee status tracking
```javascript  
// Sample phrases
"Check the onboarding status of employee EMP001"  
"What is John Smith's onboarding progress?"
"Show employee status for recent hires"

// Extracted entities: EMPLOYEE_ID, PERSON
// Confidence threshold: 0.5+
```

#### SEND_NOTIFICATION
**Purpose**: Communication and notification management
```javascript
// Sample phrases
"Send welcome notification to john.doe@company.com"
"Notify manager about new employee onboarding"  
"Send reminder email to pending employees"

// Extracted entities: EMAIL
// Confidence threshold: 0.5+
```

#### GET_EMPLOYEES
**Purpose**: Employee listing and directory queries  
```javascript
// Sample phrases
"List all employees in the system"
"Show current staff directory"
"Get employee roster by department"

// Extracted entities: None typically required  
// Confidence threshold: 0.5+
```

## 🔧 Configuration Options

### Environment Variables
```bash
# Deployment target
USE_CLOUDHUB=true|false

# Custom endpoints (local)
AGENT_BROKER_URL=http://localhost:8081
EMPLOYEE_ONBOARDING_URL=http://localhost:8082  
ASSET_ALLOCATION_URL=http://localhost:8083
EMAIL_NOTIFICATION_URL=http://localhost:8084

# Test behavior
MAX_RETRIES=3
TIMEOUT=30000
DELAY_BETWEEN_TESTS=1000
```

### CloudHub Endpoints
```javascript
// Default CloudHub URLs (update for your deployment)
CLOUDHUB_ENDPOINTS: {
    AGENT_BROKER: 'https://onboardingbroker.us-e1.cloudhub.io',
    EMPLOYEE_ONBOARDING: 'https://employeeonboardingmcp.us-e1.cloudhub.io',
    ASSET_ALLOCATION: 'https://assetallocationserver.us-e1.cloudhub.io', 
    EMAIL_NOTIFICATION: 'https://emailnotificationmcp.us-e1.cloudhub.io'
}
```

## 📊 Test Results & Reporting

### Console Output
```bash
🚀 Starting Comprehensive Agent Fabric MCP + NLP Test Suite
======================================================================
Deployment Target: Local
Test Start Time: 2024-03-05T15:13:28.792Z
======================================================================

🔍 Running Health Check Tests...
Testing Local endpoints...
✅ Agent Broker Health Check: Service is responsive (200)
✅ Employee Onboarding Health Check: Service is responsive (200)
❌ Asset Allocation Health Check: No responsive health endpoints found
✅ Email Notification Health Check: Service is responsive (200)

🎯 Running MCP Orchestration Tests...
✅ Complete MCP Orchestration: Successfully orchestrated onboarding via /mcp/tools/orchestrate-employee-onboarding
✅ Onboarding Status Verification: Status retrieved successfully
✅ Individual MCP - Employee Creation: POST /api/employee responded successfully
❌ Individual MCP - Asset Listing: No endpoints responded successfully
...
```

### JSON Report Generation
```json
{
  "summary": {
    "total": 25,
    "passed": 22,
    "failed": 3,
    "successRate": "88.0%",
    "duration": "45.67s",
    "deployment": "Local"
  },
  "testDetails": [...],
  "configuration": {
    "endpoints": {...},
    "timeout": 30000,
    "maxRetries": 3
  }
}
```

## 🔍 Troubleshooting Guide

### Common Issues

#### Connection Failures
```bash
# Symptoms
❌ Agent Broker Health Check: Health check failed

# Solutions
1. Verify MCP servers are running
2. Check firewall and port accessibility  
3. Validate endpoint URLs in configuration
4. Test with curl: curl http://localhost:8081/health
```

#### NLP Processing Errors
```bash  
# Symptoms
❌ NLP Intent Classification: Only 3/10 intents classified correctly

# Solutions
1. Review intent patterns and keywords
2. Check entity extraction patterns
3. Validate test phrases against business requirements
4. Adjust confidence thresholds if needed
```

#### CloudHub Connectivity  
```bash
# Symptoms  
❌ Complete MCP Orchestration: No orchestration endpoints responded successfully

# Solutions
1. Verify CloudHub application status
2. Check HTTPS endpoints and certificates
3. Validate CloudHub application names and regions
4. Test with browser: https://your-app.cloudhub.io/health
```

### Debug Mode
```bash
# Enable detailed logging
DEBUG=true node test-agent-fabric-comprehensive-nlp-mcp.js

# Test individual components
node -e "
const { NLPProcessor } = require('./test-agent-fabric-comprehensive-nlp-mcp.js');
const nlp = new NLPProcessor();
console.log(nlp.processText('Create employee John Smith'));
"
```

## 📈 Performance Benchmarks

### Expected Performance Metrics

#### NLP Processing
- **Throughput**: 50+ phrases/second
- **Intent Accuracy**: 70%+ for business intents
- **Entity Extraction**: 60%+ accuracy
- **Response Time**: <50ms per phrase

#### MCP Orchestration
- **End-to-End Workflow**: <5 seconds
- **Individual API Calls**: <2 seconds  
- **Concurrent Requests**: 5+ parallel operations
- **Success Rate**: 80%+ under normal conditions

#### Integration Workflows
- **NLP → MCP Translation**: <100ms
- **Multi-turn Conversations**: 4+ turn processing
- **Error Recovery**: <3 retry attempts
- **Load Handling**: 3+ concurrent orchestrations

## 🔧 Customization & Extension

### Adding New Intents
```javascript
// In NLPProcessor class
this.intentPatterns.NEW_INTENT = {
    keywords: ['keyword1', 'keyword2'],  
    patterns: [/pattern1/i, /pattern2/i]
};
```

### Custom Entity Types
```javascript
// Add to entityPatterns
CUSTOM_ENTITY: {
    patterns: [/your-regex-pattern/g]
}
```

### Additional Test Cases
```javascript
// Extend NLP_TEST_PHRASES array
{
    text: "Your test phrase",
    expectedIntent: "YOUR_INTENT", 
    expectedEntities: ["ENTITY_TYPE"]
}
```

### New Test Suites
```javascript
class CustomTests {
    static async runAll() {
        console.log('\n🔧 Running Custom Tests...');
        await this.yourCustomTest();
    }
    
    static async yourCustomTest() {
        // Your test implementation
        logTest('Custom Test Name', 'PASS', 'Test completed successfully');
    }
}
```

## 🚀 Integration with CI/CD

### GitHub Actions
```yaml
name: Agent Fabric MCP NLP Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install axios
      - run: node test-agent-fabric-comprehensive-nlp-mcp.js --local
```

### Jenkins Pipeline  
```groovy
pipeline {
    agent any
    stages {
        stage('MCP NLP Tests') {
            steps {
                sh 'npm install axios'
                sh 'node test-agent-fabric-comprehensive-nlp-mcp.js'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'test-report-*.json'
                }
            }
        }
    }
}
```

## 📚 Related Documentation

- [MCP Integration Guide](employee-onboarding-agent-fabric/MCP_INTEGRATION_GUIDE.md)
- [Agent Fabric Architecture](employee-onboarding-agent-fabric/ENHANCED_AGENT_FABRIC_INTEGRATION_ARCHITECTURE.md)
- [Deployment Guide](employee-onboarding-agent-fabric/CLOUDHUB_DEPLOYMENT_GUIDE.md)
- [API Documentation](employee-onboarding-agent-fabric/src/main/resources/api/)
- [Postman Collections](employee-onboarding-agent-fabric/Postman/)

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/enhanced-nlp-tests`
3. Add comprehensive test cases
4. Ensure all existing tests pass
5. Submit pull request with detailed description

### Code Standards
- Follow existing code structure and patterns
- Add JSDoc comments for new functions
- Include error handling and logging
- Maintain backward compatibility
- Update documentation for new features

---

**🎉 Happy Testing!** This comprehensive suite ensures your Agent Fabric MCP + NLP integration is robust, reliable, and ready for production workloads.
