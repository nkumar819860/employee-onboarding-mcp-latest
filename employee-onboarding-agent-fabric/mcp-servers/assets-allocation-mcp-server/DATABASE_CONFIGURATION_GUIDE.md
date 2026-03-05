# Database Configuration Guide
## Conditional Database Selection for Assets Allocation MCP Server

This guide explains the new conditional database configuration approach that automatically selects the appropriate database based on the deployment environment.

## Overview

The system now uses a **classifier approach** where only the appropriate database configuration is loaded based on the environment, preventing both databases from being loaded simultaneously at startup.

## Configuration Strategy

### Database Selection Priority
1. **H2 Database**: Default for CloudHub and local development
2. **PostgreSQL**: Used when explicitly configured for production/Docker environments

### Environment Variable Control
The database selection is controlled by the `db.strategy` property, which accepts the following values:
- `h2` (default) - Uses H2 in-memory database
- `postgres` or `postgresql` - Uses PostgreSQL database

## Configuration Structure

### Global.xml Configuration

The `global.xml` file now contains three database configurations:

#### 1. H2 Database Config (Default)
```xml
<db:config doc:name="H2 Database Config" name="H2_Database_Config">
    <db:generic-connection
        driverClassName="${db.h2.driverClassName}"
        password="${db.h2.password}" 
        url="${db.h2.url}"
        user="${db.h2.username}">
        <db:pooling-profile 
            maxPoolSize="${db.connection.maxPoolSize:10}" 
            minPoolSize="${db.connection.minPoolSize:1}" 
            acquireIncrement="${db.connection.acquireIncrement:1}" 
            preparedStatementCacheSize="${db.connection.cacheSize:10}"/>
    </db:generic-connection>
</db:config>
```

#### 2. PostgreSQL Database Config (Conditional)
```xml
<db:config doc:name="PostgreSQL Database Config" name="PostgreSQL_Database_Config">
    <db:generic-connection
        driverClassName="${db.postgres.driverClassName}"
        password="${db.postgres.password}" 
        url="${db.postgres.url}"
        user="${db.postgres.username}">
        <db:pooling-profile 
            maxPoolSize="${db.postgres.maxPoolSize:10}" 
            minPoolSize="${db.postgres.minPoolSize:2}" 
            acquireIncrement="${db.postgres.acquireIncrement:1}" 
            preparedStatementCacheSize="${db.postgres.cacheSize:15}"/>
    </db:generic-connection>
</db:config>
```

#### 3. Dynamic Database Selector (Recommended)
```xml
<db:config doc:name="Database Config Selector" name="Database_Config">
    <db:generic-connection
        driverClassName="${db.${db.strategy:h2}.driverClassName}"
        password="${db.${db.strategy:h2}.password:}" 
        url="${db.${db.strategy:h2}.url}"
        user="${db.${db.strategy:h2}.username}">
        <db:pooling-profile 
            maxPoolSize="${db.${db.strategy:h2}.maxPoolSize:10}" 
            minPoolSize="${db.${db.strategy:h2}.minPoolSize:1}" 
            acquireIncrement="${db.${db.strategy:h2}.acquireIncrement:1}" 
            preparedStatementCacheSize="${db.${db.strategy:h2}.cacheSize:10}"/>
    </db:generic-connection>
</db:config>
```

### Properties Configuration

#### Database Strategy Control
```properties
# Database Configuration Strategy
# Controls which database configuration to use
# Values: h2 (default), postgres, postgresql
db.strategy=${DB_STRATEGY:h2}
```

#### H2 Configuration (Default)
```properties
# H2 Database Configuration (Default for CloudHub and Local Development)
db.h2.url=${DB_H2_URL:jdbc:h2:mem:assets_allocation;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;INIT=CREATE SCHEMA IF NOT EXISTS ASSETS_ALLOCATION}
db.h2.username=${DB_H2_USERNAME:sa}
db.h2.password=${DB_H2_PASSWORD:}
db.h2.driverClassName=org.h2.Driver
db.h2.maxPoolSize=${DB_H2_MAX_POOL_SIZE:10}
db.h2.minPoolSize=${DB_H2_MIN_POOL_SIZE:1}
db.h2.acquireIncrement=${DB_H2_ACQUIRE_INCREMENT:1}
db.h2.cacheSize=${DB_H2_CACHE_SIZE:10}
```

