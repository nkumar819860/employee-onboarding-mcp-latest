# Employee Onboarding Agent Broker

## Overview

The Employee Onboarding Agent Broker is a comprehensive MCP (Model Context Protocol) server that orchestrates the complete employee onboarding process. It acts as the central coordinator that integrates with multiple specialized MCP servers to provide a seamless, automated onboarding experience.

## Architecture

### Agent Network Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    Agent Network Layer                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐│
│  │ Onboarding       │  │ Employee         │  │ Asset           ││
│  │ Orchestrator     │  │ Manager          │  │ Allocator       ││
│  │ Agent            │  │ Agent            │  │ Agent           ││
│  └──────────────────┘  └──────────────────┘  └─────────────────┘│
│            │                     │                     │        │
│  ┌─────────────────┐             │            ┌─────────────────┐│
│  │ Notification    │             │            │ Main Broker     ││
│  │ Sender Agent    │             │            │ (Orchestrator)  ││
│  └─────────────────┘             │            └─────────────────┘│
└─────────────────────────────────────────────────────────────────┘
            │                     │                     │
┌─────────────────────────────────────────────────────────────────┐
│                      MCP Server Layer                           │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────────┐│
│  │ Employee         │  │ Asset Allocation │  │ Notification    ││
│  │ Onboarding       │  │ MCP Server       │  │ MCP Server      ││
│  │ MCP Server       │  │ (Port 8082)      │  │ (Port 8083)     ││
│  │ (Port 8081)      │  └──────────────────┘  └─────────────────┘│
│  └──────────────────┘                                           │
│            │                     │                     │        │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ Employee Onboarding Agent Broker MCP Server (Port 8084)    ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Features

### 🎯 Core Capabilities
- **Complete Process Orchestration**: Coordinates all aspects of employee onboarding
- **Multi-Service Integration**: Integrates with employee management, asset allocation, and notification services
- **Error Handling & Recovery**: Robust error handling with retry mechanisms
- **Status Tracking**: Real-time status monitoring and reporting
- **Agent Network Support**: Fully compatible with agent network architectures

### 🛠 MCP Tools
1. **orchestrate-employee-onboarding**: Complete end-to-end onboarding orchestration
2. **get-onboarding-status**: Retrieve current status of onboarding process
3. **retry-failed-step**: Retry any failed step in the onboarding process

### 🔄 Orchestration Flow
1. **Employee Profile Creation** → Validates and creates employee record
2. **Asset Allocation** → Assigns appropriate assets based on role/department
3. **Welcome Email** → Sends personalized welcome email
4. **Asset Notification** → Notifies about allocated assets
5. **Completion Notification** → Sends final onboarding completion email

## Quick Start

### Prerequisites
- Java 17+
- Mule Runtime 4.11.1+
- Access to employee onboarding, asset allocation, and notification MCP servers
- Groq API key for agent network (optional)

### Installation

1. **Clone and navigate to the project:**
   ```bash
   cd employee-onboarding-agent-broker
   ```

2. **Install dependencies:**
   ```bash
   mvn clean install
   ```

3. **Configure environment variables:**
   ```bash
   # Required for agent network
   export GROQ_API_KEY="your_groq_api_key"
   
   # MCP server URLs (default values shown)
   export EMPLOYEE_ONBOARDING_MCP_URL="http://localhost:8081"
   export ASSET_ALLOCATION_MCP_URL="http://localhost:8082"
   export NOTIFICATION_MCP_URL="http://localhost:8083"
   ```

4. **Run the application:**
   ```bash
   mvn mule:run
   ```

The agent broker will start on port **8084**.

## API Endpoints

### Health Check
```
GET http://localhost:8084/health
```

### MCP Server Info
```
GET http://localhost:8084/mcp/info
```

### Complete Employee Onboarding
```
POST http://localhost:8084/mcp/tools/orchestrate-employee-onboarding

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@company.com",
  "department": "Engineering",
  "position": "Software Developer",
  "startDate": "2024-03-01",
  "manager": "Jane Smith",
  "managerEmail": "jane.smith@company.com",
  "companyName": "Tech Corp",
  "assets": [
    {
      "category": "laptop",
      "specifications": "MacBook Pro 16-inch"
    },
    {
      "category": "monitor",
      "specifications": "27-inch 4K display"
    }
  ]
}
```

### Get Onboarding Status
```
POST http://localhost:8084/mcp/tools/get-onboarding-status

{
  "employeeId": "EMP001"
}
```

### Retry Failed Step
```
POST http://localhost:8084/mcp/tools/retry-failed-step

{
  "employeeId": "EMP001",
  "step": "asset-allocation"
}
```

## Agent Network Configuration

The project includes a comprehensive `agent-network.yaml` configuration that defines:

