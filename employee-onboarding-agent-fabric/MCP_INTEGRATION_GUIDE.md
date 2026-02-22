# MCP Integration Guide: Employee Onboarding System

## Overview

This system has been successfully upgraded from a basic React + PostgreSQL setup to a sophisticated **MuleSoft MCP (Model Context Protocol) Agent Broker** architecture. The system now leverages proper MCP protocol to orchestrate complex employee onboarding workflows through intelligent agent coordination.

## Architecture Transformation

### Before: Simple REST APIs
- React client → Direct HTTP calls → Individual MuleSoft services
- Basic CRUD operations
- Manual coordination between services
- Limited error handling and retry mechanisms

### After: MCP Agent Broker Pattern
- React client → MCP Service → **MCP Agent Broker** → Orchestrated MuleSoft services
- Intelligent workflow orchestration
- Proper MCP protocol implementation
- Advanced error handling, retries, and monitoring
- Agent-based coordination with comprehensive status tracking

## MCP Components

### 1. MCP Server (TypeScript)
**Location:** `c:\Users\Pradeep\AppData\Roaming\Code\User\globalStorage\salesforce.mule-dx-vscode\MCP\employee-onboarding-agent-broker\`

**Features:**
- **Tools:** Complete MCP tool implementations for employee onboarding orchestration
- **Resources:** Dynamic and static resource templates for employee data and system status
- **Agent Coordination:** Communicates with MuleSoft Agent Broker for workflow orchestration

**Available MCP Tools:**
- `orchestrate-employee-onboarding` - Complete end-to-end employee onboarding
- `get-onboarding-status` - Real-time status tracking
- `retry-failed-step` - Intelligent error recovery
- `check-system-health` - Comprehensive health monitoring

### 2. MuleSoft Agent Broker
**Location:** `employee-onboarding-agent-fabric/mcp-servers/agent-broker-mcp/`

**Capabilities:**
- **5-Step Orchestration Process:**
  1. Employee profile creation
  2. Asset allocation automation
  3. Welcome email delivery
  4. Asset allocation notifications
  5. Onboarding completion workflow

- **Advanced Error Handling:**
  - Automatic fallback mechanisms
  - Retry logic for failed steps
  - Mock responses when services unavailable

### 3. React MCP Service Integration
**Location:** `employee-onboarding-agent-fabric/react-client/src/services/mcpService.js`

**Features:**
- MCP-aware API service layer
- Intelligent routing (MCP vs Legacy API)
- Enhanced error reporting
- Real-time orchestration feedback

## Getting Started

### 1. Verify MCP Server Configuration

The MCP server is already configured in:
```
c:\Users\Pradeep\AppData\Roaming\Code\User\globalStorage\salesforce.mule-dx-vscode\settings\a4d_mcp_settings.json
```

Configuration:
```json
{
  "mcpServers": {
    "employee-onboarding-agent-broker": {
      "disabled": false,
      "autoApprove": [],
      "command": "node",
      "args": ["c:\\Users\\Pradeep\\AppData\\Roaming\\Code\\User\\globalStorage\\salesforce.mule-dx-vscode\\MCP\\employee-onboarding-agent-broker\\build\\index.js"],
      "env": {
        "AGENT_BROKER_BASE_URL": "http://localhost:8080",
        "EMPLOYEE_SERVICE_URL": "http://localhost:8081",
        "ASSET_SERVICE_URL": "http://localhost:8082",
        "NOTIFICATION_SERVICE_URL": "http://localhost:8083"
      }
    }
  }
}
```

### 2. Start the MuleSoft Services

```bash
# Start all services via Docker
cd employee-onboarding-agent-fabric
docker-compose up -d

# Or use the deployment script
test-docker-deployment.bat
```

### 3. Test MCP Integration

The MCP server will automatically start when you use MCP-enabled tools. Test via the React NLP Chat interface:

**MCP-Powered Commands:**
- "Create new employee John Smith with MCP orchestration"
- "Check system health via MCP"
- "Show me MCP server capabilities"
- "Orchestrate complete onboarding for Sarah Johnson"

## MCP vs Legacy API Behavior

### Employee Creation

**Legacy Request:** "Create employee John Smith"
- Uses basic API service
- Single service call
- Limited orchestration

**MCP Request:** "Create employee John Smith with MCP orchestration" 
- Triggers full MCP orchestration
- 5-step coordinated workflow
- Comprehensive status reporting
- Automatic asset allocation
- Email notifications
- Error recovery mechanisms

### System Health

**Legacy:** Individual service health checks
**MCP:** Comprehensive system-wide health analysis with agent broker coordination

## Testing the MCP Integration

### 1. MCP Tool Testing

You can now use the following MCP tools directly:

```javascript
// Via React MCP Service
import { mcpService } from '../services/mcpService';

