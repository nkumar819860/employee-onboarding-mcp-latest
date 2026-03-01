# APIKit Router Upgrade Guide for MCP Services

## Overview

This guide provides step-by-step instructions to convert all MCP services from plain HTTP listeners to APIKit router using the existing RAML/OAS API specifications. This will provide:

- Automatic API validation
- Better error handling
- RAML/OAS specification compliance
- Centralized routing based on API specs
- Consistent response formatting

## Services to Upgrade

1. **Employee Onboarding MCP Server**
   - API Spec: `employee-onboarding-mcp-api.yaml`
   - Current: Manual HTTP listeners
   - Target: APIKit router with RAML

2. **Asset Allocation MCP Server**
   - API Spec: `asset-allocation-mcp-api.yaml`
   - Current: Manual HTTP listeners
   - Target: APIKit router with RAML

3. **Notification MCP Server**
   - API Spec: None (needs creation)
   - Current: Manual HTTP listeners
   - Target: APIKit router with RAML

4. **Agent Broker MCP Server**
   - API Spec: None (needs creation)
   - Current: Manual HTTP listeners
   - Target: APIKit router with RAML

## Step-by-Step Conversion Process

### Phase 1: Prepare API Specifications

#### 1.1 Employee Onboarding MCP
✅ **Already has RAML spec**: `employee-onboarding-mcp-api.yaml`

#### 1.2 Asset Allocation MCP
✅ **Already has RAML spec**: `asset-allocation-mcp-api.yaml`

#### 1.3 Notification MCP
❌ **Needs RAML spec creation**

Create `notification-mcp-api.yaml`:
```yaml
#%RAML 1.0
title: Notification MCP Server API
version: v1.0.0
baseUri: https://notification-mcp-server.us-e1.cloudhub.io/api

/health:
  get:
    description: Health check endpoint
    responses:
      200:
        body:
          application/json:
            example: |
              {
                "status": "UP",
                "service": "Notification MCP Server"
              }

/mcp:
  /info:
    get:
      description: MCP server information
      responses:
        200:
          body:
            application/json:
              
  /tools:
    /send-welcome-email:
      post:
        description: Send welcome email notification
        body:
          application/json:
            properties:
              employeeId: string
              firstName: string
              lastName: string
              email: string
        responses:
          200:
            body:
              application/json:
                
    /send-asset-notification:
      post:
        description: Send asset allocation notification
        body:
          application/json:
            properties:
              employeeId: string
              assets: array
        responses:
          200:
            body:
              application/json:
```

#### 1.4 Agent Broker MCP
❌ **Needs RAML spec creation**

### Phase 2: Convert to APIKit Router

#### 2.1 Update Dependencies in pom.xml

Add APIKit dependencies to each MCP server's `pom.xml`:

```xml
<dependency>
    <groupId>org.mule.modules</groupId>
    <artifactId>mule-apikit-module</artifactId>
    <version>1.8.0</version>
    <classifier>mule-plugin</classifier>
</dependency>
```

#### 2.2 Convert Employee Onboarding MCP Server

**Current Structure:**
```xml
<flow name="mcp-create-employee-tool">
    <http:listener path="/mcp/tools/create-employee" config-ref="HTTP_Listener_config"/>
    <!-- Business logic -->
</flow>
```

**Target APIKit Structure:**
```xml
<!-- APIKit Router Configuration -->
<apikit:config name="employee-onboarding-mcp-config" 
               raml="api/employee-onboarding-mcp-api.yaml" 
               outboundHeadersMapName="outboundHeaders" 
               httpStatusVarName="httpStatus" />

<!-- Main APIKit Router Flow -->
<flow name="employee-onboarding-mcp-main">
    <http:listener config-ref="HTTP_Listener_config" path="/api/*"/>
    <apikit:router config-ref="employee-onboarding-mcp-config"/>
    <error-handler>
        <on-error-propagate type="APIKIT:BAD_REQUEST">
            <ee:transform doc:name="Transform Message">
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{message: "Bad request"}]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable variableName="httpStatus">400</ee:set-variable>
                </ee:variables>
            </ee:transform>
        </on-error-propagate>
        <on-error-propagate type="APIKIT:NOT_FOUND">
            <ee:transform doc:name="Transform Message">
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{message: "Resource not found"}]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable variableName="httpStatus">404</ee:set-variable>
                </ee:variables>
            </ee:transform>
        </on-error-propagate>
    </error-handler>
</flow>

<!-- Generated APIKit Flows -->
<flow name="post:\mcp\tools\create-employee:employee-onboarding-mcp-config">
    <flow-ref name="create-employee-with-fallback"/>
</flow>

<flow name="get:\mcp\tools\get-employee\(empId):employee-onboarding-mcp-config">
    <set-variable variableName="empId" value="#[attributes.uriParams.empId]"/>
    <flow-ref name="get-employee-with-fallback"/>
</flow>

<flow name="get:\mcp\tools\list-employees:employee-onboarding-mcp-config">
    <set-variable variableName="page" value="#[attributes.queryParams.page default 1]"/>
    <set-variable variableName="size" value="#[attributes.queryParams.size default 10]"/>
    <set-variable variableName="statusFilter" value="#[attributes.queryParams.status default '']"/>
    <flow-ref name="list-employees-with-fallback"/>
</flow>

<flow name="put:\mcp\tools\update-employee-status\(empId)\(status):employee-onboarding-mcp-config">
    <set-variable variableName="empId" value="#[attributes.uriParams.empId]"/>
    <set-variable variableName="status" value="#[upper(attributes.uriParams.status)]"/>
    <flow-ref name="update-employee-status-with-fallback"/>
</flow>

<flow name="get:\health:employee-onboarding-mcp-config">
    <flow-ref name="health-check-logic"/>
</flow>

<flow name="get:\mcp\info:employee-onboarding-mcp-config">
    <flow-ref name="mcp-server-info-logic"/>
</flow>
```

