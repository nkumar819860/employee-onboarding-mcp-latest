import React, { createContext, useContext, useState, useCallback } from 'react';

// Environment configurations
const ENVIRONMENTS = {
  development: {
    name: 'Development',
    baseURL: 'http://localhost:8081',
    employeeAPI: 'http://localhost:8082',
    assetAPI: 'http://localhost:8083',
    notificationAPI: 'http://localhost:8084',
    color: '#4CAF50'
  },
  staging: {
    name: 'Staging',
    baseURL: 'http://agent-broker-mcp-server-staging.us-e1.cloudhub.io',
    employeeAPI: 'http://employee-onboarding-mcp-server-staging.us-e1.cloudhub.io',
    assetAPI: 'http://asset-allocation-mcp-server-staging.us-e1.cloudhub.io',
    notificationAPI: 'http://employee-notification-service-staging.us-e1.cloudhub.io',
    color: '#FF9800'
  },
  production: {
    name: 'Production',
    baseURL: 'http://agent-broker-mcp-server.us-e1.cloudhub.io',
    employeeAPI: 'http://employee-onboarding-mcp-server.us-e1.cloudhub.io',
    assetAPI: 'http://asset-allocation-mcp-server.us-e1.cloudhub.io',
    notificationAPI: 'http://employee-notification-service.us-e1.cloudhub.io',
    color: '#f44336'
  }
};

const EnvironmentContext = createContext({
  currentEnvironment: 'production',
  environmentConfig: ENVIRONMENTS.production,
  environments: ENVIRONMENTS,
  switchEnvironment: () => {},
  refreshCallbacks: [],
  registerRefreshCallback: () => {},
  unregisterRefreshCallback: () => {}
});

export const useEnvironment = () => {
  const context = useContext(EnvironmentContext);
  if (!context) {
    throw new Error('useEnvironment must be used within an EnvironmentProvider');
  }
  return context;
};

export const EnvironmentProvider = ({ children }) => {
  // Get initial environment from localStorage or default to production
  const [currentEnvironment, setCurrentEnvironment] = useState(() => {
    const saved = localStorage.getItem('selectedEnvironment');
    return saved && ENVIRONMENTS[saved] ? saved : 'production';
  });

  // Track refresh callbacks from components
  const [refreshCallbacks, setRefreshCallbacks] = useState([]);

  const environmentConfig = ENVIRONMENTS[currentEnvironment];

  const switchEnvironment = useCallback((newEnvironment) => {
    if (!ENVIRONMENTS[newEnvironment]) {
      console.error(`Invalid environment: ${newEnvironment}`);
      return;
    }

    console.log(`Switching from ${currentEnvironment} to ${newEnvironment}`);
    const previousEnvironment = currentEnvironment;
    setCurrentEnvironment(newEnvironment);
    
    // Save to localStorage
    localStorage.setItem('selectedEnvironment', newEnvironment);

    // Notify all registered components to refresh their content
    refreshCallbacks.forEach((callback) => {
      try {
        callback(newEnvironment, ENVIRONMENTS[newEnvironment]);
      } catch (error) {
        console.error('Error executing refresh callback:', error);
      }
    });

    // Show notification to user
    const event = new CustomEvent('environment-changed', {
      detail: {
        from: previousEnvironment,
        to: newEnvironment,
        config: ENVIRONMENTS[newEnvironment],
        reason: previousEnvironment !== newEnvironment ? 'user-switch' : 'failover'
      }
    });
    window.dispatchEvent(event);
  }, [currentEnvironment, refreshCallbacks]);

  const registerRefreshCallback = useCallback((callback) => {
    if (typeof callback !== 'function') {
      console.error('Refresh callback must be a function');
      return;
    }

    setRefreshCallbacks(prev => {
      if (!prev.includes(callback)) {
        return [...prev, callback];
      }
      return prev;
    });
  }, []);

  const unregisterRefreshCallback = useCallback((callback) => {
    setRefreshCallbacks(prev => prev.filter(cb => cb !== callback));
  }, []);

  const value = {
    currentEnvironment,
    environmentConfig,
    environments: ENVIRONMENTS,
    switchEnvironment,
    refreshCallbacks,
    registerRefreshCallback,
    unregisterRefreshCallback
  };

  return (
    <EnvironmentContext.Provider value={value}>
      {children}
    </EnvironmentContext.Provider>
  );
};

export default EnvironmentContext;
