# Centralized Logging Framework Integration Guide

This guide provides manual steps to complete the integration of the centralized logging framework.

## Automatic Updates Completed:
- ✓ Updated log4j2.xml configurations for all services
- ✓ Created logging framework components
- ✓ Generated integration examples

## Manual Steps Required:

### 1. Update Global Configuration Files

For each service, add these imports to the global.xml file:

```xml
<!-- Add these imports after the opening mule tag -->
<import file="../../shared-components/logging-framework/src/main/mule/global-exception-handling.xml"/>
<import file="../../shared-components/logging-framework/src/main/mule/logging-utilities.xml"/>
```

### 2. Update API Flows

Add logging to your API flows by following these patterns:

#### Request/Response Logging:
```xml
<!-- At the start of your flow -->
<flow-ref name="logRequestStart"/>

<!-- Your business logic here -->

<!-- At the end of your flow -->
<flow-ref name="logRequestEnd"/>
```

#### Database Operations:
```xml
<!-- Before database operation -->
<set-variable value="SELECT" variableName="dbOperation"/>
<set-variable value="EMPLOYEES" variableName="dbTable"/>
<flow-ref name="logDatabaseOperation"/>

<!-- Your database operation -->

<!-- After database operation -->
<set-variable value="#[payload.size()]" variableName="recordsAffected"/>
<flow-ref name="logDatabaseOperationEnd"/>
```

#### Business Events:
```xml
<set-variable value="EMPLOYEE_CREATED" variableName="businessEvent"/>
<set-variable value="Employee" variableName="entityType"/>
<set-variable value="#[payload.employeeId]" variableName="entityId"/>
<set-variable value="CREATE" variableName="businessAction"/>
<flow-ref name="logBusinessEvent"/>
```

### 3. Update Error Handling

The global exception handler will automatically handle errors, but you can customize by:

1. Removing existing error handlers from individual flows
2. Letting the global handler manage all exceptions
3. Adding specific business context before errors occur

### 4. Testing the Integration

1. Build and deploy one service first
2. Test all endpoints and verify logging output
3. Check log files are created:
   - {service-name}.log
   - {service-name}-error.log  
   - {service-name}-performance.log
   - {service-name}-audit.log

### 5. Validation Checklist

- [ ] All services compile successfully
- [ ] Log files are generated with correct patterns
- [ ] Performance metrics are logged
- [ ] Error handling works correctly
- [ ] Audit events are captured
- [ ] Request/response correlation IDs are present

## Reference Files:

- Framework Documentation: shared-components/logging-framework/README.md
- Integration Examples: shared-components/logging-framework/integration-example.xml
- Log4j2 Template: shared-components/logging-framework/src/main/resources/log4j2-template.xml

## Support:

For issues or questions, refer to the framework documentation or the integration examples.