#### PostgreSQL Configuration (Production)
```properties
# PostgreSQL Database Configuration (for Production/Docker environments)
db.postgres.host=${DB_POSTGRES_HOST:localhost}
db.postgres.port=${DB_POSTGRES_PORT:5432}
db.postgres.name=${DB_POSTGRES_NAME:assets_allocation}
db.postgres.username=${DB_POSTGRES_USERNAME:postgres}
db.postgres.password=${DB_POSTGRES_PASSWORD:password}
db.postgres.url=${DB_POSTGRES_URL:jdbc:postgresql://${db.postgres.host}:${db.postgres.port}/${db.postgres.name}}
db.postgres.driverClassName=org.postgresql.Driver
db.postgres.maxPoolSize=${DB_POSTGRES_MAX_POOL_SIZE:15}
db.postgres.minPoolSize=${DB_POSTGRES_MIN_POOL_SIZE:2}
db.postgres.acquireIncrement=${DB_POSTGRES_ACQUIRE_INCREMENT:2}
db.postgres.cacheSize=${DB_POSTGRES_CACHE_SIZE:20}
```

## Usage Scenarios

### Scenario 1: CloudHub Deployment (Default)
- **Environment**: CloudHub
- **Database**: H2 (In-memory)
- **Configuration**: No additional environment variables needed
- **Behavior**: Uses H2 database with default settings

```bash
# No environment variables required - uses defaults
# db.strategy defaults to "h2"
```

### Scenario 2: Local Development
- **Environment**: Local machine
- **Database**: H2 (In-memory)
- **Configuration**: Default behavior
- **Behavior**: Uses H2 database for rapid development

```bash
# Optional: Explicitly set H2
export DB_STRATEGY=h2
```

### Scenario 3: Docker Environment with PostgreSQL
- **Environment**: Docker containers
- **Database**: PostgreSQL
- **Configuration**: Set environment variables for PostgreSQL

```bash
# Docker environment variables
export DB_STRATEGY=postgres
export DB_POSTGRES_HOST=postgres-db
export DB_POSTGRES_PORT=5432
export DB_POSTGRES_NAME=assets_allocation
export DB_POSTGRES_USERNAME=app_user
export DB_POSTGRES_PASSWORD=secure_password
```

### Scenario 4: Production Environment
- **Environment**: Production server with external PostgreSQL
- **Database**: PostgreSQL
- **Configuration**: Production-grade PostgreSQL settings

```bash
# Production environment variables
export DB_STRATEGY=postgresql
export DB_POSTGRES_HOST=prod-db.company.com
export DB_POSTGRES_PORT=5432
export DB_POSTGRES_NAME=assets_allocation_prod
export DB_POSTGRES_USERNAME=prod_user
export DB_POSTGRES_PASSWORD=${SECURE_DB_PASSWORD}
export DB_POSTGRES_MAX_POOL_SIZE=20
export DB_POSTGRES_MIN_POOL_SIZE=5
```

## Environment Variable Reference

### Core Database Strategy
| Variable | Default | Description |
|----------|---------|-------------|
| `DB_STRATEGY` | `h2` | Database type selection (`h2`, `postgres`, `postgresql`) |

### H2 Database Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `DB_H2_URL` | `jdbc:h2:mem:assets_allocation;...` | H2 connection URL |
| `DB_H2_USERNAME` | `sa` | H2 username |
| `DB_H2_PASSWORD` | ` ` (empty) | H2 password |
| `DB_H2_MAX_POOL_SIZE` | `10` | Maximum connection pool size |
| `DB_H2_MIN_POOL_SIZE` | `1` | Minimum connection pool size |

