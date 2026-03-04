# Employee Onboarding MCP Server

## Overview

The Employee Onboarding MCP Server is a specialized Model Context Protocol (MCP) server designed for comprehensive employee profile management and database operations. It serves as the foundational data layer for the employee onboarding ecosystem, providing robust CRUD operations with multi-database support.

## Features

### 🗄️ Multi-Database Support
- **Primary**: PostgreSQL for production environments
- **Fallback**: H2 in-memory database for development and testing
- **Automatic Failover**: Seamless switching between database systems
- **Connection Pooling**: Optimized database connection management

### 🔧 MCP Tools
1. **create-employee**: Create new employee profiles with comprehensive data validation
2. **get-employee**: Retrieve employee information by ID or email
3. **update-employee**: Update existing employee profiles with partial updates support
4. **delete-employee**: Remove employee records (with safety checks)
5. **list-employees**: Query employees with filtering and pagination
6. **check-employee-exists**: Validate employee existence without full data retrieval

### 📊 Database Schema
```sql
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100),
    position VARCHAR(100),
    start_date DATE,
    salary DECIMAL(12,2),
    manager VARCHAR(100),
    manager_email VARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 🔍 Advanced Query Capabilities
- Filter by department, position, status
- Date range queries for start dates
- Full-text search across name and email fields
- Pagination support for large datasets
- Sorting by multiple fields

## Quick Start

### Prerequisites
- Java 17+
- Mule Runtime 4.9.6+
- PostgreSQL 12+ (recommended) or H2 (development)

### Installation

1. **Clone and navigate to the project:**
   ```bash
   cd employee-onboarding-mcp
   ```

2. **Install dependencies:**
   ```bash
   mvn clean install
   ```

3. **Configure database connection:**
   ```bash
   # PostgreSQL (production)
   export DB_HOST="localhost"
   export DB_PORT="5432"
   export DB_NAME="employee_onboarding"
   export DB_USER="your_username"
   export DB_PASSWORD="your_password"
   
   # Or use H2 (development - no configuration needed)
   export USE_H2_DATABASE="true"
   ```

4. **Run the application:**
   ```bash
   mvn mule:run
   ```

The server will start on port **8081**.

## API Endpoints

### Health Check
```
GET http://localhost:8081/health
```

### MCP Server Information
```
GET http://localhost:8081/mcp/info
```

### Employee Management

#### Create Employee
```
POST http://localhost:8081/mcp/tools/create-employee

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@company.com",
  "phone": "+1-555-0123",
  "department": "Engineering",
  "position": "Software Developer",
  "startDate": "2024-03-01",
  "salary": 75000.00,
  "manager": "Jane Smith",
  "managerEmail": "jane.smith@company.com"
}
```

#### Get Employee
```
POST http://localhost:8081/mcp/tools/get-employee

{
  "employeeId": "EMP001"
}
```
or
```
POST http://localhost:8081/mcp/tools/get-employee

{
  "email": "john.doe@company.com"
}
```

#### Update Employee
```
POST http://localhost:8081/mcp/tools/update-employee

{
  "employeeId": "EMP001",
  "department": "Senior Engineering",
  "salary": 85000.00
}
```

#### List Employees
```
POST http://localhost:8081/mcp/tools/list-employees

{
  "department": "Engineering",
  "status": "ACTIVE",
  "page": 1,
  "pageSize": 10,
  "sortBy": "lastName",
  "sortOrder": "ASC"
}
```

#### Delete Employee
```
POST http://localhost:8081/mcp/tools/delete-employee

{
  "employeeId": "EMP001"
}
```

## Database Configuration

### PostgreSQL Setup
```sql
-- Create database
CREATE DATABASE employee_onboarding;

-- Create user
CREATE USER mcp_user WITH PASSWORD 'secure_password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO mcp_user;

-- Connect to the database and create tables
\c employee_onboarding;

-- The application will automatically create tables on startup
```

### H2 Database (Development)
The H2 database is automatically configured and requires no setup. It creates an in-memory database with the schema initialized on startup.

## Configuration

### Environment Variables
```properties
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=employee_onboarding
DB_USER=mcp_user
DB_PASSWORD=secure_password
DB_MAX_CONNECTIONS=10

# H2 Database (Alternative)
USE_H2_DATABASE=false
H2_DB_PATH=./data/employee_onboarding

# HTTP Server
HTTP_PORT=8081
HTTP_HOST=0.0.0.0

# Application Settings
MCP_SERVER_NAME=Employee Onboarding MCP Server
LOG_LEVEL=INFO
ENABLE_METRICS=true
```

### Mule Configuration Properties
```properties
# src/main/resources/config.properties
http.port=8081
http.host=0.0.0.0

