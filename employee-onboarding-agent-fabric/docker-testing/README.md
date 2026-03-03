# Employee Onboarding MCP Docker Testing Environment

This Docker testing environment provides a containerized setup for testing the Employee Onboarding MCP servers using **Mule Runtime 4.9.6**.

## 🏗️ Architecture Overview

The testing environment consists of:

- **Agent Broker MCP Server** (Port 8081) - Orchestrates the complete onboarding process
- **Employee Onboarding MCP Server** (Port 8082) - Manages employee profile creation
- **Asset Allocation MCP Server** (Port 8083) - Handles IT asset allocation
- **Notification MCP Server** (Port 8084) - Sends email notifications
- **PostgreSQL Database** (Port 5432) - Data persistence
- **MailCatcher** (Port 1080/1025) - Email testing
- **React Client** (Port 3000) - Optional frontend interface

## 🚀 Quick Start

### Prerequisites

- Docker Desktop installed and running
- Windows 10/11 with WSL2 (recommended) or Windows with Docker Desktop
- At least 8GB RAM available for Docker
- curl (for health checks)

### 1. Run the Build and Test Script

```bash
cd employee-onboarding-agent-fabric/docker-testing
build-and-test.bat
```

This script will:
1. Copy all MCP server code from the main project
2. Create Docker-optimized configurations
3. Build Docker images with Mule 4.9.6
4. Start all services with Docker Compose
5. Perform health checks
6. Display service URLs and test commands

### 2. Manual Setup (Alternative)

If you prefer manual setup:

```bash
# Copy the MCP server code manually
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f agent-broker-mcp
```

## 📡 Service Endpoints

| Service | URL | API Console | Health Check |
|---------|-----|-------------|--------------|
| Agent Broker | http://localhost:8081 | http://localhost:8081/console | http://localhost:8081/health |
| Employee Onboarding | http://localhost:8082 | http://localhost:8082/console | http://localhost:8082/health |
| Asset Allocation | http://localhost:8083 | http://localhost:8083/console | http://localhost:8083/health |
| Notification | http://localhost:8084 | http://localhost:8084/console | http://localhost:8084/health |
| React Client | http://localhost:3000 | - | - |
| PostgreSQL | localhost:5432 | - | - |
| MailCatcher | http://localhost:1080 | - | - |

## 🧪 Testing the Complete Onboarding Flow

### 1. Basic Health Checks

```bash
# Test all services are running
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health
curl http://localhost:8084/health
```

### 2. Complete Employee Onboarding

```bash
curl -X POST http://localhost:8081/api/mcp/tools/orchestrate-employee-onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe", 
    "email": "john.doe@company.com",
    "department": "IT",
    "position": "Software Developer",
    "startDate": "2026-03-03",
    "manager": "Jane Smith",
    "managerEmail": "jane.smith@company.com",
    "companyName": "Tech Solutions Inc",
    "assets": ["laptop", "phone", "id-card"]
  }'
```

### 3. Check Onboarding Status

```bash
curl -X POST http://localhost:8081/api/mcp/tools/get-onboarding-status \
  -H "Content-Type: application/json" \
  -d '{
    "employeeId": "EMP001"
  }'
```

### 4. View Email Notifications

Open http://localhost:1080 in your browser to see all sent emails via MailCatcher.

## 🔧 Configuration

### Environment Variables

Each service can be configured via environment variables in `docker-compose.yml`:

```yaml
environment:
  - MULE_ENV=docker
  - DB_HOST=postgres
  - DB_PORT=5432
  - DB_NAME=employee_onboarding
  - DB_USER=mcp_user
  - DB_PASSWORD=mcp_password
```

### Database Configuration

- **Database**: employee_onboarding
- **User**: mcp_user  
- **Password**: mcp_password
- **Port**: 5432

The database is automatically initialized with the required schema from `database/init-databases.sql`.

### Email Configuration

Email notifications are sent to MailCatcher (SMTP localhost:1025) for testing purposes.

## 🐛 Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using ports
   netstat -an | findstr "8081\|8082\|8083\|8084"
   
   # Stop conflicting services or modify ports in docker-compose.yml
   ```

2. **Memory Issues**
   ```bash
   # Increase Docker Desktop memory allocation
   # Docker Desktop -> Settings -> Resources -> Memory (recommend 8GB+)
   ```

3. **Service Startup Failures**
   ```bash
   # Check logs
   docker-compose logs agent-broker-mcp
   
   # Restart specific service
   docker-compose restart agent-broker-mcp
   ```

4. **Database Connection Issues**
   ```bash
   # Check PostgreSQL logs
   docker-compose logs postgres
   
   # Test database connectivity
   docker-compose exec postgres psql -U mcp_user -d employee_onboarding
   ```

### Health Check Failures

If health checks fail, wait longer for services to initialize (especially on slower systems):

```bash
# Check service status
docker-compose ps

# View real-time logs
docker-compose logs -f --tail=50

# Restart unhealthy services
docker-compose restart [service-name]
```

### Build Failures

```bash
# Clean Docker cache
docker system prune -a

# Rebuild with no cache
docker-compose build --no-cache

# Check Docker Desktop is running and has sufficient resources
```

## 🔍 Monitoring and Logs

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f agent-broker-mcp

# Last 100 lines
docker-compose logs --tail=100 agent-broker-mcp
```

### Service Status
```bash
# View running services
docker-compose ps

# View resource usage
docker stats
```

## 🧹 Cleanup

### Stop Services
```bash
# Stop services (containers remain)
docker-compose stop

# Stop and remove containers  
docker-compose down

# Stop, remove containers and volumes
docker-compose down -v
```

### Clean Docker Environment
```bash
# Remove unused images, networks, etc.
docker system prune

# Remove all stopped containers, unused networks, images and build cache
docker system prune -a
```

## 🔄 Development Workflow

### Making Changes to MCP Servers

1. Update code in the main `mcp-servers/` directory
2. Run the build script again to copy changes:
   ```bash
   build-and-test.bat
   ```
3. Or manually copy and restart:
   ```bash
   # Copy updated files
   xcopy /E /I /Y ..\mcp-servers\employee-onboarding-agent-broker\src services\agent-broker-mcp\src
   
   # Rebuild and restart
   docker-compose build agent-broker-mcp
   docker-compose restart agent-broker-mcp
   ```

### Testing Changes

1. Check service health after restart
2. Run test API calls to verify functionality
3. Check logs for errors
4. Use MailCatcher to verify email notifications

## 🌐 Integration Testing

This Docker environment is ideal for:

- **End-to-End Testing** - Complete onboarding workflow
- **Integration Testing** - Inter-service communication
- **Performance Testing** - Load testing with isolated environment
- **Email Testing** - Notification flow verification
- **Database Testing** - Data persistence and retrieval
- **API Testing** - RESTful API validation

## 📋 Features Tested

✅ **Agent Broker Orchestration**
- Complete employee onboarding workflow
- Error handling and rollback
- Service-to-service communication
- CORS support for web clients

✅ **Employee Profile Management**
- Employee creation and storage
- Profile retrieval and updates
- Data validation

✅ **Asset Allocation**
- IT asset assignment
- Asset tracking and management
- Integration with inventory systems

✅ **Email Notifications**
- Welcome emails
- Asset allocation notifications
- Completion confirmations
- Template-based emails

✅ **Database Operations**
- PostgreSQL integration
- CRUD operations
- Transaction management
- Data integrity

This Docker testing environment provides a complete, isolated testing platform for the Employee Onboarding MCP system using production-ready Mule 4.9.6 runtime.