#### 2.3 Convert Asset Allocation MCP Server

Similar conversion pattern:

```xml
<apikit:config name="asset-allocation-mcp-config" 
               raml="api/asset-allocation-mcp-api.yaml" 
               outboundHeadersMapName="outboundHeaders" 
               httpStatusVarName="httpStatus" />

<flow name="asset-allocation-mcp-main">
    <http:listener config-ref="HTTP_Listener_config" path="/api/*"/>
    <apikit:router config-ref="asset-allocation-mcp-config"/>
    <!-- Error handlers -->
</flow>

<flow name="post:\mcp\tools\allocate-assets:asset-allocation-mcp-config">
    <flow-ref name="allocate-assets-business-logic"/>
</flow>

<flow name="get:\mcp\tools\get-available-assets:asset-allocation-mcp-config">
    <flow-ref name="get-available-assets-logic"/>
</flow>
```

#### 2.4 Convert Notification MCP Server

```xml
<apikit:config name="notification-mcp-config" 
               raml="api/notification-mcp-api.yaml" 
               outboundHeadersMapName="outboundHeaders" 
               httpStatusVarName="httpStatus" />

<flow name="notification-mcp-main">
    <http:listener config-ref="HTTP_Listener_config" path="/api/*"/>
    <apikit:router config-ref="notification-mcp-config"/>
    <!-- Error handlers -->
</flow>

<flow name="post:\mcp\tools\send-welcome-email:notification-mcp-config">
    <flow-ref name="send-welcome-email-logic"/>
</flow>

<flow name="post:\mcp\tools\send-asset-notification:notification-mcp-config">
    <flow-ref name="send-asset-notification-logic"/>
</flow>
```

### Phase 3: Benefits After Conversion

#### 3.1 Automatic Validation
- Request/response validation against RAML specs
- Type checking for parameters
- Required field validation

#### 3.2 Better Error Handling
- Consistent error responses
- HTTP status code management
- APIKIT standard error flows

#### 3.3 Documentation Integration
- API Console automatically generated
- Self-documenting endpoints
- OpenAPI/RAML compliance

#### 3.4 Maintenance Benefits
- Single source of truth (RAML spec)
- Easier API versioning
- Consistent routing logic

### Phase 4: Update Postman Collection

After APIKit conversion, update endpoints in Postman collection:

**Before:**
```
{{EMPLOYEE_SERVICE_URL}}/mcp/tools/create-employee
```

**After:**
```
{{EMPLOYEE_SERVICE_URL}}/api/mcp/tools/create-employee
```

Note the `/api` prefix added by APIKit router.

### Phase 5: Testing Strategy

#### 5.1 Health Checks
- Verify `/api/health` endpoints work
- Check response format consistency

#### 5.2 MCP Tools
- Test all `/api/mcp/tools/*` endpoints
- Validate request/response against RAML

#### 5.3 Error Handling
- Test invalid requests return proper 400 errors
- Test non-existent endpoints return 404
- Verify error response format

### Phase 6: Deployment Considerations

#### 6.1 CloudHub Configuration
- Update CloudHub app paths to include `/api` prefix
- Update health check endpoints in load balancers
- Update firewall rules if needed

#### 6.2 Environment Variables
No changes needed - existing database and configuration logic remains the same.

#### 6.3 Performance Impact
- Slight overhead from APIKit validation
- Better error handling reduces debugging time
- Improved API compliance

## Implementation Priority

1. **High Priority**: Asset Allocation MCP (has binary response issues)
2. **Medium Priority**: Employee Onboarding MCP
3. **Medium Priority**: Notification MCP (fix CloudHub URL first)
4. **Low Priority**: Agent Broker MCP

## Rollback Strategy

Keep current XML files as backups:
- `*-mcp-server.xml.backup`
- Test APIKit version thoroughly before deploying
- Have deployment rollback procedures ready

## Summary

Converting to APIKit router will:
- ✅ Fix binary response issues
- ✅ Provide better API validation
- ✅ Ensure RAML compliance
- ✅ Standardize error handling
- ✅ Improve maintainability
- ✅ Enable auto-generated documentation

This upgrade aligns with MuleSoft best practices and will resolve the current Postman collection issues while future-proofing the MCP services.
