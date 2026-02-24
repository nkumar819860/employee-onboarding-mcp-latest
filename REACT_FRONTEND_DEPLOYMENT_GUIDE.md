# 📱 React Frontend Deployment Guide
## Employee Onboarding MCP System - Frontend Setup

---

## 📋 OVERVIEW

The React frontend provides a user-friendly interface for the Employee Onboarding MCP System. It connects to the deployed MCP servers on CloudHub to provide a complete end-to-end experience.

**Frontend Location:** `employee-onboarding-agent-fabric/react-client/`

---

## 🚀 LOCAL DEVELOPMENT SETUP

### Step 1: Install Dependencies
```cmd
cd employee-onboarding-agent-fabric\react-client
npm install
```

### Step 2: Configure API Endpoints
The frontend will automatically connect to your deployed CloudHub MCP servers once they're running.

**Expected MCP Server URLs:**
- Employee Onboarding: `https://employee-onboarding-mcp-server.us-e1.cloudhub.io`
- Asset Allocation: `https://asset-allocation-mcp-server.us-e1.cloudhub.io`
- Notification: `https://notification-mcp-server.us-e1.cloudhub.io`
- Agent Broker: `https://employee-onboarding-agent-broker.us-e1.cloudhub.io`

### Step 3: Start Development Server
```cmd
npm start
```

The application will open at `http://localhost:3000`

---

## 🏗️ PRODUCTION DEPLOYMENT OPTIONS

### Option A: Build and Serve Locally

#### Step 1: Build Production Bundle
```cmd
cd employee-onboarding-agent-fabric\react-client
npm run build
```

#### Step 2: Serve Static Files
```cmd
# Option 1: Use serve package
npx serve -s build -l 3000

# Option 2: Use Python HTTP server
cd build
python -m http.server 3000

# Option 3: Use Node.js HTTP server
npx http-server build -p 3000 -c-1
```

### Option B: Deploy to Netlify

#### Step 1: Build the Application
```cmd
npm run build
```