### 🤖 Agents
- **Onboarding Orchestrator**: Main coordination agent
- **Employee Manager**: Handles employee profile operations
- **Asset Allocator**: Manages asset allocation and tracking
- **Notification Sender**: Handles all email communications

### 🔧 LLM Integration
- **Provider**: Groq
- **Model**: llama3-8b-8192
- **API Integration**: OpenAI-compatible API
- **Configuration**: Temperature, max tokens, timeout settings

### 🌐 MCP Servers
- Employee Onboarding MCP Server (Port 8081)
- Asset Allocation MCP Server (Port 8082)
- Notification MCP Server (Port 8083)
- Agent Broker MCP Server (Port 8084)

### 📋 Workflows
Defined workflows for complete employee onboarding with dependency management and error handling.

## Configuration

### Environment Variables
```properties
# HTTP Server
HTTP_PORT=8084
HTTP_HOST=0.0.0.0

# MCP Servers
EMPLOYEE_ONBOARDING_MCP_URL=http://localhost:8081
ASSET_ALLOCATION_MCP_URL=http://localhost:8082
NOTIFICATION_MCP_URL=http://localhost:8083

# Groq LLM (for agent network)
GROQ_API_KEY=your_groq_api_key

# Request Configuration
MCP_REQUEST_TIMEOUT=30000
MCP_RETRY_MAX_ATTEMPTS=3
MCP_RETRY_DELAY=1000
```

### Dependencies
The agent broker integrates with:
- **Employee Onboarding MCP Server**: Employee profile management
- **Asset Allocation MCP Server**: Asset assignment and tracking
- **Notification MCP Server**: Email notifications and communications

## Error Handling

### Robust Error Management
- **Connection Errors**: Automatic retry with exponential backoff
- **Timeout Handling**: Configurable timeout with graceful degradation
- **Partial Failures**: Continue processing other steps when possible
- **Detailed Logging**: Comprehensive error tracking and reporting

### Error Response Format
```json
{
  "status": "error",
  "message": "Employee onboarding orchestration failed",
  "error": "Connection timeout to asset allocation service",
  "employeeEmail": "john.doe@company.com",
  "failedAt": "Step 2: Asset Allocation",
  "startTime": "2024-02-21 23:45:00",
  "errorTime": "2024-02-21 23:45:15",
  "timestamp": "2024-02-21 23:45:15"
}
```

## Success Response Format
```json
{
  "status": "success",
  "message": "Employee onboarding orchestration completed successfully",
  "employeeId": "EMP001",
  "employeeName": "John Doe",
  "email": "john.doe@company.com",
  "onboardingSteps": {
    "profileCreation": {
      "status": "completed",
      "result": { "employeeId": "EMP001", "message": "Employee created successfully" }
    },
    "assetAllocation": {
      "status": "completed",
      "assetsAllocated": 2,
      "result": { "allocatedAssets": [...] }
    },
    "welcomeEmail": {
      "status": "completed",
      "result": { "message": "Welcome email sent successfully" }
    },
    "assetNotification": {
      "status": "completed", 
      "result": { "message": "Asset notification sent successfully" }
    },
    "onboardingComplete": {
      "status": "completed",
      "result": { "message": "Onboarding complete notification sent" }
    }
  },
  "startTime": "2024-02-21 23:45:00",
  "completionTime": "2024-02-21 23:45:30",
  "totalDuration": "PT30S",
  "timestamp": "2024-02-21 23:45:30"
}
```

## Development

### Project Structure
```
employee-onboarding-agent-broker/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── global.xml                          # Global configurations
│   │   │   └── employee-onboarding-agent-broker.xml # Main application flows
│   │   └── resources/
│   │       └── config.properties                   # Configuration properties
│   └── test/
├── agent-network.yaml                              # Agent network configuration
├── pom.xml                                         # Maven project configuration
├── exchange.json                                   # Exchange publication metadata
├── mule-artifact.json                             # Mule artifact configuration
└── README.md                                       # This file
```

### Building
```bash
mvn clean compile
```

### Testing
```bash
mvn test
```

### Deployment
```bash
mvn clean package
```

## Monitoring and Observability

### Health Monitoring
- Service health checks for all integrated MCP servers
- Real-time status monitoring
- Performance metrics collection

### Logging
- Structured logging with correlation IDs
- Detailed step-by-step process logging
- Error tracking and alerting

### Metrics
- Process completion times
- Success/failure rates
- Service availability metrics
- Resource utilization tracking

## Security Considerations

### Data Protection
- Secure handling of employee PII
- Encrypted communication between services
- Audit logging for compliance

### Access Control
- API key-based authentication
- Role-based authorization
- Service-to-service authentication

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## Support

For questions, issues, or contributions, please contact the MCP Development Team.

## License

Copyright (c) 2024 MuleSoft. All rights reserved.
