# Employee Onboarding System with NLP Processing

A comprehensive, dockerized employee onboarding system featuring natural language processing capabilities, built with React frontend and MuleSoft MCP (Model Context Protocol) servers.

## 🏗️ Architecture

### Components
- **React NLP Client** (Port 3000) - Modern web interface with natural language processing
- **Agent Broker MCP** (Port 8080) - Main orchestration service
- **Employee Onboarding MCP** (Port 8081) - Employee management service  
- **Asset Allocation MCP** (Port 8082) - Asset and inventory management
- **Notification MCP** (Port 8083) - Email and notification service
- **PostgreSQL Database** (Port 5432) - Persistent data storage

### Technology Stack
- **Frontend**: React 18, Material-UI, NLP libraries (compromise.js, sentiment analysis)
- **Backend**: MuleSoft Mule Runtime, Java 17
- **Database**: PostgreSQL 15
- **Containerization**: Docker & Docker Compose
- **NLP**: compromise.js, Natural.js, Sentiment analysis, Speech recognition

## 🚀 Features

### Natural Language Processing
- **Intent Recognition**: Automatically detects user intentions from natural language
- **Entity Extraction**: Identifies people, employee IDs, assets, and other entities
- **Sentiment Analysis**: Analyzes emotional tone of user inputs  
- **Speech Recognition**: Voice-to-text input capability
- **Multi-language Support**: Extensible NLP pipeline

### Core Functionality
- **Employee Management**: Create, track, and manage employee onboarding
- **Asset Allocation**: Manage laptops, phones, ID cards, and other equipment
- **Automated Notifications**: Send welcome emails, reminders, and alerts
- **Real-time Analytics**: Dashboard with metrics and insights
- **Health Monitoring**: Service status and performance tracking

### Supported NLP Commands
```
"Create new employee John Smith"
"Allocate laptop to employee EMP001"  
"Show me all available assets"
"Get employee onboarding status"
"Send notification to new employees"
"What assets are allocated to EMP002?"
```

## 📋 Prerequisites

- Docker Desktop 4.0+
- Docker Compose 2.0+
- 8GB+ RAM available
- Ports 3000, 8080-8083, 5432 available

## 🎯 Quick Start

### 1. Clone and Navigate
```bash
git clone <repository-url>
cd employee-onboarding-agent-fabric
```

### 2. Deploy Everything
```bash
# Windows
test-e2e-deployment.bat

# Linux/Mac  
chmod +x test-e2e-deployment.sh
./test-e2e-deployment.sh
```

### 3. Access the System
- **Main Application**: http://localhost:3000
- **NLP Chat Interface**: http://localhost:3000/chat
- **API Documentation**: http://localhost:8080/console

## 🗄️ Database Schema

### Key Tables
- `employees` - Employee records and status
- `assets` - Equipment and inventory
- `asset_allocations` - Asset assignments
- `asset_categories` - Asset types and policies
- `departments` - Organizational structure

### Sample Data
The system includes pre-loaded sample data:
- 8 employees across multiple departments
- 20+ assets (laptops, phones, ID cards)
- Asset allocation history
- Department and category configurations

## 🔧 Configuration

### Environment Variables
```env
# React Client
REACT_APP_API_BASE_URL=http://localhost:8080
REACT_APP_EMPLOYEE_API_URL=http://localhost:8081
REACT_APP_ASSET_API_URL=http://localhost:8082
REACT_APP_NOTIFICATION_API_URL=http://localhost:8083

# Database
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres_pass
```

### Service Configuration
Each MCP server can be configured via environment variables in `docker-compose.yml`:
- Memory allocation (JAVA_OPTS)
- Database connections
- Service-specific settings

## 🧪 Testing

### Manual Testing
1. Start the system: `docker-compose up -d`
2. Visit http://localhost:3000/chat
3. Try NLP commands:
   - "Create employee Sarah Johnson"
   - "Allocate laptop to EMP001"
   - "Show available assets"