#### Step 2: Deploy to Netlify
1. Go to [netlify.com](https://netlify.com)
2. Drag and drop the `build/` folder to deploy
3. Or use Netlify CLI:
```cmd
npx netlify-cli deploy --prod --dir=build
```

### Option C: Deploy to Vercel

#### Step 1: Install Vercel CLI
```cmd
npm install -g vercel
```

#### Step 2: Deploy
```cmd
cd employee-onboarding-agent-fabric\react-client
vercel --prod
```

### Option D: Deploy to AWS S3 + CloudFront

#### Step 1: Build the Application
```cmd
npm run build
```

#### Step 2: Upload to S3
```cmd
aws s3 sync build/ s3://your-bucket-name --delete
```

#### Step 3: Configure CloudFront Distribution
- Point CloudFront to your S3 bucket
- Set up custom error pages for SPA routing

---

## 🐳 DOCKER DEPLOYMENT

### Step 1: Build Docker Image
```cmd
cd employee-onboarding-agent-fabric\react-client
docker build -t employee-onboarding-frontend .
```

### Step 2: Run Container
```cmd
docker run -p 80:80 employee-onboarding-frontend
```

### Step 3: Deploy with Docker Compose
Use the existing `docker-compose.yml` in the project root:
```cmd
cd employee-onboarding-agent-fabric
docker-compose up react-client
```

---

## 🔧 CONFIGURATION

### Environment Variables
The React app uses these environment variables (optional):

```env
# .env.local file
REACT_APP_API_BASE_URL=https://employee-onboarding-agent-broker.us-e1.cloudhub.io
REACT_APP_EMPLOYEE_SERVICE_URL=https://employee-onboarding-mcp-server.us-e1.cloudhub.io
REACT_APP_ASSET_SERVICE_URL=https://asset-allocation-mcp-server.us-e1.cloudhub.io
REACT_APP_NOTIFICATION_SERVICE_URL=https://notification-mcp-server.us-e1.cloudhub.io
```

### API Service Configuration
The frontend automatically detects and connects to your CloudHub MCP servers. Check these files for configuration:

- `src/services/apiService.js` - Main API configuration
- `src/services/mcpService.js` - MCP server connections
- `src/services/nlpService.js` - Natural language processing

---

## 🧪 TESTING THE FRONTEND

### Step 1: Verify MCP Server Connectivity
1. Open browser developer tools (F12)
2. Go to Network tab
3. Load the frontend application
4. Check for successful API calls to CloudHub URLs

### Step 2: Test Core Features

#### Employee Onboarding Flow
1. Navigate to the Employee Onboarding section
2. Fill out the employee form:
   ```
   First Name: John
   Last Name: Doe
   Email: john.doe@company.com
   Department: Engineering
   Position: Software Developer
   Start Date: 2026-03-01
   ```
3. Submit and verify the process completes

#### Asset Allocation
1. Go to Asset Allocation section
2. Select an employee
3. Assign assets (laptop, phone, ID card)
4. Verify allocation is successful

#### Analytics Dashboard
1. Navigate to Analytics
2. Check employee metrics
3. Verify asset utilization data
4. Review onboarding completion rates

### Step 3: Test MCP Integration
1. Use the NLP Chat component
2. Ask natural language queries like:
   - "Show me all employees"
   - "What assets are available?"
   - "Create a new employee profile"
3. Verify responses from MCP servers

---

## 📊 FEATURES OVERVIEW

### 🏠 Dashboard
- Employee onboarding statistics
- Asset allocation metrics
- System health indicators
- Recent activity feed

### 👥 Employee Management
- Create new employee profiles
- View employee directory
- Track onboarding progress
- Manage employee data

### 🏢 Asset Allocation
- Asset inventory management
- Assign/unassign assets
- Track asset utilization
- Asset lifecycle management

### 📈 Analytics
- Onboarding completion rates
- Asset utilization statistics
- Department-wise metrics
- Time-to-productivity analysis

### 💬 NLP Chat Interface
- Natural language queries
- Intelligent responses from MCP servers
- Contextual assistance
- Automated task execution

---

## 🔍 TROUBLESHOOTING

### Common Issues

#### Frontend Not Loading
1. **Check Node.js version**: Requires Node.js 14+ 
2. **Clear npm cache**: `npm cache clean --force`
3. **Delete node_modules**: `rm -rf node_modules && npm install`

#### API Connection Failures
1. **Verify MCP servers are running** on CloudHub
2. **Check CORS configuration** in MCP servers
3. **Verify health endpoints** are accessible
4. **Check browser console** for detailed errors

#### Build Failures
1. **Update dependencies**: `npm update`
2. **Check for TypeScript errors**: `npm run type-check`
3. **Clear build cache**: `rm -rf build && npm run build`

### Health Check Commands
```cmd
# Check if MCP servers are accessible
curl https://employee-onboarding-agent-broker.us-e1.cloudhub.io/health
curl https://employee-onboarding-mcp-server.us-e1.cloudhub.io/health
curl https://asset-allocation-mcp-server.us-e1.cloudhub.io/health
curl https://notification-mcp-server.us-e1.cloudhub.io/health
```

---

## ✅ SUCCESS CRITERIA

**Frontend Deployment Success:**
- ✅ React app builds without errors
- ✅ Application loads in browser
- ✅ All MCP servers are accessible
- ✅ Employee onboarding flow works end-to-end
- ✅ Asset allocation functions properly
- ✅ Analytics dashboard displays data
- ✅ NLP chat responds to queries

**Performance Benchmarks:**
- Page load time < 3 seconds
- API response time < 1 second
- No JavaScript errors in console
- Mobile-responsive design works
- Cross-browser compatibility (Chrome, Firefox, Safari, Edge)

---

## 🎯 NEXT STEPS

1. **Deploy MCP servers first** using the manual CloudHub deployment guide
2. **Verify all health endpoints** are responding
3. **Deploy React frontend** using one of the methods above
4. **Test end-to-end functionality** with real employee data
5. **Configure production environment** variables if needed
6. **Set up monitoring** and logging for the frontend

**🚀 Ready to deploy? Start with the MCP servers, then deploy this frontend!**