### PostgreSQL Database Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `DB_POSTGRES_HOST` | `localhost` | PostgreSQL server host |
| `DB_POSTGRES_PORT` | `5432` | PostgreSQL server port |
| `DB_POSTGRES_NAME` | `assets_allocation` | Database name |
| `DB_POSTGRES_USERNAME` | `postgres` | PostgreSQL username |
| `DB_POSTGRES_PASSWORD` | `password` | PostgreSQL password |
| `DB_POSTGRES_MAX_POOL_SIZE` | `15` | Maximum connection pool size |
| `DB_POSTGRES_MIN_POOL_SIZE` | `2` | Minimum connection pool size |

## Benefits of This Approach

### 1. **Environment-Based Selection**
- Automatically selects the appropriate database based on deployment context
- No manual configuration changes needed between environments

### 2. **Resource Optimization**
- Only the selected database configuration is loaded
- Prevents unnecessary connection attempts to unavailable databases

### 3. **Simplified Deployment**
- Single codebase works across all environments
- Environment-specific behavior controlled via environment variables

### 4. **Backward Compatibility**
- Maintains compatibility with existing deployments
- Graceful fallback to H2 if no strategy is specified

### 5. **Enhanced Security**
- Database credentials can be injected via environment variables
- No hardcoded credentials in configuration files

## Database Reference Usage

### In Flows - Use Dynamic Selector (Recommended)
```xml
<db:select config-ref="Database_Config">
    <db:sql>SELECT * FROM assets WHERE employee_id = :employeeId</db:sql>
    <db:input-parameters>
        <db:input-parameter key="employeeId" value="#[payload.employeeId]"/>
    </db:input-parameters>
</db:select>
```

### In Flows - Use Specific Database
```xml
<!-- For H2 specific operations -->
<db:select config-ref="H2_Database_Config">
    <!-- H2 specific SQL -->
</db:select>

<!-- For PostgreSQL specific operations -->
<db:select config-ref="PostgreSQL_Database_Config">
    <!-- PostgreSQL specific SQL -->
</db:select>
```

## Testing the Configuration

### Test H2 Configuration
```bash
# Test with H2 (default)
curl -X GET http://localhost:8083/api/assets/health
```

### Test PostgreSQL Configuration
```bash
# Set PostgreSQL strategy
export DB_STRATEGY=postgres

# Start application and test
curl -X GET http://localhost:8083/api/assets/health
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed
- **Cause**: Incorrect database strategy or connection parameters
- **Solution**: Verify environment variables and database availability

#### 2. Both Databases Attempting Connection
- **Cause**: Legacy configuration or incorrect property resolution
- **Solution**: Ensure `db.strategy` is properly set and referenced

#### 3. Property Resolution Errors
- **Cause**: Missing default values or malformed property expressions
- **Solution**: Check property syntax and ensure fallback values exist

### Debugging Steps

1. **Check Active Strategy**
   ```bash
   echo $DB_STRATEGY
   ```

2. **Verify Database Availability**
   ```bash
   # For PostgreSQL
   pg_isready -h $DB_POSTGRES_HOST -p $DB_POSTGRES_PORT
   
   # For H2 (check application logs)
   tail -f logs/application.log
   ```

3. **Test Configuration Loading**
   ```bash
   # Check if properties are resolved correctly
   curl -X GET http://localhost:8083/api/assets/config/database
   ```

## Migration from Legacy Configuration

### Step 1: Update Global.xml
Replace the old database configurations with the new conditional setup as shown above.

### Step 2: Update Properties
Add the new database strategy properties and environment variable support.

### Step 3: Update Flow References
Change database config references to use `Database_Config` for automatic selection.

### Step 4: Test All Environments
Verify functionality across CloudHub, local development, and Docker environments.

## Best Practices

1. **Use Dynamic Selector**: Always use `Database_Config` in flows for automatic database selection
2. **Environment Variables**: Use environment variables for sensitive configuration
3. **Connection Pooling**: Configure appropriate pool sizes based on environment load
4. **Health Checks**: Implement database health check endpoints
5. **Monitoring**: Add database connection monitoring and alerting
6. **Documentation**: Keep environment-specific configuration documented

## Conclusion

This conditional database configuration approach provides a robust, environment-aware solution that automatically selects the appropriate database without loading unnecessary configurations. It enhances security, performance, and maintainability while supporting all deployment scenarios from local development to production.
