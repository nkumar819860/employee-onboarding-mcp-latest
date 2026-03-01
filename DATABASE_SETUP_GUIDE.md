# Database Setup Guide for MCP Employee Onboarding System

This guide provides comprehensive instructions for setting up H2 and PostgreSQL databases for the Employee Onboarding MCP system, both locally and using Docker.

## Table of Contents
- [H2 Database Setup](#h2-database-setup)
- [PostgreSQL Setup](#postgresql-setup)
- [Docker Setup](#docker-setup)
- [Configuration](#configuration)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## H2 Database Setup

H2 is an embedded database that requires minimal setup and is perfect for development and testing.

### Local H2 Setup

#### Prerequisites
- Java 8 or higher
- H2 Database Engine (comes with most Java distributions)

#### Option 1: Embedded Mode (Recommended for Development)
```properties
# In config.properties
db.strategy=h2
db.host=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
db.port=
db.name=testdb
db.user=sa
db.password=
db.initialization.enabled=true
```

#### Option 2: Server Mode
1. **Download H2 Database**:
   ```bash
   # Download H2 (if not included with Java)
   wget https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar
   ```

2. **Start H2 Server**:
   ```bash
   # Windows
   java -cp h2-2.2.224.jar org.h2.tools.Server -web -tcp -pg

   # Linux/Mac
   java -cp h2-2.2.224.jar org.h2.tools.Server -web -tcp -pg
   ```

3. **Configuration**:
   ```properties
   # In config.properties
   db.strategy=h2
   db.host=jdbc:h2:tcp://localhost:9092/~/testdb
   db.port=9092
   db.name=testdb
   db.user=sa
   db.password=
   db.initialization.enabled=true
   ```

#### H2 Web Console Access
- URL: `http://localhost:8082`
- JDBC URL: `jdbc:h2:mem:testdb` (for embedded) or `jdbc:h2:tcp://localhost:9092/~/testdb`
- Username: `sa`
- Password: (leave empty)

---

## PostgreSQL Setup

### Local PostgreSQL Setup

#### Windows Installation
1. **Download PostgreSQL**:
   - Visit: https://www.postgresql.org/download/windows/
   - Download and run the installer

2. **Installation Steps**:
   ```cmd
   # Run the installer and set:
   # - Username: postgres
   # - Password: (choose a secure password)
   # - Port: 5432
   # - Locale: Default
   ```

3. **Create Database**:
   ```sql
   # Connect to PostgreSQL
   psql -U postgres -h localhost

   # Create database and user
   CREATE DATABASE employee_onboarding;
   CREATE USER mcp_user WITH PASSWORD 'mcp_password';
   GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO mcp_user;
   ```

#### Linux Installation (Ubuntu/Debian)
```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql
CREATE DATABASE employee_onboarding;
CREATE USER mcp_user WITH PASSWORD 'mcp_password';
GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO mcp_user;
\q
```

#### macOS Installation
```bash
# Using Homebrew
brew install postgresql

# Start PostgreSQL
brew services start postgresql

# Create database
createdb employee_onboarding

# Connect and create user
psql employee_onboarding
CREATE USER mcp_user WITH PASSWORD 'mcp_password';
GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO mcp_user;
\q
```

#### PostgreSQL Configuration
```properties
# In config.properties
db.strategy=postgresql
db.host=localhost
db.port=5432
db.name=employee_onboarding
db.user=mcp_user
db.password=mcp_password
db.initialization.enabled=true
```

---

## Docker Setup

### Docker Compose Setup (Recommended)

Create `docker-compose-databases.yml`:

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: mcp-postgres
    environment:
      POSTGRES_DB: employee_onboarding
      POSTGRES_USER: mcp_user
      POSTGRES_PASSWORD: mcp_password
      PGDATA: /var/lib/postgresql/data/pgdata
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init-databases.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - mcp-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mcp_user -d employee_onboarding"]
      interval: 30s
      timeout: 10s
      retries: 5

  # H2 Database (for testing)
  h2:
    image: oscarfonts/h2:latest
    container_name: mcp-h2
    ports:
      - "8082:8082"  # Web console
      - "9092:9092"  # TCP server
    environment:
      H2_OPTIONS: -web -webAllowOthers -tcp -tcpAllowOthers -baseDir /opt/h2-data
    volumes:
      - h2_data:/opt/h2-data
    networks:
      - mcp-network

  # pgAdmin (PostgreSQL Web Interface)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: mcp-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@mcp.local
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "8083:80"
    depends_on:
      - postgres
    networks:
      - mcp-network

volumes:
  postgres_data:
  h2_data:

networks:
  mcp-network:
    driver: bridge
```

### Docker Setup Commands

```bash
# Start all database services
docker-compose -f docker-compose-databases.yml up -d

# Start only PostgreSQL
docker-compose -f docker-compose-databases.yml up -d postgres

# Start only H2
docker-compose -f docker-compose-databases.yml up -d h2

# Check service status
docker-compose -f docker-compose-databases.yml ps

# View logs
docker-compose -f docker-compose-databases.yml logs postgres
docker-compose -f docker-compose-databases.yml logs h2

# Stop services
docker-compose -f docker-compose-databases.yml down

# Stop and remove volumes (WARNING: This deletes data)
docker-compose -f docker-compose-databases.yml down -v
```

### Individual Docker Commands

#### PostgreSQL Docker Setup
```bash
# Run PostgreSQL container
docker run -d \
  --name mcp-postgres \
  -e POSTGRES_DB=employee_onboarding \
  -e POSTGRES_USER=mcp_user \
  -e POSTGRES_PASSWORD=mcp_password \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

# Connect to PostgreSQL
docker exec -it mcp-postgres psql -U mcp_user -d employee_onboarding
```

#### H2 Docker Setup
```bash
# Run H2 container
docker run -d \
  --name mcp-h2 \
  -p 8082:8082 \
  -p 9092:9092 \
  -v h2_data:/opt/h2-data \
  oscarfonts/h2

# Access H2 web console: http://localhost:8082
```

---

## Configuration

### MCP Server Configuration Files

Update the following configuration files based on your database choice:

#### Asset Allocation MCP (`mcp-servers/asset-allocation-mcp/src/main/resources/config.properties`)
```properties
# Database Strategy (h2 or postgresql)
db.strategy=h2

# H2 Configuration
# For embedded H2
db.host=jdbc:h2:mem:assetdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
# For H2 server mode
# db.host=jdbc:h2:tcp://localhost:9092/~/assetdb

# PostgreSQL Configuration
# db.host=localhost
# db.port=5432
# db.name=employee_onboarding

db.user=sa
db.password=
db.initialization.enabled=true

# Server Configuration
mcp.server.name=Asset Allocation MCP Server
mcp.server.version=1.0.0
mcp.server.baseUrl=http://localhost:8085
```

#### Employee Onboarding MCP (`mcp-servers/employee-onboarding-mcp/src/main/resources/config.properties`)
```properties
# Database Strategy
db.strategy=h2

# Database Configuration (same patterns as above)
db.host=jdbc:h2:mem:employeedb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
db.user=sa
db.password=
db.initialization.enabled=true

# Server Configuration
mcp.server.name=Employee Onboarding MCP Server
mcp.server.version=1.0.0
mcp.server.baseUrl=http://localhost:8083
```

### Global Configuration (`mcp-servers/*/src/main/mule/global.xml`)

The database configurations are automatically loaded from the properties files. Ensure your global.xml has the correct database connectors:

```xml
<!-- H2 Database Configuration -->
<db:config name="H2_Database_Config">
    <db:generic-connection 
        driverClassName="org.h2.Driver"
        url="${db.host}"
        user="${db.user}"
        password="${db.password}">
        <reconnection>
            <reconnect frequency="3000" count="3"/>
        </reconnection>
    </db:generic-connection>
</db:config>

<!-- PostgreSQL Database Configuration -->
<db:config name="PostgreSQL_Database_Config">
    <db:generic-connection 
        driverClassName="org.postgresql.Driver"
        url="jdbc:postgresql://${db.host}:${db.port}/${db.name}"
        user="${db.user}"
        password="${db.password}">
        <reconnection>
            <reconnect frequency="3000" count="3"/>
        </reconnection>
    </db:generic-connection>
</db:config>
```

---

## Testing

### Database Connection Tests

#### Test H2 Connection
```bash
# Using H2 console (if running server mode)
# Navigate to: http://localhost:8082
# JDBC URL: jdbc:h2:tcp://localhost:9092/~/testdb
# User: sa, Password: (empty)

# Test query
SELECT 1 as test;
```

#### Test PostgreSQL Connection
```bash
# Command line test
psql -h localhost -p 5432 -U mcp_user -d employee_onboarding -c "SELECT 1 as test;"

# Or using Docker
docker exec -it mcp-postgres psql -U mcp_user -d employee_onboarding -c "SELECT 1 as test;"
```

### MCP Server Health Checks
```bash
# Test Asset Allocation MCP (H2)
curl -X GET http://localhost:8085/health

# Test Employee Onboarding MCP (H2)
curl -X GET http://localhost:8083/health

# Test Agent Broker MCP
curl -X GET http://localhost:8084/health
```

### Database Schema Verification
```sql
-- Check if tables were created successfully
-- For H2
SELECT table_name FROM information_schema.tables WHERE table_schema = 'PUBLIC';

-- For PostgreSQL
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check sample data
SELECT * FROM asset_categories LIMIT 5;
SELECT * FROM assets LIMIT 5;
SELECT * FROM employees LIMIT 5;
```

---

## Troubleshooting

### Common Issues and Solutions

#### H2 Database Issues

**Issue**: `Database "mem:testdb" not found`
**Solution**: 
- Ensure DB_CLOSE_DELAY=-1 is set in JDBC URL
- Check that the application is not closing the connection prematurely

**Issue**: H2 Web Console not accessible
**Solution**:
```bash
# Check if H2 server is running
netstat -an | grep 8082

# Restart H2 with web console
java -cp h2*.jar org.h2.tools.Server -web -webAllowOthers
```

#### PostgreSQL Issues

**Issue**: `Connection refused`
**Solution**:
```bash
# Check if PostgreSQL is running
# Windows
sc query postgresql

# Linux
sudo systemctl status postgresql

# Docker
docker ps | grep postgres

# Check port availability
netstat -an | grep 5432
```

**Issue**: `Authentication failed for user`
**Solution**:
```sql
-- Connect as postgres user and reset password
ALTER USER mcp_user WITH PASSWORD 'new_password';

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE employee_onboarding TO mcp_user;
GRANT ALL ON SCHEMA public TO mcp_user;
```

#### Docker Issues

**Issue**: Container startup failures
**Solution**:
```bash
# Check container logs
docker logs mcp-postgres
docker logs mcp-h2

# Check container status
docker ps -a

# Recreate containers
docker-compose down
docker-compose up -d
```

**Issue**: Port conflicts
**Solution**:
```bash
# Check what's using the ports
netstat -tulpn | grep :5432
netstat -tulpn | grep :8082

# Kill conflicting processes or change ports in docker-compose.yml
```

### Performance Optimization

#### PostgreSQL Optimization
```sql
-- Add indexes for better performance
CREATE INDEX idx_employees_employee_id ON employees(employee_id);
CREATE INDEX idx_assets_status ON assets(status);
CREATE INDEX idx_asset_allocations_employee_id ON asset_allocations(employee_id);
CREATE INDEX idx_asset_allocations_asset_id ON asset_allocations(asset_id);
```

#### H2 Optimization
```sql
-- H2 performance settings
SET CACHE_SIZE 131072;  -- 128MB cache
SET LOG 0;              -- Disable transaction log for faster inserts
```

### Backup and Recovery

#### PostgreSQL Backup
```bash
# Create backup
pg_dump -h localhost -U mcp_user employee_onboarding > backup.sql

# Restore backup
psql -h localhost -U mcp_user employee_onboarding < backup.sql

# Docker backup
docker exec mcp-postgres pg_dump -U mcp_user employee_onboarding > backup.sql
```

#### H2 Backup
```sql
-- Export database
SCRIPT TO 'backup.sql';

-- Import database
RUNSCRIPT FROM 'backup.sql';
```

---

## Quick Start Scripts

### Windows Quick Start
Create `setup-databases-windows.bat`:
```batch
@echo off
echo Setting up databases for MCP Employee Onboarding System...

echo Starting Docker containers...
docker-compose -f docker-compose-databases.yml up -d

echo Waiting for databases to initialize...
timeout /t 30

echo Testing connections...
curl -X GET http://localhost:8085/health
curl -X GET http://localhost:8083/health

echo Database setup complete!
echo H2 Console: http://localhost:8082
echo pgAdmin: http://localhost:8083 (admin@mcp.local / admin123)
pause
```

### Linux/Mac Quick Start
Create `setup-databases.sh`:
```bash
#!/bin/bash
echo "Setting up databases for MCP Employee Onboarding System..."

echo "Starting Docker containers..."
docker-compose -f docker-compose-databases.yml up -d

echo "Waiting for databases to initialize..."
sleep 30

echo "Testing connections..."
curl -X GET http://localhost:8085/health
curl -X GET http://localhost:8083/health

echo "Database setup complete!"
echo "H2 Console: http://localhost:8082"
echo "pgAdmin: http://localhost:8083 (admin@mcp.local / admin123)"
```

This comprehensive guide should help you set up and configure both H2 and PostgreSQL databases for your MCP Employee Onboarding system in various environments.
