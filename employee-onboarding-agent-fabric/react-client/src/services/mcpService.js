/**
 * MCP Service - Interface for communicating with MuleSoft Agent Broker MCP Server
 * This service communicates with the MuleSoft Agent Broker which orchestrates 
 * all employee onboarding operations through proper MCP protocol
 */
import axios from 'axios';

class MCPService {
  constructor() {
    // The MuleSoft Agent Broker acts as our MCP gateway
    this.baseURL = process.env.REACT_APP_AGENT_BROKER_URL || 'http://localhost:8080';
    
    this.client = axios.create({
      baseURL: this.baseURL,
      timeout: 30000, // 30 second timeout for orchestration operations
      headers: {
        'Content-Type': 'application/json',
        'X-MCP-Client': 'React-Employee-Onboarding'
      },
    });

    // Add response interceptors for error handling
    this.setupInterceptors();
  }

  setupInterceptors() {
    this.client.interceptors.response.use(
      response => response,
      error => {
        if (error.response) {
          console.error('MCP Service Error:', error.response.data);
          return Promise.reject(new Error(error.response.data.message || 'MCP server error'));
        } else if (error.request) {
          console.error('MCP Network Error:', error.request);
          return Promise.reject(new Error('MCP server unreachable - please check if services are running'));
        } else {
          console.error('MCP Request Error:', error.message);
          return Promise.reject(error);
        }
      }
    );
  }

  /**
   * Orchestrate complete employee onboarding using MCP Agent Broker
   * This is the main MCP tool that handles the entire onboarding process
   */
  async orchestrateEmployeeOnboarding(employeeData) {
    try {
      console.log('🚀 Initiating MCP-orchestrated employee onboarding for:', employeeData.email);
      
      const response = await this.client.post('/mcp/tools/orchestrate-employee-onboarding', {
        firstName: employeeData.firstName,
        lastName: employeeData.lastName,
        email: employeeData.email,
        phone: employeeData.phone,
        department: employeeData.department,
        position: employeeData.position,
        startDate: employeeData.startDate,
        salary: employeeData.salary,
        manager: employeeData.manager,
        managerEmail: employeeData.managerEmail,
        companyName: employeeData.companyName || 'Our Company',
        assets: employeeData.assets || ['laptop', 'phone', 'id-card']
      });

      console.log('✅ MCP orchestration completed successfully:', response.data);
      return {
        success: true,
        data: response.data,
        message: 'Employee onboarding orchestration completed successfully via MCP',
        mcpPowered: true
      };
    } catch (error) {
      console.error('❌ MCP orchestration failed:', error.message);
      return {
        success: false,
        error: error.message,
        message: 'MCP orchestration failed - check if MuleSoft services are running',
        mcpPowered: true
      };
    }
  }

  /**
   * Get employee onboarding status using MCP
   */
  async getOnboardingStatus(employeeId = null, email = null) {
    try {
      const params = {};
      if (employeeId) params.employeeId = employeeId;
      if (email) params.email = email;

      if (!employeeId && !email) {
        throw new Error('Either employeeId or email must be provided');
      }

      console.log('📊 Retrieving onboarding status via MCP for:', params);

      const response = await this.client.get('/mcp/tools/get-onboarding-status', { params });

      return {
        success: true,
        data: response.data,
        message: 'Onboarding status retrieved successfully via MCP',
        mcpPowered: true
      };
    } catch (error) {
      console.error('❌ MCP status retrieval failed:', error.message);
      return {
        success: false,
        error: error.message,
        message: 'Failed to retrieve onboarding status via MCP',
        mcpPowered: true
      };
    }
  }

  /**
   * Retry a failed onboarding step using MCP
   */
  async retryFailedStep(employeeId, step) {
    try {
      console.log('🔄 Retrying failed step via MCP:', { employeeId, step });

      const response = await this.client.post('/mcp/tools/retry-failed-step', {
        employeeId,
        step
      });

      return {
        success: true,
        data: response.data,
        message: `Step '${step}' retry initiated successfully via MCP`,
        mcpPowered: true
      };
    } catch (error) {
      console.error('❌ MCP step retry failed:', error.message);
      return {
        success: false,
        error: error.message,
        message: 'Failed to retry step via MCP',
        mcpPowered: true
      };
    }
  }

