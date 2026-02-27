# Asset Allocation MCP Server

## Overview

The Asset Allocation MCP (Model Context Protocol) Server is an intelligent IT asset management system designed specifically for employee onboarding workflows. It provides automated allocation, tracking, and management of company assets such as laptops, ID cards, mobile devices, and other IT equipment.

## Key Features

- **🤖 Automated Asset Allocation**: Intelligently allocates available assets to new employees during onboarding
- **📊 Real-time Asset Tracking**: Monitors asset availability and allocation status in real-time
- **🔄 Multi-Database Support**: Supports PostgreSQL (production), H2 (development), and mock mode with intelligent fallback
- **⚡ High Availability**: Built-in fallback strategies ensure service continuity
- **🏥 Health Monitoring**: Comprehensive health checks and status reporting
- **🔧 RESTful API**: Clean, well-documented REST API for easy integration
- **🔍 MCP Protocol**: Implements Model Context Protocol for agent-based interactions

## API Specification

This service exposes a RAML-based API specification that can be published to Anypoint Exchange. The API includes:

- **Health Check Endpoint**: `/health` - Service status monitoring
- **MCP Info Endpoint**: `/mcp/info` - Server capabilities and tool definitions
- **Asset Management Tools**:
  - Allocate assets to employees
  - Return allocated assets
  - List all assets with filtering
  - Get available assets
  - Retrieve employee-specific asset allocations

## Database Strategy Configuration

The service supports multiple database strategies via the `db.strategy` property:

### For Local Development (Recommended)
```properties
db.strategy=h2
env=development
```

### For Production Deployment
```properties
db.strategy=postgresql
env=production
```

### For Flexible Environments
```properties
db.strategy=auto
env=sandbox
```

## Quick Start

### 1. Local Development Setup
1. Import the project into Anypoint Studio
2. Ensure `db.strategy=h2` in `config.properties`
3. Run the application (`Run As` → `Mule Application`)
4. Test health endpoint: `GET http://localhost:8082/health`

### 2. Asset Allocation Example
```bash
curl -X POST http://localhost:8082/mcp/tools/allocate-assets \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "EMP001",
    "firstName": "John",
    "lastName": "Doe",
    "assets": ["laptop", "id-card"]
  }'
```

### 3. List Available Assets
```bash
curl http://localhost:8082/mcp/tools/get-available-assets
```

## Configuration

### Database Settings
```properties
# H2 In-Memory Database (Development)
db.h2.url=jdbc:h2:mem:asset_allocation;DB_CLOSE_DELAY=-1
db.h2.username=sa
db.h2.password=

# PostgreSQL Database (Production)
db.postgres.url=jdbc:postgresql://postgres:5432/asset_allocation
db.postgres.username=postgres
db.postgres.password=postgres_pass
```

### Server Settings
```properties
http.host=0.0.0.0
http.port=8082
```

### Asset Business Rules
```properties
asset.allocation.default.laptop=true
asset.allocation.default.id_card=true
asset.allocation.approval.required=false
asset.allocation.max.per.employee=5
```

## Deployment

### CloudHub Deployment
1. Configure connected app credentials in `.env`
2. Update database connection for cloud environment
3. Deploy using: `mvn clean package deploy -DmuleDeploy`

### Exchange Publication
This asset can be published to Anypoint Exchange as a reusable MCP component:

```bash
# Publish to Exchange
mvn clean deploy -DaltDeploymentRepository=anypoint-exchange::default::https://maven.anypoint.mulesoft.com/api/v2/organizations/{orgId}/maven
```

## Architecture

### Component Overview
```
┌─────────────────────────────────────────┐
│           Asset Allocation              │
│              MCP Server                 │
├─────────────────────────────────────────┤
│  HTTP Listener (Port 8082)             │
│  ├── Health Check (/health)            │
│  ├── MCP Info (/mcp/info)              │
│  └── Asset Tools (/mcp/tools/*)        │
├─────────────────────────────────────────┤
│         Business Logic Layer           │
│  ├── Asset Allocation Engine           │
│  ├── Database Fallback Handler         │
│  └── Mock Response Generator           │
├─────────────────────────────────────────┤
│          Data Access Layer             │
│  ├── PostgreSQL Connector              │
│  ├── H2 Database Connector             │
│  └── Connection Pool Management        │
├─────────────────────────────────────────┤
│            Database Layer              │
│  ├── PostgreSQL (Production)           │
│  ├── H2 In-Memory (Development)        │
│  └── Mock Data (Fallback)              │
└─────────────────────────────────────────┘
```

### Database Schema
```sql
-- Asset Categories
CREATE TABLE asset_categories (
    id INT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

-- Assets
CREATE TABLE assets (
    id INT PRIMARY KEY,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES asset_categories(id),
    brand VARCHAR(50),
    model VARCHAR(50),
    serial_number VARCHAR(100),
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    condition_status VARCHAR(20) DEFAULT 'GOOD',
    purchase_date DATE,
    specifications JSONB
);

-- Asset Allocations
CREATE TABLE asset_allocations (
    id INT PRIMARY KEY,
    asset_id INT REFERENCES assets(id),
    employee_id INT NOT NULL,
    allocated_date DATE NOT NULL,
    expected_return_date DATE,
    actual_return_date DATE,
    allocation_status VARCHAR(20) DEFAULT 'ALLOCATED',
    allocation_reason TEXT,
    return_condition VARCHAR(20),
    notes TEXT
);
```

## Error Handling & Resilience

### Database Fallback Strategy
1. **Primary**: Try configured database (PostgreSQL/H2)
2. **Secondary**: Fall back to alternative database
3. **Tertiary**: Use mock responses for service continuity

### Health Monitoring
- **Database Health**: Connection status and query performance
- **Application Health**: Memory usage and service uptime
- **Configuration Health**: Property validation and feature flags

## Testing

### Unit Tests
```bash
mvn test
```

### Integration Tests
```bash
mvn verify -Pintegration-tests
```

### Health Check Validation
```bash
curl http://localhost:8082/health
```

Expected healthy response:
```json
{
  "status": "HEALTHY",
  "service": "Asset Allocation MCP Server",
  "version": "1.0.2",
  "checks": [
    {
      "name": "database",
      "healthy": true,
      "details": {
        "type": "H2",
        "assetCount": 10,
        "connection": "active"
      }
    }
  ]
}
```

## Troubleshooting

### Common Issues

#### 1. Database Script Execution Error
**Error**: "One of the following fields must be set [file], [sql]"
**Solution**: Ensure proper `db:execute-script` syntax in Mule flows

#### 2. Port Already in Use
**Error**: "Address already in use: 8082"
**Solution**: Change port in config.properties or kill process using the port

#### 3. Database Connection Failed
**Error**: "Connection refused to database"
**Solution**: 
- For H2: Ensure `db.strategy=h2` 
- For PostgreSQL: Verify database server is running and credentials are correct

### Debugging
Enable debug logging:
```xml
<Logger name="org.mule.extension.db" level="DEBUG"/>
<Logger name="com.mulesoft.mule.runtime.plugin.db" level="DEBUG"/>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the project repository
- Contact the development team via email
- Check the troubleshooting section above

## Version History

- **v1.0.2**: Fixed database script execution issues, added comprehensive API documentation
- **v1.0.1**: Added multi-database support with intelligent fallback
- **v1.0.0**: Initial release with basic asset allocation functionality
