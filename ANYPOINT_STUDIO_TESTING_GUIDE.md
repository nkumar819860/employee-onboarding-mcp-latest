# Testing Database Script Execution Fix in Anypoint Studio

## Issue Fixed
Fixed the "One of the following fields must be set [file], [sql] (all of them are empty) at execute script" error in the Asset Allocation MCP Server.

## Changes Made
1. **Fixed `db:execute-script` syntax** in `asset-allocation-mcp-server.xml`
   - Changed from: `<db:execute-script config-ref="H2_Database_Config"><db:sql file="init-h2.sql" /></db:execute-script>`
   - Changed to: `<db:execute-script config-ref="H2_Database_Config" file="init-h2.sql" />`

2. **Improved database initialization logic** to handle script execution properly

## Testing in Anypoint Studio

### Prerequisites
1. **Anypoint Studio** installed (latest version)
2. **H2 Database Connector** added to your project dependencies
3. **Database config files** in the correct location

### Step 1: Import Project into Anypoint Studio

1. Open Anypoint Studio
2. Go to `File` → `Import` → `Anypoint Studio` → `Anypoint Studio project from File System`
3. Select the `employee-onboarding-agent-fabric/mcp-servers/asset-allocation-mcp` folder
4. Click `Finish`

### Step 2: Verify Database Configuration

Check that your `global.xml` contains the H2 database configuration:

```xml
<db:config name="H2_Database_Config">
    <db:generic-connection 
        driverClassName="org.h2.Driver"
        url="jdbc:h2:mem:assetdb;DB_CLOSE_DELAY=-1;DATABASE_TO_UPPER=FALSE"
        user="sa"
        password=""/>
</db:config>
```

### Step 3: Test Database Initialization

1. **Run the Application**
   - Right-click on the project in Package Explorer
   - Select `Run As` → `Mule Application`

2. **Monitor Console Output**
   Look for these key log messages:
   ```
   INFO  - Starting intelligent database initialization - Strategy: h2
   INFO  - Initializing H2 database...
   INFO  - H2 connection successful
   INFO  - H2 tables created successfully
   INFO  - Database initialization completed successfully with: h2
   ```

3. **Check for Errors**
   - If the fix worked, you should NOT see the error: "One of the following fields must be set [file], [sql]"
   - Database initialization should complete without errors

### Step 4: Test Database Operations

1. **Test Health Check Endpoint**
   - Open browser or Postman
   - GET: `http://localhost:8081/health`
   - Should return status "HEALTHY" with database details

2. **Test Asset Allocation**
   - POST: `http://localhost:8081/mcp/tools/allocate-assets`
   - Body (JSON):
   ```json
   {
     "employeeId": "EMP001",
     "firstName": "John",
     "lastName": "Doe",
     "assets": ["laptop", "id-card"]
   }
   ```

3. **Test List Assets**
   - GET: `http://localhost:8081/mcp/tools/list-assets`
   - Should return available assets

### Step 5: Verify Database Tables Created

1. **Add H2 Console** (Optional for debugging)
   Add to your `global.xml`:
   ```xml
   <http:listener-config name="H2_Console_Config">
       <http:listener-connection host="0.0.0.0" port="8082"/>
   </http:listener-config>
   ```

2. **Access H2 Console**
   - URL: `http://localhost:8082/h2-console`
   - JDBC URL: `jdbc:h2:mem:assetdb`
   - User: `sa`, Password: (empty)

3. **Verify Tables**
   Run SQL queries:
   ```sql
   SHOW TABLES;
   SELECT * FROM assets;
   SELECT * FROM asset_categories;
   SELECT * FROM employees;
   ```

## Expected Results After Fix

### ✅ Success Indicators
1. **Application starts without database script errors**
2. **H2 tables are created successfully**
3. **Health check returns database status as "UP"**
4. **Asset allocation operations work correctly**
5. **Database fallback strategies function properly**

### ❌ If Still Failing
1. **Check file paths** - Ensure `init-h2.sql` exists in `src/main/resources/`
2. **Verify syntax** - Make sure `db:execute-script` has `file` attribute, not nested `<db:sql file="">`
3. **Database permissions** - Ensure H2 can create in-memory database
4. **Connector version** - Check if H2 database connector is compatible

## Configuration Properties

Ensure your `config.properties` has:
```properties
# Database Configuration
db.strategy=h2
db.initialization.enabled=true

# MCP Server Configuration
mcp.server.name=Asset Allocation MCP Server
mcp.server.version=1.0.2
mcp.features.mock.enabled=false
```

## Debugging Tips

### Enable Debug Logging
Add to your `log4j2.xml`:
```xml
<Logger name="org.mule.extension.db" level="DEBUG"/>
<Logger name="com.mulesoft.mule.runtime.plugin.db" level="DEBUG"/>
```

### Console Commands for Testing
```bash
# Test health endpoint
curl http://localhost:8081/health

# Test asset allocation
curl -X POST http://localhost:8081/mcp/tools/allocate-assets \
  -H "Content-Type: application/json" \
  -d '{"employeeId":"EMP001","firstName":"John","lastName":"Doe"}'

# Test list assets
curl http://localhost:8081/mcp/tools/list-assets
```

## Troubleshooting Common Issues

### Issue 1: ClassPath Problems
- **Solution**: Right-click project → `Mule` → `Update Project Dependencies`

### Issue 2: H2 Driver Not Found
- **Solution**: Add H2 dependency to `pom.xml`:
```xml
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <version>2.1.214</version>
</dependency>
```

### Issue 3: Port Already in Use
- **Solution**: Change port in HTTP Listener config or kill process using the port

### Issue 4: Database Lock Issues
- **Solution**: Restart Anypoint Studio and clear workspace cache

## Testing Other MCP Services

Apply the same testing approach to:
1. **Employee Onboarding MCP** (`employee-onboarding-mcp`)
2. **Notification MCP** (`notification-mcp`)
3. **Agent Broker MCP** (`agent-broker-mcp`)

Each service should start without database script execution errors and properly initialize their respective databases.
