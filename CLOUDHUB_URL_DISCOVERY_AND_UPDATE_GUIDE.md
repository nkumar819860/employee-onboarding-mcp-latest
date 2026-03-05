# CloudHub URL Discovery and Configuration Update Guide

## Overview

This guide provides a comprehensive solution for discovering actual deployed CloudHub application URLs and updating both test scripts and React client configuration with the correct URLs.

## Files Created

1. **`discover-and-update-cloudhub-urls.bat`** - Main discovery and update script
2. **`test-cloudhub-health.bat`** - Quick health check script (auto-generated)
3. **`cloudhub-urls.env`** - Configuration reference file (auto-generated)

## How It Works

### Step 1: URL Discovery
The script attempts to discover CloudHub URLs using multiple methods:

1. **Anypoint CLI Discovery** (if available)
   - Uses `anypoint-cli runtime-mgr application list` to get deployed applications
   
2. **Pattern-Based Discovery**
   - Tests common URL patterns based on artifact IDs from pom.xml files
   - Tests alternative hyphenated patterns based on folder names
   - Uses health check endpoints to validate URL accessibility

### Step 2: Configuration Updates
Automatically updates all necessary configuration files:

1. **React Environment Files**
   - `.env.production` - CloudHub production configuration
   - `.env.staging` - CloudHub staging configuration

2. **API Service Configuration**
   - `apiService.js` - Enhanced with CloudHub-specific features

3. **Test Scripts**
   - Updates `test-agent-fabric-comprehensive-nlp-mcp.js` with correct URLs

## Usage Instructions

### Basic Usage
```bash
# Run the discovery and update script
discover-and-update-cloudhub-urls.bat
```

### Manual URL Override
If you know your exact CloudHub URLs, you can set them manually:

```bash
# Set environment variables before running
set CLOUDHUB_REGION=us-e1
set AGENT_BROKER_URL=https://your-agent-broker.us-e1.cloudhub.io
set EMPLOYEE_ONBOARDING_URL=https://your-employee-service.us-e1.cloudhub.io
# ... then run the script
discover-and-update-cloudhub-urls.bat
```

## Updated Configuration Features

### Enhanced React Environment Configuration

#### Production Environment (`.env.production`)
```bash
# CloudHub URLs
REACT_APP_AGENT_BROKER_URL=https://onboardingbroker.us-e1.cloudhub.io
REACT_APP_EMPLOYEE_ONBOARDING_URL=https://employeeonboardingmcp.us-e1.cloudhub.io
REACT_APP_ASSET_ALLOCATION_URL=https://assetallocationserver.us-e1.cloudhub.io
REACT_APP_EMAIL_NOTIFICATION_URL=https://emailnotificationmcp.us-e1.cloudhub.io

# API Configuration
REACT_APP_API_TIMEOUT=30000
REACT_APP_MAX_RETRIES=3
REACT_APP_RETRY_DELAY=2000

# CloudHub Specific
REACT_APP_USE_CLOUDHUB=true
REACT_APP_ENABLE_HTTPS=true
```

### Enhanced API Service Features

The updated `apiService.js` includes:

1. **Automatic URL Normalization**
   - HTTPS enforcement for CloudHub environments
   - Proper URL construction and validation

2. **Advanced Error Handling**
   - Exponential backoff with jitter for retries
   - Comprehensive error logging
   - Timeout configuration

3. **CloudHub-Optimized Requests**
   - Proper CORS headers
   - CloudHub-compatible request configuration
   - Enhanced timeout handling

4. **Health Check Integration**
   - Individual service health checks
   - Comprehensive system health validation
   - Health status aggregation

## Verification Steps

### 1. URL Discovery Verification
```bash
# Check if URLs are accessible
test-cloudhub-health.bat
```

### 2. Manual URL Verification
Check each service health endpoint:
```bash
curl https://your-service.us-e1.cloudhub.io/health
```

### 3. React Client Testing
```bash
cd employee-onboarding-agent-fabric/react-client
npm install
npm run build
npm start
```

### 4. End-to-End Testing
```bash
node test-agent-fabric-comprehensive-nlp-mcp.js --cloudhub
```

## Troubleshooting

### Common Issues

#### 1. URLs Not Found
**Problem**: Script cannot discover CloudHub URLs
**Solutions**:
- Check Anypoint Platform Runtime Manager for actual application names
- Verify applications are deployed and running
- Manually set URLs using environment variables

#### 2. Health Check Failures
**Problem**: Health endpoints return errors
**Solutions**:
- Verify CloudHub applications are running
- Check application logs in Anypoint Platform
- Ensure health endpoints are properly implemented

#### 3. CORS Issues in React Client
**Problem**: Browser blocks API calls due to CORS
**Solutions**:
- Ensure CloudHub applications have proper CORS configuration
- Verify API Gateway settings if using API Manager
- Check that requests are using HTTPS for CloudHub

#### 4. Authentication Errors
**Problem**: API calls return 401/403 errors
**Solutions**:
- Verify CloudHub application security settings
- Check if authentication headers are required
- Review API policy configurations

### Regional Configuration

For different CloudHub regions, set the region before running:

```bash
# US East (default)
set CLOUDHUB_REGION=us-e1

# US West
set CLOUDHUB_REGION=us-w1

# EU
set CLOUDHUB_REGION=eu-c1

# Asia Pacific
set CLOUDHUB_REGION=ap-se1
```

## File Structure After Update

```
project-root/
├── discover-and-update-cloudhub-urls.bat     # Main script
├── test-cloudhub-health.bat                   # Auto-generated health check
├── cloudhub-urls.env                          # Auto-generated URL config
└── employee-onboarding-agent-fabric/
    └── react-client/
        ├── .env.production                     # Updated production config
        ├── .env.staging                        # Updated staging config
        └── src/
            └── services/
                └── apiService.js              # Enhanced API service
```

## Best Practices

1. **Regular URL Verification**
   - Run health checks after each deployment
   - Monitor CloudHub application status

2. **Environment Management**
   - Use different URLs for staging and production
   - Keep environment files properly configured

3. **Error Handling**
   - Implement proper fallback mechanisms
   - Log API errors for debugging

4. **Security Considerations**
   - Always use HTTPS for CloudHub
   - Implement proper authentication
   - Configure CORS policies correctly

## Next Steps After Configuration

1. **Verify URLs**: Check Anypoint Platform Runtime Manager for exact URLs
2. **Test Endpoints**: Run comprehensive test suite
3. **Build React Client**: Create production build with new configuration
4. **Deploy Frontend**: Deploy React client to your hosting platform
5. **Monitor Health**: Set up monitoring for CloudHub endpoints

## Support

If you encounter issues:
1. Check CloudHub application logs in Anypoint Platform
2. Verify network connectivity to CloudHub URLs
3. Review API policy configurations
4. Test individual endpoints manually with tools like Postman or curl

This solution provides a complete automation framework for CloudHub URL discovery and configuration management, ensuring your React client and test scripts always use the correct endpoints.
