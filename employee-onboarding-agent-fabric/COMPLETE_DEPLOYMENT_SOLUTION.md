# 🚀 Complete Employee Onboarding System - Deployment Solutions

## 📋 Problem Summary
The employee onboarding system consists of 4 MCP servers + React frontend that need to be deployed to CloudHub 2.0, but runtime version compatibility issues prevent successful deployment.

## ✅ Multiple Solution Approaches

### 🎯 **SOLUTION 1: Updated Runtime Versions (RECOMMENDED)**

**Use the new deployment script:** `deploy-cloudhub-fixed-runtime.bat`

This script uses:
- **Primary Runtime:** `4.8.0:40e-java17` (Latest stable with Java 17)
- **Fallback Runtime:** `4.7.2` (If primary fails)
- **Automatic Runtime Detection:** Lists available runtimes if both fail

**To Execute:**
```bash
cd employee-onboarding-agent-fabric
deploy-cloudhub-fixed-runtime.bat
```

---

### 🐳 **SOLUTION 2: Local Docker Deployment (DEVELOPMENT)**

**Complete local environment for development and testing:**

**Prerequisites:**
- Docker & Docker Compose installed
- All environment variables configured in `.env`

**To Execute:**
```bash
cd employee-onboarding-agent-fabric
docker-compose up --build -d
```

**Services Available:**
- 🤖 Agent Broker: `http://localhost:8080`
- 👥 Employee Service: `http://localhost:8081`
- 💼 Asset Service: `http://localhost:8082`
- 🔔 Notification Service: `http://localhost:8083`
- 🌐 React Frontend: `http://localhost:3000`
- 🗄️ PostgreSQL: `localhost:5432`

---

### 🔧 **SOLUTION 3: Runtime Version Discovery**

**Find exactly which runtime versions are supported:**

```bash
# Navigate to any MCP server directory
cd mcp-servers/notification-mcp

# List available runtimes for your organization
mvn mule:list-runtimes \
  -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 \
  -Danypoint.environment=Sandbox
```

This will show you all available runtime versions you can use.

---

### 🏗️ **SOLUTION 4: Individual Service Deployment**

**Deploy services one by one to isolate issues:**

**Step 1: Deploy Notification Service First**
```bash
cd mcp-servers/notification-mcp
mvn clean deploy -DmuleDeploy \
  -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 \
  -Danypoint.environment=Sandbox \
  -Dcloudhub.applicationName=notification-mcp-server \
  -Dcloudhub.muleVersion=4.8.0:40e-java17 \
  -DskipTests
```

**Step 2: Verify Deployment**
```bash
curl https://notification-mcp-server.us-e1.cloudhub.io/health
```

**Step 3: Repeat for other services**

---

### 🔍 **SOLUTION 5: MCP-Only Deployment (IMMEDIATE USE)**

**Use the existing MCP integration without CloudHub:**

The MCP server is already functional and can be used directly:

```javascript
// Test MCP orchestration directly
use_mcp_tool({
  server_name: "employee-onboarding-agent-broker",
  tool_name: "orchestrate-employee-onboarding",
  arguments: {
    firstName: "John",
    lastName: "Doe", 
    email: "john.doe@company.com",
    department: "Engineering",
    position: "Software Developer",
    startDate: "2024-03-01",
    salary: 75000,
    assets: ["laptop", "phone", "id-card"]
  }
});
```

---

### 📱 **SOLUTION 6: React Frontend Deployment**

**Deploy React frontend independently:**

**Step 1: Build Production Version**
```bash
cd react-client
npm install
npm run build
```

**Step 2: Deploy to Static Hosting**
- **Netlify:** Drag `build/` folder to Netlify
- **Vercel:** `vercel --prod`
- **AWS S3:** Upload `build/` folder to S3 bucket
- **GitHub Pages:** Push `build/` to `gh-pages` branch

**Step 3: Update API URLs**
Update environment variables to point to CloudHub services once deployed.

---

## 🎯 **RECOMMENDED DEPLOYMENT STRATEGY**

### **Phase 1: Immediate Testing (Docker)**
1. Run `docker-compose up --build -d`
2. Test all functionality locally
3. Verify MCP integration works
4. Test React frontend functionality

### **Phase 2: CloudHub Deployment**
1. Run `deploy-cloudhub-fixed-runtime.bat`
2. If runtime issues persist, run `mvn mule:list-runtimes` to find supported versions
3. Update deployment script with supported runtime version
4. Deploy services individually to isolate issues

### **Phase 3: Frontend Deployment**
1. Deploy React frontend to static hosting
2. Update environment variables to point to CloudHub services
3. Test end-to-end functionality

---

## 🔧 **Troubleshooting Guide**

### **If Runtime Version Still Fails:**

**Option A: Check Organization Runtime Permissions**
```bash
mvn mule:describe-runtime \
  -Danypoint.businessGroup=47562e5d-bf49-440a-a0f5-a9cea0a89aa9 \
  -Danypoint.environment=Sandbox \
  -Dcloudhub.muleVersion=4.8.0:40e-java17
```

**Option B: Use CloudHub CLI**
```bash
# Install CloudHub CLI
npm install -g cloudhub-cli

# List available runtimes
cloudhub runtime-mgr:list-runtimes --environment=Sandbox
```

**Option C: Contact MuleSoft Support**
If no runtime versions work, contact MuleSoft support to:
- Enable newer runtime versions for your organization
- Check CloudHub 2.0 compatibility
- Verify account permissions

---

## 📊 **System Status After Deployment**

### **Health Check URLs (CloudHub):**
- 🔔 Notification: `https://notification-mcp-server.us-e1.cloudhub.io/health`
- 👥 Employee: `https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health`
- 💼 Asset: `https://asset-allocation-mcp-server.us-e1.cloudhub.io/health`
- 🤖 Agent Broker: `https://agent-broker-mcp-server.us-e1.cloudhub.io/health`

### **MCP Endpoints:**
- 📋 System Info: `https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/info`
- 🔧 Tools: `https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/`
- 📊 Resources: `https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/resources/`

### **Test Employee Onboarding:**
```bash
curl -X POST https://agent-broker-mcp-server.us-e1.cloudhub.io/mcp/tools/orchestrate-employee-onboarding \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@test.com",
    "department": "Engineering",
    "position": "Software Developer",
    "startDate": "2024-03-01",
    "salary": 75000,
    "assets": ["laptop", "phone", "id-card"]
  }'
```

---

## 🎯 **SUCCESS CRITERIA**

✅ **Deployment Successful When:**
- All 4 MCP services return 200 on `/health` endpoints
- MCP orchestration endpoint accepts and processes requests
- React frontend loads and connects to backend services
- Database operations work (employee creation, asset allocation)
- Email notifications are sent successfully

---

## 📞 **Next Steps**

1. **Try Solution 1:** Run `deploy-cloudhub-fixed-runtime.bat`
2. **If fails:** Use Solution 3 to find supported runtime versions
3. **Immediate use:** Solution 5 (MCP-only) works right now
4. **Development:** Solution 2 (Docker) for local testing

The system is fully built and ready - it's just a matter of finding the right runtime version for CloudHub deployment!