### API Testing
```bash
# Health checks
curl http://localhost:8080/health
curl http://localhost:8081/health  
curl http://localhost:8082/health
curl http://localhost:8083/health

# Database check
docker-compose exec postgres psql -U postgres -c "\l"
```

### NLP Testing
The NLP engine supports various input patterns:
- **Formal**: "Please create a new employee named John Doe"
- **Casual**: "Add John Doe as an employee"  
- **Commands**: "Create employee John Doe"
- **Questions**: "Can you show me available laptops?"

## 🔍 Monitoring

### Service Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f react-nlp-client
docker-compose logs -f agent-broker-mcp
docker-compose logs -f postgres
```

### Health Monitoring
- Dashboard shows real-time service status
- Built-in health checks for all components
- Database connection monitoring
- Performance metrics tracking

## 🛠️ Development

### Local Development Setup
```bash
# Start only backend services
docker-compose up -d postgres employee-onboarding-mcp asset-allocation-mcp

# Run React client locally
cd react-client
npm install
npm start
```

### Adding New NLP Intents
1. Edit `react-client/src/services/nlpService.js`
2. Add intent patterns and keywords
3. Update entity recognition rules
4. Implement action handlers in `NLPChat.js`

### Database Migrations
```sql
-- Connect to database
docker-compose exec postgres psql -U postgres -d asset_allocation

-- Run custom migrations
\i /path/to/migration.sql
```

## 🐳 Docker Services

### Service Dependencies
```
react-nlp-client
├── agent-broker-mcp
├── employee-onboarding-mcp  
├── asset-allocation-mcp
└── notification-mcp

agent-broker-mcp
└── notification-mcp

employee-onboarding-mcp
└── postgres

asset-allocation-mcp  
└── postgres
```

### Volume Mounts
- `postgres_data` - Database persistence
- `mule-logs` - Application logs
- Init SQL scripts mounted read-only

## 🚨 Troubleshooting

### Common Issues

**Services won't start**
```bash
# Check Docker resources
docker system df
docker system prune -f

# Restart with fresh build
docker-compose down --volumes
docker-compose up --build
```

**Database connection errors**
```bash
# Check PostgreSQL status
docker-compose exec postgres pg_isready -U postgres

# View database logs
docker-compose logs postgres
```

**React client build fails**
```bash
# Check Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"
docker-compose build react-nlp-client --no-cache
```

**NLP not working**
- Ensure speech recognition permissions in browser
- Check browser console for JavaScript errors
- Verify API endpoints are accessible

### Performance Tuning
```bash
# Increase memory for Mule services
export JAVA_OPTS="-Xms1g -Xmx2g"

# Optimize PostgreSQL
docker-compose exec postgres psql -U postgres -c "
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';"
```

## 📊 Sample NLP Interactions

### Employee Management
```
User: "Create a new employee named Alice Johnson with email alice.johnson@company.com"
System: "Employee Alice Johnson created successfully with ID: EMP009"

User: "What's the onboarding status for EMP001?"
System: "Employee EMP001 status: IN_PROGRESS (3/5 steps completed)"
```

### Asset Allocation  
```
User: "Allocate a laptop to employee EMP003"
System: "Laptop allocated to employee EMP003 successfully"

User: "Show me all available phones"
System: "Found 1 available assets: Samsung Galaxy S24"
```

### Notifications
```
User: "Send welcome notification to new employees"
System: "Notification sent successfully to 3 employees"
```

## 🔐 Security Considerations

- Database credentials should be changed for production
- API endpoints should use authentication
- Network segmentation recommended for production
- Regular security updates for base images

## 📈 Scaling

### Horizontal Scaling
- Add load balancer for React client
- Scale MCP services with Docker Swarm/Kubernetes
- Implement database replication
- Add Redis for caching

### Performance Optimization
- Enable database connection pooling
- Implement API response caching
- Optimize Docker image sizes
- Use CDN for static assets

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Add tests for new functionality  
4. Update documentation
5. Submit pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create GitHub issues for bugs
- Check troubleshooting section
- Review service logs for errors
- Test with provided sample commands

---

**Ready to experience intelligent employee onboarding with natural language processing!** 🚀
