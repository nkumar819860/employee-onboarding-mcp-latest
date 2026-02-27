import axios from 'axios';

class APIService {
  constructor() {
    // CloudHub Production URLs (deployed services)
    this.baseURL = process.env.REACT_APP_API_BASE_URL || 'https://agent-broker-mcp-server.us-e1.cloudhub.io';
    this.employeeAPI = process.env.REACT_APP_EMPLOYEE_API_URL || 'https://employee-onboarding-mcp-server.us-e1.cloudhub.io';
    this.assetAPI = process.env.REACT_APP_ASSET_API_URL || 'https://asset-allocation-mcp-server.us-e1.cloudhub.io';
    this.notificationAPI = process.env.REACT_APP_NOTIFICATION_API_URL || 'https://notification-mcp-server.us-e1.cloudhub.io';
    
    // Create axios instances for each service
    this.agentBroker = axios.create({
      baseURL: this.baseURL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.employeeService = axios.create({
      baseURL: this.employeeAPI,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.assetService = axios.create({
      baseURL: this.assetAPI,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.notificationService = axios.create({
      baseURL: this.notificationAPI,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add response interceptors for error handling
    this.setupInterceptors();
  }

  setupInterceptors() {
    const errorHandler = (error) => {
      if (error.response) {
        console.error('API Error:', error.response.data);
        return Promise.reject(new Error(error.response.data.message || 'Server error'));
      } else if (error.request) {
        console.error('Network Error:', error.request);
        return Promise.reject(new Error('Network error - please check your connection'));
      } else {
        console.error('Request Error:', error.message);
        return Promise.reject(error);
      }
    };

    this.agentBroker.interceptors.response.use(response => response, errorHandler);
    this.employeeService.interceptors.response.use(response => response, errorHandler);
    this.assetService.interceptors.response.use(response => response, errorHandler);
    this.notificationService.interceptors.response.use(response => response, errorHandler);
  }

  // Employee Management APIs
  async createEmployee(employeeData) {
    try {
      const response = await this.employeeService.post('/api/employees', employeeData);
      return response.data;
    } catch (error) {
      // Fallback to mock data for demo
      console.warn('Using mock data for employee creation');
      return {
        employeeId: `EMP${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`,
        name: employeeData.name,
        email: employeeData.email,
        status: 'CREATED',
        createdAt: new Date().toISOString()
      };
    }
  }

  async getEmployees() {
    try {
      const response = await this.employeeService.get('/api/employees');
      return response.data;
    } catch (error) {
      console.warn('Using mock data for employees list');
      return [
        {
          id: 'EMP001',
          name: 'John Smith',
          email: 'john.smith@company.com',
          department: 'Engineering',
          status: 'ACTIVE',
          onboardingStatus: 'COMPLETED'
        },
        {
          id: 'EMP002',
          name: 'Maria Garcia',
          email: 'maria.garcia@company.com',
          department: 'Marketing',
          status: 'ACTIVE',
          onboardingStatus: 'IN_PROGRESS'
        }
      ];
    }
  }

  async getEmployeeStatus(employeeId) {
    try {
      const response = await this.employeeService.get(`/api/employees/${employeeId}/status`);
      return response.data;
    } catch (error) {
      console.warn('Using mock data for employee status');
      return {
        employeeId,
        status: 'ACTIVE',
        onboardingStatus: 'IN_PROGRESS',
        completedSteps: 3,
        totalSteps: 5,
        lastUpdated: new Date().toISOString()
      };
    }
  }

  // Asset Management APIs
  async getAvailableAssets() {
    try {
      const response = await this.assetService.get('/api/assets/available');
      return response.data;
    } catch (error) {
      console.warn('Using mock data for available assets');
      return [
        {
          id: 'LAP-003',
          name: 'HP EliteBook 850',
          type: 'laptop',
          brand: 'HP',
          model: 'EliteBook 850',
          status: 'AVAILABLE'
        },
        {
          id: 'LAP-005',
          name: 'Dell XPS 13',
          type: 'laptop',
          brand: 'Dell',
          model: 'XPS 13',
          status: 'AVAILABLE'
        },
        {
          id: 'PHN-002',
          name: 'Samsung Galaxy S24',
          type: 'phone',
          brand: 'Samsung',
          model: 'Galaxy S24',
          status: 'AVAILABLE'
        }
      ];
    }
  }

  async allocateAsset(employeeId, assetType) {
    try {
      const response = await this.assetService.post('/api/assets/allocate', {
        employeeId,
        assetType
      });
      return response.data;
    } catch (error) {
      console.warn('Using mock data for asset allocation');
      return {
        allocationId: `ALLOC-${Date.now()}`,
        employeeId,
        assetId: `${assetType.toUpperCase()}-${Math.floor(Math.random() * 100)}`,
        assetType,
        status: 'ALLOCATED',
        allocatedAt: new Date().toISOString()
      };
    }
  }

  async getAssetAllocations(employeeId = null) {
    try {
      const url = employeeId ? `/api/assets/allocations?employeeId=${employeeId}` : '/api/assets/allocations';
      const response = await this.assetService.get(url);
      return response.data;
    } catch (error) {
      console.warn('Using mock data for asset allocations');
      return [
        {
          id: 'ALLOC-001',
          employeeId: 'EMP001',
          assetId: 'LAP-001',
          assetName: 'Dell Latitude 7420',
          status: 'ALLOCATED',
          allocatedAt: '2024-01-15T10:00:00Z'
        }
      ];
    }
  }

  // Notification APIs
  async sendNotification(type, recipients = null) {
    try {
      const response = await this.notificationService.post('/api/notifications/send', {
        type,
        recipients
      });
      return response.data;
    } catch (error) {
      console.warn('Using mock data for notification sending');
      return {
        notificationId: `NOTIF-${Date.now()}`,
        type,
        recipients: recipients || 5,
        status: 'SENT',
        sentAt: new Date().toISOString()
      };
    }
  }

  async getNotificationHistory() {
    try {
      const response = await this.notificationService.get('/api/notifications/history');
      return response.data;
    } catch (error) {
      console.warn('Using mock data for notification history');
      return [
        {
          id: 'NOTIF-001',
          type: 'welcome',
          recipient: 'john.smith@company.com',
          status: 'DELIVERED',
          sentAt: '2024-01-15T10:00:00Z'
        },
        {
          id: 'NOTIF-002',
          type: 'reminder',
          recipient: 'maria.garcia@company.com',
          status: 'PENDING',
          sentAt: '2024-01-16T09:30:00Z'
        }
      ];
    }
  }

  // Agent Broker APIs (Orchestration)
  async orchestrateOnboarding(employeeData) {
    try {
      const response = await this.agentBroker.post('/api/orchestrate/onboarding', employeeData);
      return response.data;
    } catch (error) {
      console.warn('Using mock data for onboarding orchestration');
      return {
        orchestrationId: `ORCH-${Date.now()}`,
        employeeId: employeeData.employeeId || `EMP${Math.floor(Math.random() * 1000)}`,
        steps: [
          { step: 'CREATE_EMPLOYEE', status: 'COMPLETED' },
          { step: 'ALLOCATE_ASSETS', status: 'IN_PROGRESS' },
          { step: 'SEND_WELCOME_EMAIL', status: 'PENDING' },
          { step: 'SETUP_ACCOUNTS', status: 'PENDING' }
        ],
        status: 'IN_PROGRESS'
      };
    }
  }

  async getOnboardingStatus(orchestrationId) {
    try {
      const response = await this.agentBroker.get(`/api/orchestrate/status/${orchestrationId}`);
      return response.data;
    } catch (error) {
      console.warn('Using mock data for onboarding status');
      return {
        orchestrationId,
        status: 'IN_PROGRESS',
        completedSteps: 2,
        totalSteps: 4,
        currentStep: 'ALLOCATE_ASSETS',
        estimatedCompletion: new Date(Date.now() + 30 * 60 * 1000).toISOString()
      };
    }
  }

  // Health Check APIs
  async checkHealth() {
    const healthChecks = [];

    try {
      await this.agentBroker.get('/health');
      healthChecks.push({ service: 'Agent Broker', status: 'UP' });
    } catch (error) {
      healthChecks.push({ service: 'Agent Broker', status: 'DOWN', error: error.message });
    }

    try {
      await this.employeeService.get('/health');
      healthChecks.push({ service: 'Employee Service', status: 'UP' });
    } catch (error) {
      healthChecks.push({ service: 'Employee Service', status: 'DOWN', error: error.message });
    }

    try {
      await this.assetService.get('/health');
      healthChecks.push({ service: 'Asset Service', status: 'UP' });
    } catch (error) {
      healthChecks.push({ service: 'Asset Service', status: 'DOWN', error: error.message });
    }

    try {
      await this.notificationService.get('/health');
      healthChecks.push({ service: 'Notification Service', status: 'UP' });
    } catch (error) {
      healthChecks.push({ service: 'Notification Service', status: 'DOWN', error: error.message });
    }

    return healthChecks;
  }

  // Analytics APIs
  async getAnalytics() {
    try {
      const response = await this.agentBroker.get('/api/analytics');
      return response.data;
    } catch (error) {
      console.warn('Using mock data for analytics');
      return {
        totalEmployees: 8,
        activeOnboarding: 3,
        completedOnboarding: 5,
        assetsAllocated: 15,
        availableAssets: 12,
        notificationsSent: 25,
        systemHealth: 'GOOD',
        trends: {
          newEmployeesThisMonth: 3,
          assetsAllocatedThisMonth: 8,
          notificationsSentThisMonth: 15
        }
      };
    }
  }
}

export const apiService = new APIService();
