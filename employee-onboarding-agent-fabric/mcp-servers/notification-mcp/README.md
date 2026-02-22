# Notification MCP Server

A comprehensive MuleSoft MCP (Model Context Protocol) server for automated email notifications supporting employee onboarding and asset allocation processes using Gmail SMTP integration.

## 🏗️ Project Structure

```
notification-mcp/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── notification-mcp-server.xml   # Main notification flows
│   │   │   └── global.xml                     # Gmail SMTP configurations
│   │   └── resources/
│   │       ├── config.properties             # Configuration properties
│   │       └── templates/                    # HTML email templates
│   │           ├── employee-welcome.html     # Welcome email template
│   │           ├── asset-allocation.html     # Asset notification template
│   │           └── onboarding-complete.html  # Completion email template
│   └── test/
│       ├── munit/                            # MUnit test files
│       └── resources/                        # Test resources
├── pom.xml                                   # Maven project configuration
├── mule-artifact.json                        # Mule runtime configuration
├── exchange.json                             # Anypoint Exchange metadata
└── README.md                                 # This file
```

## 🚀 Features

### Email Notification Types
- **Welcome Emails**: Professional onboarding emails for new employees
- **Asset Notifications**: Equipment allocation confirmations with details
- **Completion Messages**: Comprehensive onboarding completion summaries
- **Test Emails**: Configuration validation and testing

### Gmail SMTP Integration
- **Secure Connection**: TLS encryption for email transmission
- **App Password Support**: Enhanced security with Gmail app passwords  
- **Error Handling**: Comprehensive email delivery error management
- **Configuration Testing**: Built-in email configuration validation

### Email Templates
- **Responsive Design**: Mobile-friendly HTML email templates
- **Dynamic Content**: Template variable replacement system
- **Professional Styling**: Corporate-ready email designs
- **Multi-Language Ready**: Template structure supports localization

## 🛠️ API Endpoints

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/health` | GET | Health check status |
| `/mcp/info` | GET | MCP server information |
| `/mcp/tools/send-welcome-email` | POST | Send employee welcome notification |
| `/mcp/tools/send-asset-notification` | POST | Send asset allocation confirmation |
| `/mcp/tools/send-onboarding-complete` | POST | Send onboarding completion notification |
| `/mcp/tools/test-email-config` | POST | Test Gmail SMTP configuration |

## 📧 Gmail Configuration

### Prerequisites
1. **Gmail Account** with two-factor authentication enabled
2. **App Password** generated for SMTP access
3. **SMTP Access** enabled in Gmail settings

### Setup Steps
1. **Enable 2FA**: Go to Google Account → Security → 2-Step Verification
2. **Generate App Password**: 
   - Google Account → Security → App passwords
   - Select "Mail" and generate password
   - Copy the 16-character password
3. **Configure Properties**: Set Gmail credentials in properties file

### Security Configuration
```properties
# Gmail SMTP Configuration
gmail.smtp.host=smtp.gmail.com
gmail.smtp.port=587
gmail.smtp.username=${gmail.username}
gmail.smtp.password=${gmail.password}  # Use App Password
gmail.smtp.startTlsEnabled=true
gmail.smtp.auth=true
```

## 🔧 Configuration

### Environment Variables
```properties
# Required Gmail Settings
gmail.username=your-gmail@gmail.com
gmail.password=your-app-password

# Optional Notification Settings
notification.cc.hr=hr@company.com
notification.cc.it=it@company.com
email.from.name=HR Notification System
```

### Template Variables
The system supports dynamic content replacement in email templates:

#### Employee Information
- `{{employeeName}}` - Full name
- `{{employeeId}}` - Employee ID
- `{{department}}` - Department name
- `{{position}}` - Job position
- `{{email}}` - Email address

#### Asset Information
- `{{assetName}}` - Asset name
- `{{assetTag}}` - Asset tag/ID
- `{{brand}}` - Asset brand
- `{{model}}` - Asset model
- `{{condition}}` - Asset condition

#### Company Information
- `{{companyName}}` - Company name
- `{{managerName}}` - Manager name
- `{{startDate}}` - Start date

## 🚀 Getting Started

### Prerequisites
- Java 17+
- Maven 3.6+
- Gmail account with app password
- Mule Runtime 4.11.1+

### Local Development
1. **Clone the project**
2. **Configure Gmail**:
   ```bash
   # Set environment variables
   export gmail.username=your-gmail@gmail.com
   export gmail.password=your-app-password
   ```
3. **Run the application**:
   ```bash
   mvn clean install
   mvn mule:run -Dhttp.port=8083
   ```
4. **Test configuration**:
   ```bash
   curl http://localhost:8083/health
   ```

### Sample API Calls

#### Test Email Configuration
```bash
curl -X POST http://localhost:8083/mcp/tools/test-email-config \
  -H "Content-Type: application/json" \
  -d '{
    "testEmail": "test@example.com"
  }'