  /**
   * Check system health using MCP
   */
  async checkSystemHealth() {
    try {
      console.log('🏥 Checking system health via MCP...');

      // First check if the MCP broker itself is healthy
      const brokerHealth = await this.client.get('/health');
      
      // Then get comprehensive health check through MCP
      // Note: We could use the MCP tool for this, but for now using the direct health endpoint
      const systemHealthChecks = await Promise.allSettled([
        this.client.get('/health'), // Agent Broker
        axios.get('http://localhost:8081/health'), // Employee Service  
        axios.get('http://localhost:8082/health'), // Asset Service
        axios.get('http://localhost:8083/health'), // Notification Service
      ]);

      const serviceNames = ['Agent Broker (MCP)', 'Employee Service', 'Asset Service', 'Notification Service'];
      const healthReport = systemHealthChecks.map((result, index) => ({
        service: serviceNames[index],
        status: result.status === 'fulfilled' ? 'UP' : 'DOWN',
        details: result.status === 'fulfilled' 
          ? result.value.data 
          : { error: result.reason?.message || 'Connection failed' },
        mcpManaged: index === 0 // First service is MCP-managed
      }));

      const overallHealthy = systemHealthChecks.every(check => check.status === 'fulfilled');

      return {
        success: true,
        data: {
          overallStatus: overallHealthy ? 'HEALTHY' : 'DEGRADED',
          services: healthReport,
          timestamp: new Date().toISOString(),
          mcpBrokerActive: brokerHealth.status === 200
        },
        message: `System health check completed - Status: ${overallHealthy ? 'HEALTHY' : 'DEGRADED'}`,
        mcpPowered: true
      };
    } catch (error) {
      console.error('❌ MCP health check failed:', error.message);
      return {
        success: false,
        error: error.message,
        message: 'System health check failed - MCP broker may be down',
        mcpPowered: true
      };
    }
  }

  /**
   * Get MCP server information
   */
  async getMCPServerInfo() {
    try {
      const response = await this.client.get('/mcp/info');
      return {
        success: true,
        data: response.data,
        message: 'MCP server information retrieved successfully',
        mcpPowered: true
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        message: 'Failed to retrieve MCP server information',
        mcpPowered: true
      };
    }
  }

  /**
   * Helper method to create employee data structure for MCP
   */
  createEmployeeDataForMCP(formData) {
    return {
      firstName: formData.firstName || formData.name?.split(' ')[0] || '',
      lastName: formData.lastName || formData.name?.split(' ').slice(1).join(' ') || '',
      email: formData.email,
      phone: formData.phone,
      department: formData.department,
      position: formData.position || formData.role,
      startDate: formData.startDate || formData.hireDate,
      salary: formData.salary ? Number(formData.salary) : undefined,
      manager: formData.manager || formData.managerName,
      managerEmail: formData.managerEmail,
      companyName: formData.companyName || 'Our Company',
      assets: formData.assets || this.getDefaultAssets(formData.department, formData.position)
    };
  }

  /**
   * Helper method to determine default assets based on department and position
   */
  getDefaultAssets(department, position) {
    const baseAssets = ['laptop', 'id-card'];
    
    if (department === 'Engineering' || department === 'IT') {
      return [...baseAssets, 'phone', 'monitor', 'keyboard-mouse'];
    } else if (department === 'Sales' || department === 'Marketing') {
      return [...baseAssets, 'phone', 'tablet'];
    } else if (position?.toLowerCase().includes('manager')) {
      return [...baseAssets, 'phone', 'tablet'];
    }
    
    return baseAssets;
  }

  /**
   * Legacy API compatibility methods
   * These methods maintain compatibility with existing React components
   * while leveraging MCP orchestration behind the scenes
   */

  async createEmployee(employeeData) {
    // Convert to MCP orchestration
    const mcpData = this.createEmployeeDataForMCP(employeeData);
    const result = await this.orchestrateEmployeeOnboarding(mcpData);
    
    if (result.success) {
      return {
        employeeId: result.data.employeeId,
        name: `${mcpData.firstName} ${mcpData.lastName}`,
        email: mcpData.email,
        status: 'CREATED',
        createdAt: new Date().toISOString(),
        mcpOrchestrated: true
      };
    } else {
      throw new Error(result.error);
    }
  }

  async getEmployees() {
    // For now, return mock data but in a real implementation,
    // this would query the employee service through MCP
    console.log('📋 Getting employees list (mock data - could be MCP-powered)');
    return [
      {
        id: 'EMP001',
        name: 'John Smith',
        email: 'john.smith@company.com',
        department: 'Engineering',
        status: 'ACTIVE',
        onboardingStatus: 'COMPLETED',
        mcpManaged: true
      },
      {
        id: 'EMP002', 
        name: 'Maria Garcia',
        email: 'maria.garcia@company.com',
        department: 'Marketing',
        status: 'ACTIVE',
        onboardingStatus: 'IN_PROGRESS',
        mcpManaged: true
      }
    ];
  }

  async checkHealth() {
    const healthResult = await this.checkSystemHealth();
    return healthResult.success ? healthResult.data.services : [];
  }
}

export const mcpService = new MCPService();
export default mcpService;
