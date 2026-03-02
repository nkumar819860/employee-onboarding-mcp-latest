# Centralized Logging Framework for MCP Services

This centralized logging framework provides a consistent, reusable approach to logging and exception handling across all MCP services.

## Overview

The framework consists of three main components:

1. **Standardized Log4j2 Configuration** - Consistent logging patterns and appenders
2. **Global Exception Handling** - Centralized error handling with structured responses
3. **Reusable Logging Utilities** - Common logging flows for various scenarios

## Features

- **Multiple Log Files**: Application, Error, Performance, and Audit logs
- **Structured Logging**: Consistent log patterns with correlation IDs
- **Performance Monitoring**: Automatic performance metrics logging
- **Audit Trail**: Security and compliance logging
- **Global Exception Handling**: Standardized error responses
- **Log Rotation**: Automatic log rotation and compression

## Implementation Guide

### 1. Log4j2 Configuration

Each service should use the template log4j2 configuration with service-specific parameters:

```xml
<!-- In your service's log4j2.xml -->
<!-- Set the service name system property -->
-Dmcp.service.name=your-service-name
```

### 2. Global Exception Handling

Import the global exception handling in your service's global.xml:

```xml
<!-- In your service's global.xml -->
<import file="shared-components/logging-framework/src/main/mule/global-exception-handling.xml"/>
```

### 3. Logging Utilities

Import the logging utilities in your service flows:

```xml
<!-- In your service flows -->
<import file="shared-components/logging-framework/src/main/mule/logging-utilities.xml"/>
```

## Usage Examples

### Request/Response Logging

```xml
<!-- At the start of your API flow -->
<flow-ref name="logRequestStart"/>

<!-- Your business logic here -->

<!-- At the end of your API flow -->
<flow-ref name="logRequestEnd"/>
```

### Database Operations

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

### HTTP Client Calls

```xml
<!-- Before HTTP request -->
<set-variable value="https://api.example.com/users" variableName="targetUrl"/>
<set-variable value="GET" variableName="httpMethod"/>
<flow-ref name="logHttpClientRequest"/>

<!-- Your HTTP request -->

<!-- After HTTP response -->
<flow-ref name="logHttpClientResponse"/>
```

### Business Events

```xml
<set-variable value="EMPLOYEE_CREATED" variableName="businessEvent"/>
<set-variable value="Employee" variableName="entityType"/>
<set-variable value="#[payload.employeeId]" variableName="entityId"/>
<set-variable value="CREATE" variableName="businessAction"/>
<flow-ref name="logBusinessEvent"/>
```

### Validation Logging

```xml
<set-variable value="EMAIL_VALIDATION" variableName="validationType"/>
<set-variable value="Employee" variableName="entityType"/>
<set-variable value="#[vars.isValid]" variableName="validationResult"/>
<set-variable value="#[vars.errors]" variableName="validationErrors"/>
<flow-ref name="logValidationResult"/>
```

### Security Events

```xml
<set-variable value="AUTHENTICATION" variableName="securityEventType"/>
<set-variable value="LOGIN_ATTEMPT" variableName="securityAction"/>
<set-variable value="/api/employees" variableName="resourceAccessed"/>
<flow-ref name="logSecurityEvent"/>
```

### Audit Events

```xml
<set-variable value="DATA_ACCESS" variableName="auditAction"/>
<set-variable value="Employee ID: 12345 accessed" variableName="auditDetails"/>
<flow-ref name="logAuditEvent"/>
```

## Log Categories and Levels

### Categories
- `com.mulesoft.mcp.request` - Request/Response logging
- `com.mulesoft.mcp.database` - Database operations
- `com.mulesoft.mcp.http.client` - HTTP client operations
- `com.mulesoft.mcp.business` - Business logic events
- `com.mulesoft.mcp.validation` - Validation results
- `com.mulesoft.mcp.security` - Security events
- `com.mulesoft.mcp.exception.*` - Exception handling
- `PERFORMANCE` - Performance metrics
- `AUDIT` - Audit trail

### Log Levels
- **ERROR**: System errors, exceptions
- **WARN**: Warnings, validation failures, security events
- **INFO**: General information, business events
- **DEBUG**: Detailed debugging information

## Log File Structure

### Application Log (`{service-name}.log`)
- All general application logs
- Request/response information
- Business events
- Database operations

### Error Log (`{service-name}-error.log`)
- ERROR level logs only
- Exception details and stack traces
- Critical system issues

### Performance Log (`{service-name}-performance.log`)
- Performance metrics
- Response times
- Slow operation alerts
- External API call metrics

### Audit Log (`{service-name}-audit.log`)
- Security events
- Configuration changes
- Business operation audit trail
- Compliance logging

## Performance Thresholds

- **Slow Request Alert**: > 5000ms
- **Slow Database Operation**: > 1000ms

## Variables Used by Framework

### Request Context Variables
- `requestStartTime` - Request start timestamp
- `requestMethod` - HTTP method
- `requestUri` - Request URI
- `clientIP` - Client IP address
- `userAgent` - User agent string
- `contentType` - Content type
- `responseTime` - Response time in milliseconds
- `responseStatus` - HTTP response status

### Database Context Variables
- `dbOperation` - Database operation type (SELECT, INSERT, etc.)
- `dbTable` - Database table name
- `recordsAffected` - Number of records affected
- `dbOperationTime` - Database operation time in milliseconds

### HTTP Client Variables
- `targetUrl` - Target URL for HTTP client
- `httpMethod` - HTTP method
- `httpClientResponseTime` - Response time for external calls

### Business Event Variables
- `businessEvent` - Business event name
- `entityType` - Entity type (Employee, Asset, etc.)
- `entityId` - Entity identifier
- `businessAction` - Business action (CREATE, UPDATE, etc.)

### Security Variables
- `securityEventType` - Security event type
- `securityAction` - Security action
- `resourceAccessed` - Resource that was accessed

### Audit Variables
- `auditAction` - Audit action
- `auditDetails` - Additional audit details
- `userId` - User identifier

## Best Practices

1. **Always log request start/end** for API endpoints
2. **Set appropriate variables** before calling logging flows
3. **Use correlation IDs** for request tracing
4. **Log business events** for audit trails
5. **Monitor performance metrics** regularly
6. **Use appropriate log levels** for different events
7. **Include contextual information** in log messages

## Migration from Existing Services

1. Replace existing log4j2.xml with template version
2. Import global exception handling and logging utilities
3. Add request/response logging to API flows
4. Replace existing logging statements with framework flows
5. Set required variables for logging context

## Troubleshooting

### Common Issues

1. **Missing Variables**: Ensure required variables are set before calling logging flows
2. **Log File Permissions**: Verify write permissions to log directory
3. **Performance Impact**: Monitor for logging performance overhead
4. **Correlation ID Missing**: Ensure correlation ID is properly set

### Debug Mode

Enable debug logging by setting log level to DEBUG in log4j2.xml:
```xml
<AsyncRoot level="DEBUG">