```

#### Send Welcome Email
```bash
curl -X POST http://localhost:8083/mcp/tools/send-welcome-email \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "employeeId": "EMP001",
    "department": "Engineering",
    "position": "Software Engineer",
    "startDate": "2024-03-01",
    "manager": "Jane Smith",
    "companyName": "Tech Corp"
  }'
```

#### Send Asset Allocation Notification
```bash
curl -X POST http://localhost:8083/mcp/tools/send-asset-notification \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@company.com",
    "employeeId": "EMP001",
    "allocationDate": "2024-03-01",
    "approvedBy": "IT Manager",
    "assets": [
      {
        "assetName": "MacBook Pro",
        "assetTag": "LAP-001",
        "category": "LAPTOP",
        "brand": "Apple",
        "model": "MacBook Pro 14",
        "condition": "NEW",
        "specifications": "32GB RAM, 1TB SSD"
      }
    ]
  }'
```

#### Send Onboarding Complete
```bash
curl -X POST http://localhost:8083/mcp/tools/send-onboarding-complete \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe", 
    "email": "john.doe@company.com",
    "employeeId": "EMP001",
    "department": "Engineering",
    "position": "Software Engineer",
    "startDate": "2024-03-01",
    "managerName": "Jane Smith",
    "managerEmail": "jane.smith@company.com",
    "assets": [
      {
        "assetName": "MacBook Pro",
        "assetTag": "LAP-001",
        "category": "LAPTOP",
        "condition": "NEW"
      }
    ]
  }'
```

## 🎨 Email Templates

### Welcome Email Features
- Professional company branding
- Employee information summary
- Next steps checklist
- Contact information
- Mobile-responsive design

### Asset Allocation Features
- Detailed asset listings
- Responsibility guidelines
- Contact information
- Pickup/delivery instructions

### Onboarding Complete Features
- Achievement celebration
- Asset summary
- Resource links
- Next steps timeline
- Manager contact details

## 📈 Monitoring & Logging

- Health check endpoint: `/health`
- Comprehensive logging at INFO level
- Email delivery status tracking
- Error handling with detailed messages
- SMTP connection monitoring

## 🔐 Security Features

- Secure property handling for Gmail credentials
- TLS encryption for SMTP connections
- Input validation and sanitization
- Error handling without credential exposure
- Gmail app password authentication

## 🚢 Deployment

### CloudHub 2.0
The application is configured for CloudHub deployment with:
- Worker Type: MICRO
- Region: us-east-1
- Port: 8083
- Secure properties for Gmail credentials

### Runtime Fabric
Supports deployment to Runtime Fabric with Gmail connectivity.

### Environment Variables for Production
```properties
# Production Gmail Configuration
gmail.username=${secure::gmail.username}
gmail.password=${secure::gmail.password}
notification.cc.hr=hr@yourcompany.com
notification.cc.it=it-support@yourcompany.com
```

## 🔗 Integration

### With Employee Onboarding MCP
```bash
# After employee creation, trigger welcome email
curl -X POST http://localhost:8083/mcp/tools/send-welcome-email \
  -H "Content-Type: application/json" \
  -d "$(curl http://localhost:8081/mcp/tools/get-employee?empId=EMP001)"
```

### With Asset Allocation MCP
```bash
# After asset allocation, trigger notification
curl -X POST http://localhost:8083/mcp/tools/send-asset-notification \
  -H "Content-Type: application/json" \
  -d "$(curl http://localhost:8082/mcp/tools/get-employee-assets?employeeId=EMP001)"
```

## 🛠️ Customization

### Adding New Templates
1. Create HTML template in `src/main/resources/templates/`
2. Add template path to `config.properties`
3. Create new MCP tool in `notification-mcp-server.xml`
4. Add template variable replacement logic

### Modifying Email Styling
- Update CSS in template `<style>` sections
- Maintain responsive design principles
- Test across email clients
- Ensure accessibility compliance

## ❓ Troubleshooting

### Common Issues

**Email Not Sending**
- Check Gmail app password is correct
- Verify 2FA is enabled on Gmail account
- Ensure SMTP port 587 is not blocked
- Check Gmail "Less secure app access" if needed

**Template Variables Not Replaced**
- Verify variable names match exactly (case-sensitive)
- Check JSON payload contains all required fields
- Review DataWeave transformation logic

**Build Failures**
- Ensure Maven 3.6+ and Java 17+
- Check internet connectivity for dependencies
- Verify pom.xml syntax is correct

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For support and issues:
- Check the health endpoint: `/health`
- Test email configuration: `/mcp/tools/test-email-config`
- Review application logs
- Validate Gmail SMTP settings

---

**Built with ❤️ using MuleSoft MCP Framework and Gmail SMTP**