// Complete employee onboarding orchestration
const result = await mcpService.orchestrateEmployeeOnboarding({
  firstName: "John",
  lastName: "Smith", 
  email: "john.smith@company.com",
  department: "Engineering",
  position: "Software Developer",
  assets: ["laptop", "phone", "id-card"]
});

// Get onboarding status
const status = await mcpService.getOnboardingStatus("EMP001");

// System health check
const health = await mcpService.checkSystemHealth();
```

### 2. NLP Chat Integration

The NLP Chat component now automatically detects MCP requests:

- **Trigger Words:** "MCP", "orchestration", "orchestrate", "health", "capabilities"
- **Enhanced Responses:** Rich formatted responses with status icons
- **Error Handling:** Graceful fallback with detailed error reporting

### 3. Resource Access

MCP resources are available for system monitoring:

- `employee-onboarding://system/status` - Real-time system status
- `employee-onboarding://system/info` - Complete system capabilities
- `employee-onboarding://{employeeId}/profile` - Employee profile data
- `employee-onboarding://{employeeId}/onboarding-history` - Onboarding history

## Advanced Features

### 1. Intelligent Asset Allocation

MCP orchestration automatically determines appropriate assets based on:
- Department (Engineering, Sales, Marketing, etc.)
- Position level (Manager, Developer, etc.)
- Company policies

### 2. Multi-Step Workflow Coordination

The agent broker coordinates:
1. **Profile Creation** → Employee database entry
2. **Asset Allocation** → Hardware/software provisioning  
3. **Welcome Email** → Personalized onboarding communication
4. **Asset Notifications** → Equipment delivery coordination
5. **Completion Workflow** → Manager notification and final setup

### 3. Error Recovery & Resilience

- **Automatic Retries:** Failed steps are automatically retried
- **Fallback Mechanisms:** H2 database fallback when PostgreSQL unavailable
- **Mock Responses:** Graceful degradation with mock data
- **Status Tracking:** Real-time monitoring of each orchestration step

## MCP Protocol Benefits

### 1. Standardized Communication
- Proper MCP protocol implementation
- Tool and resource schema validation
- Structured error handling

### 2. Enhanced Orchestration
- Agent-based coordination
- Complex workflow management
- Real-time status updates

### 3. Improved Monitoring
- Comprehensive health checks
- Performance tracking
- System-wide visibility

## Troubleshooting

### MCP Server Issues

1. **Check MCP Server Status:**
   ```bash
   # Verify MCP server is running
   node c:\Users\Pradeep\AppData\Roaming\Code\User\globalStorage\salesforce.mule-dx-vscode\MCP\employee-onboarding-agent-broker\build\index.js
   ```

2. **Verify MuleSoft Services:**
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8081/health  
   curl http://localhost:8082/health
   curl http://localhost:8083/health
   ```

3. **Check MCP Configuration:**
   - Verify file paths in MCP settings
   - Ensure environment variables are correct
   - Confirm ports are available

### Common Issues

**Issue:** MCP orchestration fails
**Solution:** Check if all MuleSoft services are running via `docker-compose ps`

**Issue:** "MCP server unreachable" error  
**Solution:** Verify agent broker is running on port 8080

**Issue:** Employee creation works but orchestration fails
**Solution:** Check individual service health endpoints

## Migration Notes

### From Legacy API to MCP

The system maintains backward compatibility:
- Legacy API calls still work
- MCP features are additive
- No breaking changes to existing functionality

### Data Migration

No data migration required:
- Same PostgreSQL database schema
- Existing employee records remain intact
- Asset allocation data preserved

## Next Steps

### Enhanced MCP Features

1. **Advanced Workflows:** Multi-department approval chains
2. **Integration Patterns:** Connect to external HR systems
3. **Analytics Integration:** MCP-powered reporting and insights
4. **Notification Orchestration:** Complex notification workflows

### Monitoring & Observability

1. **MCP Metrics:** Performance monitoring for orchestration workflows
2. **Distributed Tracing:** End-to-end request tracking
3. **Alert Management:** Proactive issue detection

---

## Summary

Your employee onboarding system has been successfully transformed from a simple React + PostgreSQL application into a sophisticated **MCP Agent Broker Architecture**. The system now leverages:

✅ **Proper MCP Protocol Implementation**
✅ **Intelligent Agent Orchestration** 
✅ **5-Step Automated Workflows**
✅ **Advanced Error Handling & Recovery**
✅ **Real-time Status Tracking**
✅ **Comprehensive Health Monitoring**
✅ **Enhanced NLP Chat Integration**

The system maintains full backward compatibility while providing powerful new MCP-driven capabilities for complex employee onboarding orchestration.
