# Environment Toggle Functionality

## Overview

This document describes the environment toggle functionality implemented in the Employee Onboarding React client. The system allows users to dynamically switch between different deployment environments (Development, Staging, Production) and automatically refreshes all API connections and content without requiring a page reload.

## Features

### 1. Environment Context Management
- **EnvironmentProvider**: Centralized context provider that manages environment state across the application
- **Environment Persistence**: Selected environment is saved to localStorage and persists across browser sessions
- **Dynamic Configuration**: Each environment has its own API endpoints and configuration settings

### 2. Visual Environment Selector
- **Navbar Integration**: Environment selector is embedded in the application navbar for easy access
- **Visual Indicators**: Each environment has distinct colors and icons:
  - Development: Green with Computer icon
  - Staging: Orange with Build icon  
  - Production: Red with Cloud icon
- **Current Environment Display**: Shows the active environment with a colored chip
- **Tooltip Information**: Hover tooltip displays current environment name and base URL

### 3. Automatic Content Refresh
- **API Service Updates**: Automatically reconfigures all API service endpoints when environment changes
- **Component Refresh**: Components can register callbacks to refresh their content when environment switches
- **Success Notifications**: User receives confirmation when environment switch is successful

### 4. Environment Configurations

#### Development Environment
- **Base URL**: http://localhost:8081
- **Target**: Local development servers
- **Features**: Debug mode enabled, console logs, mock API fallbacks

#### Staging Environment  
- **Base URL**: http://agent-broker-mcp-server-staging.us-e1.cloudhub.io
- **Target**: CloudHub staging deployment
- **Features**: Performance monitoring, error tracking

#### Production Environment
- **Base URL**: http://agent-broker-mcp-server.us-e1.cloudhub.io  
- **Target**: CloudHub production deployment
- **Features**: Optimized for performance and stability

## Implementation Details

### Core Components

#### 1. EnvironmentContext (`src/contexts/EnvironmentContext.js`)
```javascript
const ENVIRONMENTS = {
  development: { /* config */ },
  staging: { /* config */ },
  production: { /* config */ }
};
```

#### 2. EnvironmentSelector (`src/components/EnvironmentSelector.js`)
- Material-UI Select component with custom styling
- Environment-specific icons and colors
- Success notifications via Snackbar

#### 3. API Service Integration (`src/services/apiService.js`)
- `updateEnvironmentUrls(environmentConfig)` method
- Recreates axios instances with new base URLs
- Maintains error handling and interceptors

### Usage Example

```javascript
import { useEnvironment } from '../contexts/EnvironmentContext';

const MyComponent = () => {
  const { currentEnvironment, environmentConfig, switchEnvironment } = useEnvironment();
  
  // Register refresh callback
  useEffect(() => {
    const refreshCallback = (newEnv, newConfig) => {
      // Refresh component data
      loadData();
    };
    
    registerRefreshCallback(refreshCallback);
    return () => unregisterRefreshCallback(refreshCallback);
  }, []);
};
```

## User Experience

1. **Environment Selection**: Users can click the environment dropdown in the navbar
2. **Visual Feedback**: Current environment is clearly indicated with colors and icons
3. **Immediate Updates**: All API calls use new URLs immediately after switching
4. **Persistent Choice**: Environment selection persists across browser sessions
5. **Success Confirmation**: Toast notification confirms successful environment switch

## Technical Benefits

### For Developers
- **Easy Testing**: Switch between local and deployed environments instantly
- **Debug Capability**: Development environment includes enhanced logging
- **No Page Reloads**: Seamless environment switching without losing application state

### For QA/Testing
- **Environment Verification**: Quickly test against different deployment stages
- **URL Visibility**: Tooltip shows current API endpoints for verification
- **Staging Testing**: Dedicated staging environment for pre-production validation

### For Production Use
- **Fallback Options**: Can switch to staging if production issues occur
- **Deployment Verification**: Confirm which environment is being used
- **Multi-Environment Support**: Support for multiple production regions if needed

## Configuration Files

The system supports environment-specific configuration files:

- `.env.development` - Local development settings
- `.env.staging` - CloudHub staging settings  
- `.env.production` - CloudHub production settings

## Future Enhancements

1. **Region Selection**: Add support for multiple CloudHub regions
2. **Custom Environments**: Allow users to add custom environment configurations
3. **Environment Health**: Display real-time health status for each environment
4. **Performance Metrics**: Show response times and success rates per environment
5. **Authentication Per Environment**: Support different credentials per environment

## Troubleshooting

### Common Issues

1. **Environment Not Switching**: Check browser console for context provider errors
2. **API Calls Failing**: Verify environment URLs are correct and services are running
3. **Persistence Issues**: Clear localStorage if environment selection isn't saving

### Debug Commands

```javascript
// Check current environment in browser console
localStorage.getItem('selectedEnvironment')

// Manually trigger environment change
window.dispatchEvent(new CustomEvent('environment-changed', {
  detail: { from: 'production', to: 'development' }
}));
```

## Conclusion

The environment toggle functionality provides a seamless way for users to switch between different deployment environments while maintaining application state and providing immediate visual feedback. This enhances both the development experience and production flexibility of the Employee Onboarding system.