# Database
db.host=${DB_HOST}
db.port=${DB_PORT}
db.name=${DB_NAME}
db.user=${DB_USER}
db.password=${DB_PASSWORD}

# H2 Fallback
h2.enabled=${USE_H2_DATABASE}
h2.path=${H2_DB_PATH}
```

## Error Handling

### Database Connection Failures
- Automatic retry with exponential backoff
- Graceful failover from PostgreSQL to H2
- Connection pool monitoring and recovery

### Data Validation
- Email format validation
- Phone number format checking
- Required field validation
- Unique constraint enforcement

### Error Response Format
```json
{
  "status": "error",
  "message": "Employee creation failed",
  "error": "Email address already exists: john.doe@company.com",
  "errorCode": "DUPLICATE_EMAIL",
  "timestamp": "2024-02-21T23:45:15Z"
}
```

## Success Response Format
```json
{
  "status": "success",
  "message": "Employee created successfully",
  "employeeId": "EMP001",
  "data": {
    "id": 1,
    "employeeId": "EMP001",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "department": "Engineering",
    "position": "Software Developer",
    "status": "ACTIVE",
    "createdAt": "2024-02-21T23:45:15Z",
    "updatedAt": "2024-02-21T23:45:15Z"
  },
  "timestamp": "2024-02-21T23:45:15Z"
}
```

## Performance Optimization

### Database Indexing
```sql
-- Indexes for optimal query performance
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_employee_id ON employees(employee_id);
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_start_date ON employees(start_date);
```

### Connection Pooling
- Default pool size: 10 connections
- Connection validation on borrow
- Automatic cleanup of stale connections
- Monitoring and alerting on pool exhaustion

### Caching Strategy
- Employee data caching for frequently accessed records
- Cache invalidation on updates and deletes
- Configurable TTL (Time To Live) settings

## Security Features

### Data Protection
- Input sanitization to prevent SQL injection
- Encrypted sensitive data storage
- Audit logging for all data modifications
- Role-based access control (future enhancement)

### API Security
- Request rate limiting
- Input validation and sanitization
- Error message sanitization to prevent information leakage

## Monitoring and Observability

### Health Checks
- Database connectivity monitoring
- Connection pool health
- Memory usage tracking
- Response time monitoring

### Metrics Collection
- Request counts and response times
- Database query performance
- Error rates and types
- Resource utilization

### Logging
- Structured JSON logging
- Correlation ID tracking
- Configurable log levels
- Integration with log aggregation systems

## Development

### Project Structure
```
employee-onboarding-mcp/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── global.xml                    # Global configurations
│   │   │   └── employee-onboarding-mcp-server.xml # Main flows
│   │   └── resources/
│   │       ├── api/
│   │       │   └── employee-onboarding-mcp-api.yaml # API specification
│   │       ├── config.properties             # Configuration
│   │       ├── init-h2.sql                  # H2 schema initialization
│   │       └── init.sql                     # PostgreSQL schema
│   └── test/
├── exchange.json                             # Exchange metadata
├── mule-artifact.json                       # Mule artifact configuration
├── pom.xml                                  # Maven configuration
└── README.md                                # This file
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

## Integration Examples

### With Agent Broker
The Employee Onboarding MCP Server integrates seamlessly with the Agent Broker for complete onboarding orchestration:

```javascript
// Agent Broker calls Employee MCP
const employeeResult = await mcpClient.call('create-employee', {
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@company.com',
  department: 'Engineering'
});

if (employeeResult.status === 'success') {
  // Proceed with asset allocation and notifications
  console.log('Employee created:', employeeResult.employeeId);
}
```

### With Asset Allocation MCP
```javascript
// Query employee for asset allocation
const employee = await employeeMCP.call('get-employee', {
  employeeId: 'EMP001'
});

// Use employee data for asset allocation
const assetAllocation = await assetMCP.call('allocate-assets', {
  employeeId: employee.data.employeeId,
  department: employee.data.department,
  position: employee.data.position
});
```

## Troubleshooting

### Common Issues

#### Database Connection Failed
```bash
# Check database connectivity
telnet localhost 5432

# Verify credentials
psql -h localhost -U mcp_user -d employee_onboarding
```

#### H2 Database Issues
```bash
# Clear H2 database files
rm -rf ./data/employee_onboarding.*

# Restart application to recreate
mvn mule:run
```

#### Port Already in Use
```bash
# Find process using port 8081
netstat -tulpn | grep 8081

# Kill process if needed
kill -9 <PID>
```

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
