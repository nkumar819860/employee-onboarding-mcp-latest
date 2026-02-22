# Asset Allocation MCP Server

A comprehensive MuleSoft MCP (Model Context Protocol) server for managing asset allocation operations including laptops, ID cards, mobile phones, and other company assets.

## 🏗️ Project Structure

```
asset-allocation-mcp/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── asset-allocation-mcp-server.xml  # Main flow definitions
│   │   │   └── global.xml                       # Global configurations
│   │   └── resources/
│   │       └── config.properties               # Configuration properties
│   └── test/
│       ├── munit/                              # MUnit test files
│       └── resources/                          # Test resources
├── database/
│   └── init.sql                               # Database initialization script
├── pom.xml                                    # Maven project configuration
├── mule-artifact.json                         # Mule artifact configuration
├── exchange.json                              # Anypoint Exchange metadata
└── README.md                                  # This file
```

## 🚀 Features

### Asset Management
- **Multi-Category Support**: Laptops, desktops, ID cards, access cards, mobile phones, tablets, monitors, keyboards, mice, headsets, docking stations, parking passes
- **Comprehensive Tracking**: Asset tags, serial numbers, purchase information, warranty details
- **Status Management**: Available, allocated, maintenance, retired statuses
- **Condition Tracking**: New, good, fair, poor, damaged conditions

### Employee Operations
- **Asset Allocation**: Assign assets to employees with approval workflows
- **Asset Returns**: Process returns with condition assessment
- **Employee Asset View**: List all assets assigned to specific employees
- **Allocation History**: Complete audit trail of asset movements

### Database Support
- **Primary**: PostgreSQL for production environments
- **Fallback**: H2 in-memory database for CloudHub deployment
- **Auto-Failover**: Automatic database selection based on availability

## 🛠️ API Endpoints

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/health` | GET | Health check status |
| `/mcp/info` | GET | MCP server information |
| `/mcp/tools/allocate-asset` | POST | Allocate asset to employee |
| `/mcp/tools/return-asset` | POST | Return asset from employee |
| `/mcp/tools/list-assets` | GET | List assets with filtering |
| `/mcp/tools/get-asset-details` | GET | Get detailed asset information |
| `/mcp/tools/get-employee-assets` | GET | Get assets for employee |
| `/mcp/tools/add-asset` | POST | Add new asset to inventory |
| `/mcp/tools/update-asset-status` | POST | Update asset status |

## 📊 Database Schema

### Core Tables
- **departments**: Organization departments
- **employees**: Employee information
- **asset_categories**: Asset type definitions
- **assets**: Asset inventory
- **asset_allocations**: Assignment tracking
- **asset_maintenance**: Maintenance records

### Sample Asset Categories
- LAPTOP, DESKTOP, ID_CARD, ACCESS_CARD
- MOBILE_PHONE, TABLET, MONITOR, KEYBOARD
- MOUSE, HEADSET, DOCKING_STATION, PARKING_PASS

## 🔧 Configuration

### Database Configuration
```properties
# PostgreSQL (Primary)
db.postgres.url=jdbc:postgresql://localhost:5432/asset_allocation
db.postgres.username=postgres
db.postgres.password=postgres123

# H2 (Fallback)
db.h2.url=jdbc:h2:mem:asset_allocation;DB_CLOSE_DELAY=-1
```

### Application Properties
```properties
# Server Configuration
http.port=8082
mcp.serverName=Asset Allocation MCP Server
mcp.serverVersion=1.0.0

# Asset Management
asset.approval.required.categories=LAPTOP,DESKTOP,MOBILE_PHONE,TABLET,ACCESS_CARD
asset.auto.approval.limit=500.00
```

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Maven 3.6+
- PostgreSQL 12+ (optional, H2 fallback available)
- Mule Runtime 4.11.1+

### Local Development
1. **Clone the project**
2. **Setup database** (optional):
   ```sql
   CREATE DATABASE asset_allocation;
   ```
3. **Configure properties** in `config.properties`
4. **Run the application**:
   ```bash
   mvn clean install
   mvn mule:run
   ```
5. **Test health endpoint**:
   ```bash
   curl http://localhost:8082/health
   ```

### Sample API Calls

#### Allocate Asset
```bash
curl -X POST http://localhost:8082/mcp/tools/allocate-asset \
  -H "Content-Type: application/json" \
  -d '{
    "assetTag": "LAP-003",
    "employeeId": "EMP006",
    "reason": "New hire laptop allocation",
    "approvedBy": "John Mitchell",
    "notes": "Standard business laptop"
  }'
```

#### List Available Assets
```bash
curl "http://localhost:8082/mcp/tools/list-assets?status=AVAILABLE&category=LAPTOP"
```

#### Get Employee Assets
```bash
curl "http://localhost:8082/mcp/tools/get-employee-assets?employeeId=EMP001"
```

#### Return Asset
```bash
curl -X POST http://localhost:8082/mcp/tools/return-asset \
  -H "Content-Type: application/json" \
  -d '{
    "assetTag": "LAP-001",
    "condition": "GOOD",
    "notes": "Employee resignation - laptop returned in good condition"
  }'
```

## 🏷️ Asset Categories & Sample Data

The system comes pre-loaded with sample data including:
- **5 Laptops**: Dell, Apple, HP, Lenovo models
- **5 ID Cards**: Employee identification cards
- **3 Mobile Phones**: iPhone and Samsung devices
- **3 Access Cards**: Building access cards
- **3 Monitors**: Dell, LG, ASUS displays

## 📈 Monitoring & Logging

- Health check endpoint: `/health`
- Comprehensive logging at INFO level
- Database connectivity monitoring
- Error handling with detailed messages

## 🔐 Security Features

- Input validation and sanitization
- SQL injection prevention
- Error handling without sensitive data exposure
- Configurable approval workflows

## 🚢 Deployment

### CloudHub 2.0
The application is configured for CloudHub deployment with:
- Worker Type: MICRO
- Region: us-east-1
- H2 database fallback
- Environment-specific property overrides

### Runtime Fabric
Supports deployment to Runtime Fabric with PostgreSQL connectivity.

## 🤝 Contributing

1. Follow MuleSoft coding standards
2. Include comprehensive tests
3. Update documentation
4. Test with both PostgreSQL and H2 databases

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For support and issues:
- Check the health endpoint: `/health`
- Review application logs
- Validate database connectivity
- Ensure proper configuration properties

---

**Built with ❤️ using MuleSoft MCP Framework**
