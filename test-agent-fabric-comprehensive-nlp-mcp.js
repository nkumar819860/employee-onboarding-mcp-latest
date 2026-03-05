#!/usr/bin/env node

/**
 * Comprehensive Test Script for Agent Fabric MCP with NLP Integration
 * Tests multiple API calls, MCP orchestration, and NLP functionality
 * Supports both local and CloudHub deployments
 */

const axios = require('axios');
const fs = require('fs').promises;
const path = require('path');

// Configuration
const CONFIG = {
    // Local MCP Server Endpoints
    MCP_ENDPOINTS: {
        AGENT_BROKER: process.env.AGENT_BROKER_URL || 'http://localhost:8081',
        EMPLOYEE_ONBOARDING: process.env.EMPLOYEE_ONBOARDING_URL || 'http://localhost:8082', 
        ASSET_ALLOCATION: process.env.ASSET_ALLOCATION_URL || 'http://localhost:8083',
        EMAIL_NOTIFICATION: process.env.EMAIL_NOTIFICATION_URL || 'http://localhost:8084'
    },
    
    // CloudHub URLs (update with your actual CloudHub app URLs)
    CLOUDHUB_ENDPOINTS: {
        AGENT_BROKER: 'https://onboardingbroker.us-e1.cloudhub.io',
        EMPLOYEE_ONBOARDING: 'https://employeeonboardingmcp.us-e1.cloudhub.io',
        ASSET_ALLOCATION: 'https://assetallocationserver.us-e1.cloudhub.io',
        EMAIL_NOTIFICATION: 'https://emailnotificationmcp.us-e1.cloudhub.io'
    },
    
    // Test configurations
    TIMEOUT: 30000,
    MAX_RETRIES: 3,
    DELAY_BETWEEN_TESTS: 1000,
    USE_CLOUDHUB: process.env.USE_CLOUDHUB === 'true' || false,
    
    // Test data
    TEST_EMPLOYEE: {
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@testcompany.com',
        phone: '+1-555-123-4567',
        department: 'Engineering',
        position: 'Senior Software Engineer',
        startDate: '2024-01-15',
        salary: 95000,
        manager: 'Jane Smith',
        managerEmail: 'jane.smith@testcompany.com',
        companyName: 'Test Company Inc.',
        assets: ['laptop', 'phone', 'id-card']
    },
    
    // NLP Test Phrases with expected intents
    NLP_TEST_PHRASES: [
        {
            text: "Create a new employee John Smith with email john.smith@company.com",
            expectedIntent: "CREATE_EMPLOYEE",
            expectedEntities: ["PERSON", "EMAIL"]
        },
        {
            text: "Allocate laptop to employee EMP001",
            expectedIntent: "ALLOCATE_ASSET",
            expectedEntities: ["EMPLOYEE_ID"]
        },
        {
            text: "Show me all available assets",
            expectedIntent: "GET_ASSETS",
            expectedEntities: []
        },
        {
            text: "Check the onboarding status of employee EMP001",
            expectedIntent: "GET_EMPLOYEE_STATUS",
            expectedEntities: ["EMPLOYEE_ID"]
        },
        {
            text: "Send welcome notification to john.doe@company.com",
            expectedIntent: "SEND_NOTIFICATION",
            expectedEntities: ["EMAIL"]
        },
        {
            text: "List all employees in the system",
            expectedIntent: "GET_EMPLOYEES",
            expectedEntities: []
        },
        {
            text: "What assets are available for allocation?",
            expectedIntent: "GET_ASSETS",
            expectedEntities: []
        },
        {
            text: "I need to onboard a new hire named Sarah Johnson",
            expectedIntent: "CREATE_EMPLOYEE",
            expectedEntities: ["PERSON"]
        },
        {
            text: "Please assign a phone to the new employee",
            expectedIntent: "ALLOCATE_ASSET",
            expectedEntities: []
        },
        {
            text: "Send reminder email to all pending employees",
            expectedIntent: "SEND_NOTIFICATION",
            expectedEntities: []
        }
    ]
};

// Test Results Tracking
let testResults = {
    total: 0,
    passed: 0,
    failed: 0,
    details: [],
    startTime: new Date(),
    endTime: null
};

// Utility Functions
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

const getEndpoints = () => {
    return CONFIG.USE_CLOUDHUB ? CONFIG.CLOUDHUB_ENDPOINTS : CONFIG.MCP_ENDPOINTS;
};

const logTest = (testName, status, message, details = null) => {
    const timestamp = new Date().toISOString();
    const result = {
        timestamp,
        testName,
        status,
        message,
        details
    };
    
    testResults.total++;
    if (status === 'PASS') {
        testResults.passed++;
        console.log(`✅ ${testName}: ${message}`);
    } else {
        testResults.failed++;
        console.log(`❌ ${testName}: ${message}`);
        if (details) console.log(`   Details: ${JSON.stringify(details, null, 2)}`);
    }
    
    testResults.details.push(result);
};

const makeHttpRequest = async (method, url, data = null, headers = {}) => {
    const config = {
        method,
        url,
        timeout: CONFIG.TIMEOUT,
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...headers
        }
    };
    
    if (data) {
        config.data = data;
    }
    
    let lastError;
    for (let attempt = 1; attempt <= CONFIG.MAX_RETRIES; attempt++) {
        try {
            const response = await axios(config);
            return response;
        } catch (error) {
            lastError = error;
            if (attempt < CONFIG.MAX_RETRIES) {
                console.log(`Attempt ${attempt} failed for ${url}, retrying...`);
                await sleep(1000 * attempt);
            }
        }
    }
    throw lastError;
};

// NLP Service Implementation (Enhanced)
class NLPProcessor {
    constructor() {
        this.intentPatterns = {
            CREATE_EMPLOYEE: {
                keywords: ['create', 'add', 'new', 'register', 'onboard', 'hire', 'employee', 'staff', 'worker'],
                patterns: [
                    /create\s+(new\s+)?employee/i,
                    /add\s+(new\s+)?employee/i,
                    /register\s+(new\s+)?employee/i,
                    /onboard.*employee/i,
                    /hire.*employee/i,
                    /new\s+hire/i
                ]
            },
            ALLOCATE_ASSET: {
                keywords: ['allocate', 'assign', 'give', 'provide', 'laptop', 'phone', 'asset', 'equipment'],
                patterns: [
                    /allocate\s+\w+\s+to/i,
                    /assign\s+\w+\s+to/i,
                    /give\s+\w+\s+to/i,
                    /provide\s+\w+\s+(to|for)/i
                ]
            },
            GET_ASSETS: {
                keywords: ['show', 'list', 'get', 'available', 'assets', 'equipment', 'inventory'],
                patterns: [
                    /show.*available.*assets/i,
                    /list.*assets/i,
                    /what.*assets.*available/i,
                    /available.*assets/i
                ]
            },
            GET_EMPLOYEE_STATUS: {
                keywords: ['status', 'progress', 'check', 'employee', 'onboarding'],
                patterns: [
                    /employee.*status/i,
                    /check.*status/i,
                    /onboarding.*status/i,
                    /progress.*of/i
                ]
            },
            SEND_NOTIFICATION: {
                keywords: ['send', 'notify', 'notification', 'email', 'message', 'alert', 'reminder'],
                patterns: [
                    /send.*notification/i,
                    /send.*email/i,
                    /notify/i,
                    /send.*message/i,
                    /reminder.*email/i
                ]
            },
            GET_EMPLOYEES: {
                keywords: ['employees', 'staff', 'people', 'workers', 'list'],
                patterns: [
                    /show.*employees/i,
                    /list.*employees/i,
                    /get.*employees/i,
                    /all.*employees/i
                ]
            }
        };

        this.entityPatterns = {
            PERSON: {
                patterns: [/\b[A-Z][a-z]+\s+[A-Z][a-z]+\b/g]
            },
            EMPLOYEE_ID: {
                patterns: [/EMP\d{3,}/gi, /employee\s+\d+/gi, /\b\d{3,}\b/g]
            },
            EMAIL: {
                patterns: [/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g]
            },
            ASSET_TYPE: {
                patterns: [/laptop/gi, /computer/gi, /phone/gi, /mobile/gi, /tablet/gi, /monitor/gi]
            }
        };
    }

    processText(text) {
        const tokens = this.tokenize(text);
        let bestIntent = 'UNKNOWN';
        let highestScore = 0;

        // Intent classification
        Object.keys(this.intentPatterns).forEach(intent => {
            const intentData = this.intentPatterns[intent];
            let score = 0;

            // Check patterns (higher weight)
            intentData.patterns.forEach(pattern => {
                if (pattern.test(text)) score += 3;
            });

            // Check keywords (lower weight)
            intentData.keywords.forEach(keyword => {
                if (tokens.includes(keyword.toLowerCase()) || text.toLowerCase().includes(keyword.toLowerCase())) {
                    score += 1;
                }
            });

            if (score > highestScore) {
                highestScore = score;
                bestIntent = intent;
            }
        });

        // Entity extraction
        const entities = this.extractEntities(text);

        // Confidence calculation
        const confidence = this.calculateConfidence(bestIntent, highestScore, entities, text);

        return {
            originalText: text,
            intent: bestIntent,
            confidence,
            entities,
            tokens,
            score: highestScore
        };
    }

    tokenize(text) {
        return text.toLowerCase()
            .replace(/[^\w\s@.-]/g, ' ')
            .split(/\s+/)
            .filter(token => token.length > 0);
    }

    extractEntities(text) {
        const entities = [];

        Object.keys(this.entityPatterns).forEach(entityType => {
            const patterns = this.entityPatterns[entityType].patterns;
            patterns.forEach(pattern => {
                const matches = text.match(pattern);
                if (matches) {
                    matches.forEach(match => {
                        entities.push({
                            text: match.trim(),
                            type: entityType,
                            confidence: 0.8
                        });
                    });
                }
            });
        });

        // Remove duplicates
        const uniqueEntities = entities.filter((entity, index, self) =>
            index === self.findIndex(e => e.text.toLowerCase() === entity.text.toLowerCase() && e.type === entity.type)
        );

        return uniqueEntities.sort((a, b) => b.confidence - a.confidence);
    }

    calculateConfidence(intent, score, entities, text) {
        if (intent === 'UNKNOWN') return 0;
        
        let confidence = Math.min(score / 5, 0.8); // Base confidence from pattern matching
        
        // Boost confidence if relevant entities found
        if (entities.length > 0) {
            confidence += Math.min(entities.length * 0.1, 0.2);
        }
        
        // Text quality factor
        if (text.length > 10 && text.length < 200) {
            confidence += 0.05;
        }
        
        return Math.min(confidence, 1.0);
    }
}

// Test Suite Classes
class HealthCheckTests {
    static async runAll() {
        console.log('\n🔍 Running Health Check Tests...');
        const endpoints = getEndpoints();
        const deploymentType = CONFIG.USE_CLOUDHUB ? 'CloudHub' : 'Local';
        console.log(`Testing ${deploymentType} endpoints...`);
        
        await this.testServiceHealth(endpoints.AGENT_BROKER, 'Agent Broker');
        await this.testServiceHealth(endpoints.EMPLOYEE_ONBOARDING, 'Employee Onboarding');
        await this.testServiceHealth(endpoints.ASSET_ALLOCATION, 'Asset Allocation');
        await this.testServiceHealth(endpoints.EMAIL_NOTIFICATION, 'Email Notification');
    }
    
    static async testServiceHealth(baseUrl, serviceName) {
        try {
            // Try multiple health endpoints
            const healthEndpoints = ['/health', '/actuator/health', '/mcp/health', '/api/health', '/'];
            let healthResponse = null;
            
            for (const endpoint of healthEndpoints) {
                try {
                    healthResponse = await makeHttpRequest('GET', `${baseUrl}${endpoint}`);
                    if (healthResponse && healthResponse.status === 200) {
                        break;
                    }
                } catch (error) {
                    // Continue to next endpoint
                }
            }
            
            if (healthResponse && healthResponse.status === 200) {
                logTest(`${serviceName} Health Check`, 'PASS', `Service is responsive (${healthResponse.status})`);
            } else {
                logTest(`${serviceName} Health Check`, 'FAIL', 'No responsive health endpoints found');
            }
        } catch (error) {
            logTest(`${serviceName} Health Check`, 'FAIL', 'Health check failed', error.message);
        }
    }
}

class MCPOrchestrationTests {
    static async runAll() {
        console.log('\n🎯 Running MCP Orchestration Tests...');
        const endpoints = getEndpoints();
        
        await this.testCompleteOnboardingOrchestration(endpoints);
        await this.testIndividualMCPEndpoints(endpoints);
        await this.testAsyncOperations(endpoints);
        await this.testErrorHandling(endpoints);
        await this.testDataFlow(endpoints);
    }
    
    static async testCompleteOnboardingOrchestration(endpoints) {
        try {
            const mcpPayload = CONFIG.TEST_EMPLOYEE;
            
            // Try different orchestration endpoints
            const orchestrationEndpoints = [
                '/mcp/tools/orchestrate-employee-onboarding',
                '/api/orchestrate-onboarding',
                '/orchestrate-employee-onboarding',
                '/api/onboard',
                '/onboard'
            ];
            
            let response = null;
            let usedEndpoint = null;
            
            for (const endpoint of orchestrationEndpoints) {
                try {
                    response = await makeHttpRequest('POST', `${endpoints.AGENT_BROKER}${endpoint}`, mcpPayload);
                    if (response && (response.status === 200 || response.status === 201)) {
                        usedEndpoint = endpoint;
                        break;
                    }
                } catch (error) {
                    // Continue to next endpoint
                }
            }
            
            if (response && (response.status === 200 || response.status === 201)) {
                const responseData = response.data;
                CONFIG.TEST_EMPLOYEE.employeeId = responseData.employeeId || responseData.id || 'EMP001';
                
                logTest('Complete MCP Orchestration', 'PASS', 
                    `Successfully orchestrated onboarding via ${usedEndpoint}`, {
                    employeeId: CONFIG.TEST_EMPLOYEE.employeeId,
                    status: responseData.status,
                    endpoint: usedEndpoint
                });
                
                // Verify status after delay
                await sleep(3000);
                await this.verifyOnboardingStatus(endpoints.AGENT_BROKER);
            } else {
                logTest('Complete MCP Orchestration', 'FAIL', 'No orchestration endpoints responded successfully');
            }
        } catch (error) {
            logTest('Complete MCP Orchestration', 'FAIL', 'Orchestration test failed', error.message);
        }
    }
    
    static async verifyOnboardingStatus(brokerUrl) {
        if (!CONFIG.TEST_EMPLOYEE.employeeId) return;
        
        try {
            const statusEndpoints = [
                `/mcp/tools/get-onboarding-status?employeeId=${CONFIG.TEST_EMPLOYEE.employeeId}`,
                `/api/onboarding-status/${CONFIG.TEST_EMPLOYEE.employeeId}`,
                `/status/${CONFIG.TEST_EMPLOYEE.employeeId}`,
                `/api/employee/${CONFIG.TEST_EMPLOYEE.employeeId}/status`
            ];
            
            let response = null;
            for (const endpoint of statusEndpoints) {
                try {
                    response = await makeHttpRequest('GET', `${brokerUrl}${endpoint}`);
                    if (response && response.status === 200) break;
                } catch (error) {
                    // Continue
                }
            }
            
            if (response && response.status === 200) {
                logTest('Onboarding Status Verification', 'PASS', 
                    'Status retrieved successfully', response.data);
            } else {
                logTest('Onboarding Status Verification', 'FAIL', 'Could not retrieve onboarding status');
            }
        } catch (error) {
            logTest('Onboarding Status Verification', 'FAIL', 'Status verification failed', error.message);
        }
    }
    
    static async testIndividualMCPEndpoints(endpoints) {
        const tests = [
            {
                name: 'Employee Creation',
                url: endpoints.EMPLOYEE_ONBOARDING,
                endpoints: ['/mcp/tools/create-employee', '/api/employee', '/employees'],
                method: 'POST',
                payload: {
                    firstName: 'Test',
                    lastName: 'User',
                    email: 'test.user@company.com',
                    department: 'QA'
                }
            },
            {
                name: 'Asset Listing',
                url: endpoints.ASSET_ALLOCATION,
                endpoints: ['/mcp/tools/get-available-assets', '/api/assets', '/assets'],
                method: 'GET',
                payload: null
            },
            {
                name: 'Employee Listing',
                url: endpoints.EMPLOYEE_ONBOARDING,
                endpoints: ['/mcp/tools/get-employees', '/api/employees', '/employees'],
                method: 'GET',
                payload: null
            }
        ];
        
        for (const test of tests) {
            let success = false;
            for (const endpoint of test.endpoints) {
                try {
                    const response = await makeHttpRequest(
                        test.method, 
                        `${test.url}${endpoint}`, 
                        test.payload
                    );
                    if (response && (response.status === 200 || response.status === 201)) {
                        logTest(`Individual MCP - ${test.name}`, 'PASS', 
                            `${test.method} ${endpoint} responded successfully`);
                        success = true;
                        break;
                    }
                } catch (error) {
                    // Continue to next endpoint
                }
            }
            if (!success) {
                logTest(`Individual MCP - ${test.name}`, 'FAIL', 
                    'No endpoints responded successfully');
            }
        }
    }
    
    static async testAsyncOperations(endpoints) {
        try {
            const operations = [
                this.callAssetService(endpoints.ASSET_ALLOCATION),
                this.callEmployeeService(endpoints.EMPLOYEE_ONBOARDING),
                this.callNotificationService(endpoints.EMAIL_NOTIFICATION)
            ];
            
            const results = await Promise.allSettled(operations);
            const successCount = results.filter(r => r.status === 'fulfilled').length;
            
            if (successCount >= 1) {
                logTest('Async Operations', 'PASS', 
                    `${successCount}/3 async operations completed successfully`);
            } else {
                logTest('Async Operations', 'FAIL', 
                    'No async operations completed successfully');
            }
        } catch (error) {
            logTest('Async Operations', 'FAIL', 'Async operations test failed', error.message);
        }
    }
    
    static async callAssetService(url) {
        const endpoints = ['/api/assets', '/assets', '/mcp/tools/get-available-assets'];
        for (const endpoint of endpoints) {
            try {
                const response = await makeHttpRequest('GET', `${url}${endpoint}`);
                if (response.status === 200) return { service: 'asset', success: true };
            } catch (error) { /* continue */ }
        }
        throw new Error('Asset service not available');
    }
    
    static async callEmployeeService(url) {
        const endpoints = ['/api/employees', '/employees', '/mcp/tools/get-employees'];
        for (const endpoint of endpoints) {
            try {
                const response = await makeHttpRequest('GET', `${url}${endpoint}`);
                if (response.status === 200) return { service: 'employee', success: true };
            } catch (error) { /* continue */ }
        }
        throw new Error('Employee service not available');
    }
    
    static async callNotificationService(url) {
        const endpoints = ['/api/health', '/health', '/'];
        for (const endpoint of endpoints) {
            try {
                const response = await makeHttpRequest('GET', `${url}${endpoint}`);
                if (response.status === 200) return { service: 'notification', success: true };
            } catch (error) { /* continue */ }
        }
        throw new Error('Notification service not available');
    }
    
    static async testErrorHandling(endpoints) {
        try {
            // Test with invalid data
            const invalidPayload = {
                firstName: '',
                lastName: '',
                email: 'invalid-email',
                department: null
            };
            
            try {
                const response = await makeHttpRequest(
                    'POST',
                    `${endpoints.AGENT_BROKER}/mcp/tools/orchestrate-employee-onboarding`,
                    invalidPayload
                );
                
                if (response.status >= 400) {
                    logTest('Error Handling', 'PASS', 'System correctly returned error for invalid data');
                } else {
                    logTest('Error Handling', 'FAIL', 'System accepted invalid data');
                }
            } catch (error) {
                if (error.response && error.response.status >= 400) {
                    logTest('Error Handling', 'PASS', 'System correctly rejected invalid data');
                } else {
                    logTest('Error Handling', 'FAIL', 'Unexpected error handling', error.message);
                }
            }
        } catch (error) {
            logTest('Error Handling', 'FAIL', 'Error handling test failed', error.message);
        }
    }
    
    static async testDataFlow(endpoints) {
        try {
            // Test data consistency across services
            const employeeData = {
                firstName: 'DataFlow',
                lastName: 'Test',
                email: 'dataflow.test@company.com',
                department: 'Testing'
            };
            
            // Create employee
            let employeeId = null;
            try {
                const createResponse = await makeHttpRequest(
                    'POST',
                    `${endpoints.EMPLOYEE_ONBOARDING}/api/employee`,
                    employeeData
                );
                employeeId = createResponse.data?.employeeId || createResponse.data?.id;
            } catch (error) {
                // Ignore if creation fails
            }
            
            // Try to retrieve employee
            if (employeeId) {
                try {
                    const getResponse = await makeHttpRequest(
                        'GET',
                        `${endpoints.EMPLOYEE_ONBOARDING}/api/employee/${employeeId}`
                    );
                    if (getResponse.status === 200) {
                        logTest('Data Flow Consistency', 'PASS', 'Created employee can be retrieved');
                    } else {
                        logTest('Data Flow Consistency', 'FAIL', 'Created employee cannot be retrieved');
                    }
                } catch (error) {
                    logTest('Data Flow Consistency', 'FAIL', 'Employee retrieval failed');
                }
            } else {
                logTest('Data Flow Consistency', 'SKIP', 'Could not create employee for data flow test');
            }
        } catch (error) {
            logTest('Data Flow Consistency', 'FAIL', 'Data flow test failed', error.message);
        }
    }
}

class NLPIntegrationTests {
    static async runAll() {
        console.log('\n🧠 Running NLP Integration Tests...');
        
        const nlpProcessor = new NLPProcessor();
        
        await this.testNLPIntentClassification(nlpProcessor);
        await this.testNLPEntityExtraction(nlpProcessor);
        await this.testNLPToMCPWorkflow(nlpProcessor);
        await this.testConversationalNLP(nlpProcessor);
        await this.testNLPConfidenceScoring(nlpProcessor);
    }
    
    static async testNLPIntentClassification(nlpProcessor) {
        try {
            let successCount = 0;
            const results = [];
            
            for (const testPhrase of CONFIG.NLP_TEST_PHRASES) {
                const result = nlpProcessor.processText(testPhrase.text);
                const isCorrect = result.intent === testPhrase.expectedIntent && result.confidence > 0.3;
                
                results.push({
                    text: testPhrase.text,
                    expected: testPhrase.expectedIntent,
                    actual: result.intent,
                    confidence: result.confidence,
                    correct: isCorrect
                });
                
                if (isCorrect) {
                    successCount++;
                    console.log(`    ✓ "${testPhrase.text}" → ${result.intent} (${result.confidence.toFixed(2)})`);
                } else {
                    console.log(`    ✗ "${testPhrase.text}" → Expected: ${testPhrase.expectedIntent}, Got: ${result.intent} (${result.confidence.toFixed(2)})`);
                }
            }
            
            const accuracy = successCount / CONFIG.NLP_TEST_PHRASES.length;
            if (accuracy >= 0.7) {
                logTest('NLP Intent Classification', 'PASS', 
                    `${successCount}/${CONFIG.NLP_TEST_PHRASES.length} intents classified correctly (${(accuracy * 100).toFixed(1)}% accuracy)`, results);
            } else {
                logTest('NLP Intent Classification', 'FAIL', 
                    `Only ${successCount}/${CONFIG.NLP_TEST_PHRASES.length} intents classified correctly (${(accuracy * 100).toFixed(1)}% accuracy)`, results);
            }
        } catch (error) {
            logTest('NLP Intent Classification', 'FAIL', 'Intent classification test failed', error.message);
        }
    }
    
    static async testNLPEntityExtraction(nlpProcessor) {
        try {
            const testCases = [
                {
                    text: "Create employee John Smith with email john.smith@company.com and assign laptop to EMP001",
                    expectedTypes: ['PERSON', 'EMAIL', 'EMPLOYEE_ID']
                },
                {
                    text: "Send notification to sarah.johnson@example.com about her laptop allocation",
                    expectedTypes: ['EMAIL']
                },
                {
                    text: "Check status of employee EMP123 and provide phone details",
                    expectedTypes: ['EMPLOYEE_ID']
                }
            ];
            
            let successCount = 0;
            const results = [];
            
            for (const testCase of testCases) {
                const result = nlpProcessor.processText(testCase.text);
                const foundTypes = result.entities.map(e => e.type);
                const matchedTypes = testCase.expectedTypes.filter(type => foundTypes.includes(type));
                const accuracy = matchedTypes.length / testCase.expectedTypes.length;
                
                results.push({
                    text: testCase.text,
                    expectedTypes: testCase.expectedTypes,
                    foundTypes,
                    matchedTypes,
                    accuracy,
                    entities: result.entities
                });
                
                if (accuracy >= 0.6) {
                    successCount++;
                    console.log(`    ✓ "${testCase.text}" → Found: ${foundTypes.join(', ')}`);
                } else {
                    console.log(`    ✗ "${testCase.text}" → Expected: ${testCase.expectedTypes.join(', ')}, Found: ${foundTypes.join(', ')}`);
                }
            }
            
            if (successCount >= testCases.length * 0.7) {
                logTest('NLP Entity Extraction', 'PASS', 
                    `${successCount}/${testCases.length} entity extraction tests passed`, results);
            } else {
                logTest('NLP Entity Extraction', 'FAIL', 
                    `Only ${successCount}/${testCases.length} entity extraction tests passed`, results);
            }
        } catch (error) {
            logTest('NLP Entity Extraction', 'FAIL', 'Entity extraction test failed', error.message);
        }
    }
    
    static async testNLPToMCPWorkflow(nlpProcessor) {
        try {
            const nlpPhrase = "Create a new employee Mike Wilson with email mike.wilson@company.com";
            const nlpResult = nlpProcessor.processText(nlpPhrase);
            
            if (nlpResult.intent === 'CREATE_EMPLOYEE') {
                const emailEntity = nlpResult.entities.find(e => e.type === 'EMAIL');
                const personEntity = nlpResult.entities.find(e => e.type === 'PERSON');
                
                if (emailEntity && personEntity) {
                    const [firstName, lastName] = personEntity.text.split(' ');
                    const endpoints = getEndpoints();
                    
                    const mcpPayload = {
                        firstName,
                        lastName,
                        email: emailEntity.text,
                        department: 'Engineering',
                        position: 'Software Engineer'
                    };
                    
                    // Try to create employee via MCP
                    const mcpEndpoints = [
                        '/mcp/tools/create-employee',
                        '/api/employee',
                        '/employees'
                    ];
                    
                    let mcpSuccess = false;
                    for (const endpoint of mcpEndpoints) {
                        try {
                            const response = await makeHttpRequest(
                                'POST',
                                `${endpoints.EMPLOYEE_ONBOARDING}${endpoint}`,
                                mcpPayload
                            );
                            if (response && (response.status === 200 || response.status === 201)) {
                                mcpSuccess = true;
                                logTest('NLP to MCP Workflow', 'PASS', 
                                    `Successfully converted NLP intent "${nlpResult.intent}" to MCP action`);
                                break;
                            }
                        } catch (error) {
                            // Continue to next endpoint
                        }
                    }
                    
                    if (!mcpSuccess) {
                        logTest('NLP to MCP Workflow', 'FAIL', 'MCP action failed after NLP processing');
                    }
                } else {
                    logTest('NLP to MCP Workflow', 'FAIL', 'Required entities not extracted from NLP');
                }
            } else {
                logTest('NLP to MCP Workflow', 'FAIL', 
                    `Intent classification incorrect: Expected CREATE_EMPLOYEE, Got ${nlpResult.intent}`);
            }
        } catch (error) {
            logTest('NLP to MCP Workflow', 'FAIL', 'NLP to MCP workflow test failed', error.message);
        }
    }
    
    static async testConversationalNLP(nlpProcessor) {
        try {
            const conversation = [
                "I need to onboard a new employee",
                "The employee name is Alex Thompson",
                "His email is alex.thompson@company.com",
                "Please assign him a laptop and phone"
            ];
            
            const conversationContext = {
                entities: [],
                intents: [],
                confidence: []
            };
            
            let contextualSuccess = 0;
            for (const utterance of conversation) {
                const result = nlpProcessor.processText(utterance);
                conversationContext.intents.push(result.intent);
                conversationContext.entities.push(...result.entities);
                conversationContext.confidence.push(result.confidence);
                
                if (result.intent !== 'UNKNOWN' && result.confidence > 0.3) {
                    contextualSuccess++;
                }
            }
            
            // Check if we can build a complete profile from conversation
            const hasName = conversationContext.entities.some(e => e.type === 'PERSON');
            const hasEmail = conversationContext.entities.some(e => e.type === 'EMAIL');
            const hasCreateIntent = conversationContext.intents.includes('CREATE_EMPLOYEE');
            const hasAssetIntent = conversationContext.intents.includes('ALLOCATE_ASSET');
            const avgConfidence = conversationContext.confidence.reduce((a, b) => a + b, 0) / conversationContext.confidence.length;
            
            if (hasName && hasEmail && hasCreateIntent && contextualSuccess >= 3 && avgConfidence > 0.4) {
                logTest('Conversational NLP', 'PASS', 
                    `Successfully processed multi-turn conversation (${contextualSuccess}/4 utterances understood)`, {
                    entities: conversationContext.entities,
                    intents: conversationContext.intents,
                    avgConfidence: avgConfidence.toFixed(2)
                });
            } else {
                logTest('Conversational NLP', 'FAIL', 
                    `Conversation processing incomplete (${contextualSuccess}/4 utterances understood)`, {
                    hasName, hasEmail, hasCreateIntent, hasAssetIntent,
                    avgConfidence: avgConfidence.toFixed(2)
                });
            }
        } catch (error) {
            logTest('Conversational NLP', 'FAIL', 'Conversational NLP test failed', error.message);
        }
    }
    
    static async testNLPConfidenceScoring(nlpProcessor) {
        try {
            const confidenceTests = [
                {
                    text: "Create a new employee John Smith with email john.smith@company.com",
                    expectedMinConfidence: 0.7,
                    description: "Clear intent with entities"
                },
                {
                    text: "Maybe add someone new to the team",
                    expectedMinConfidence: 0.3,
                    description: "Vague intent"
                },
                {
                    text: "Show me all available assets in the system",
                    expectedMinConfidence: 0.6,
                    description: "Clear intent without entities"
                },
                {
                    text: "Hello how are you today",
                    expectedMinConfidence: 0.0,
                    description: "No business intent"
                }
            ];
            
            let successCount = 0;
            const results = [];
            
            for (const test of confidenceTests) {
                const result = nlpProcessor.processText(test.text);
                const confidenceMet = result.confidence >= test.expectedMinConfidence;
                
                results.push({
                    text: test.text,
                    description: test.description,
                    expectedMinConfidence: test.expectedMinConfidence,
                    actualConfidence: result.confidence,
                    intent: result.intent,
                    confidenceMet
                });
                
                if (confidenceMet) {
                    successCount++;
                    console.log(`    ✓ "${test.text}" → Confidence: ${result.confidence.toFixed(2)} (Expected: ≥${test.expectedMinConfidence})`);
                } else {
                    console.log(`    ✗ "${test.text}" → Confidence: ${result.confidence.toFixed(2)} (Expected: ≥${test.expectedMinConfidence})`);
                }
            }
            
            if (successCount >= confidenceTests.length * 0.75) {
                logTest('NLP Confidence Scoring', 'PASS', 
                    `${successCount}/${confidenceTests.length} confidence tests passed`, results);
            } else {
                logTest('NLP Confidence Scoring', 'FAIL', 
                    `Only ${successCount}/${confidenceTests.length} confidence tests passed`, results);
            }
        } catch (error) {
            logTest('NLP Confidence Scoring', 'FAIL', 'Confidence scoring test failed', error.message);
        }
    }
}

class LoadTests {
    static async runAll() {
        console.log('\n⚡ Running Load Tests...');
        
        await this.testConcurrentRequests();
        await this.testNLPProcessingLoad();
        await this.testMCPOrchestrationLoad();
    }
    
    static async testConcurrentRequests() {
        try {
            const endpoints = getEndpoints();
            const concurrentRequests = 5;
            const requests = [];
            
            // Create concurrent health check requests
            for (let i = 0; i < concurrentRequests; i++) {
                requests.push(
                    makeHttpRequest('GET', `${endpoints.AGENT_BROKER}/health`)
                        .then(() => ({ success: true, index: i }))
                        .catch(() => ({ success: false, index: i }))
                );
            }
            
            const results = await Promise.allSettled(requests);
            const successCount = results.filter(r => r.status === 'fulfilled' && r.value.success).length;
            
            if (successCount >= concurrentRequests * 0.8) {
                logTest('Concurrent Requests Load Test', 'PASS', 
                    `${successCount}/${concurrentRequests} concurrent requests succeeded`);
            } else {
                logTest('Concurrent Requests Load Test', 'FAIL', 
                    `Only ${successCount}/${concurrentRequests} concurrent requests succeeded`);
            }
        } catch (error) {
            logTest('Concurrent Requests Load Test', 'FAIL', 'Load test failed', error.message);
        }
    }
    
    static async testNLPProcessingLoad() {
        try {
            const nlpProcessor = new NLPProcessor();
            const testPhrases = CONFIG.NLP_TEST_PHRASES.map(p => p.text);
            const iterations = 10;
            
            const startTime = Date.now();
            let processedCount = 0;
            
            for (let i = 0; i < iterations; i++) {
                for (const phrase of testPhrases) {
                    nlpProcessor.processText(phrase);
                    processedCount++;
                }
            }
            
            const endTime = Date.now();
            const processingTime = endTime - startTime;
            const throughput = (processedCount / processingTime * 1000).toFixed(2);
            
            if (throughput > 50) { // 50 phrases per second
                logTest('NLP Processing Load Test', 'PASS', 
                    `Processed ${processedCount} phrases in ${processingTime}ms (${throughput} phrases/sec)`);
            } else {
                logTest('NLP Processing Load Test', 'FAIL', 
                    `Low throughput: ${throughput} phrases/sec (expected >50)`);
            }
        } catch (error) {
            logTest('NLP Processing Load Test', 'FAIL', 'NLP load test failed', error.message);
        }
    }
    
    static async testMCPOrchestrationLoad() {
        try {
            const endpoints = getEndpoints();
            const employeeData = {
                firstName: 'Load',
                lastName: 'Test',
                email: 'load.test@company.com',
                department: 'Testing'
            };
            
            const concurrentOrchestrations = 3;
            const requests = [];
            
            for (let i = 0; i < concurrentOrchestrations; i++) {
                const testEmployee = {
                    ...employeeData,
                    email: `load.test${i}@company.com`
                };
                
                requests.push(
                    makeHttpRequest(
                        'POST',
                        `${endpoints.AGENT_BROKER}/mcp/tools/orchestrate-employee-onboarding`,
                        testEmployee
                    ).then(() => ({ success: true, index: i }))
                     .catch(() => ({ success: false, index: i }))
                );
            }
            
            const results = await Promise.allSettled(requests);
            const successCount = results.filter(r => r.status === 'fulfilled' && r.value.success).length;
            
            if (successCount >= 1) {
                logTest('MCP Orchestration Load Test', 'PASS', 
                    `${successCount}/${concurrentOrchestrations} orchestrations completed`);
            } else {
                logTest('MCP Orchestration Load Test', 'FAIL', 
                    'No orchestrations completed successfully');
            }
        } catch (error) {
            logTest('MCP Orchestration Load Test', 'FAIL', 'Orchestration load test failed', error.message);
        }
    }
}

// Main execution function
async function runComprehensiveTests() {
    console.log('\n🚀 Starting Comprehensive Agent Fabric MCP + NLP Test Suite');
    console.log('='.repeat(70));
    console.log(`Deployment Target: ${CONFIG.USE_CLOUDHUB ? 'CloudHub' : 'Local'}`);
    console.log(`Test Start Time: ${testResults.startTime.toISOString()}`);
    console.log('='.repeat(70));
    
    try {
        // Run all test suites
        await HealthCheckTests.runAll();
        await sleep(CONFIG.DELAY_BETWEEN_TESTS);
        
        await MCPOrchestrationTests.runAll();
        await sleep(CONFIG.DELAY_BETWEEN_TESTS);
        
        await NLPIntegrationTests.runAll();
        await sleep(CONFIG.DELAY_BETWEEN_TESTS);
        
        await LoadTests.runAll();
        
    } catch (error) {
        console.error('Error during test execution:', error);
        logTest('Test Suite Execution', 'FAIL', 'Test suite execution failed', error.message);
    } finally {
        // Generate final report
        testResults.endTime = new Date();
        await generateTestReport();
    }
}

async function generateTestReport() {
    const duration = (testResults.endTime - testResults.startTime) / 1000;
    const successRate = testResults.total > 0 ? (testResults.passed / testResults.total * 100).toFixed(2) : 0;
    
    console.log('\n' + '='.repeat(70));
    console.log('📊 COMPREHENSIVE TEST RESULTS');
    console.log('='.repeat(70));
    console.log(`Total Tests: ${testResults.total}`);
    console.log(`Passed: ${testResults.passed} ✅`);
    console.log(`Failed: ${testResults.failed} ❌`);
    console.log(`Success Rate: ${successRate}%`);
    console.log(`Total Duration: ${duration.toFixed(2)} seconds`);
    console.log(`End Time: ${testResults.endTime.toISOString()}`);
    console.log('='.repeat(70));
    
    // Save detailed report to file
    const reportData = {
        summary: {
            total: testResults.total,
            passed: testResults.passed,
            failed: testResults.failed,
            successRate: `${successRate}%`,
            duration: `${duration.toFixed(2)}s`,
            startTime: testResults.startTime.toISOString(),
            endTime: testResults.endTime.toISOString(),
            deployment: CONFIG.USE_CLOUDHUB ? 'CloudHub' : 'Local'
        },
        testDetails: testResults.details,
        configuration: {
            endpoints: getEndpoints(),
            timeout: CONFIG.TIMEOUT,
            maxRetries: CONFIG.MAX_RETRIES,
            nlpTestPhrases: CONFIG.NLP_TEST_PHRASES.length
        }
    };
    
    try {
        const reportPath = `test-report-${Date.now()}.json`;
        await fs.writeFile(reportPath, JSON.stringify(reportData, null, 2));
        console.log(`📄 Detailed report saved to: ${reportPath}`);
    } catch (error) {
        console.error('Failed to save test report:', error.message);
    }
    
    // Display summary of failed tests
    if (testResults.failed > 0) {
        console.log('\n❌ FAILED TESTS SUMMARY:');
        console.log('-'.repeat(50));
        testResults.details
            .filter(test => test.status === 'FAIL')
            .forEach(test => {
                console.log(`• ${test.testName}: ${test.message}`);
            });
    }
    
    console.log('\n✨ Test Suite Completed!');
    
    // Exit with appropriate code
    process.exit(testResults.failed > 0 ? 1 : 0);
}

// Handle command line arguments
if (process.argv.includes('--cloudhub')) {
    CONFIG.USE_CLOUDHUB = true;
}

if (process.argv.includes('--local')) {
    CONFIG.USE_CLOUDHUB = false;
}

if (process.argv.includes('--help')) {
    console.log(`
🧪 Comprehensive Agent Fabric MCP + NLP Test Suite

Usage: node test-agent-fabric-comprehensive-nlp-mcp.js [options]

Options:
  --cloudhub    Test against CloudHub endpoints
  --local       Test against local endpoints (default)
  --help        Show this help message

Environment Variables:
  USE_CLOUDHUB=true         Test against CloudHub
  AGENT_BROKER_URL         Custom agent broker URL
  EMPLOYEE_ONBOARDING_URL  Custom employee service URL
  ASSET_ALLOCATION_URL     Custom asset service URL
  EMAIL_NOTIFICATION_URL   Custom notification service URL

Test Coverage:
  ✅ Health Check Tests
  ✅ MCP Orchestration Tests  
  ✅ NLP Intent Classification
  ✅ NLP Entity Extraction
  ✅ NLP to MCP Workflow Integration
  ✅ Conversational NLP
  ✅ Load Testing
  ✅ Error Handling
  ✅ Data Flow Consistency

Examples:
  node test-agent-fabric-comprehensive-nlp-mcp.js
  node test-agent-fabric-comprehensive-nlp-mcp.js --cloudhub
  USE_CLOUDHUB=true node test-agent-fabric-comprehensive-nlp-mcp.js
    `);
    process.exit(0);
}

// Run the tests
if (require.main === module) {
    runComprehensiveTests();
}

module.exports = {
    runComprehensiveTests,
    CONFIG,
    NLPProcessor,
    HealthCheckTests,
    MCPOrchestrationTests,
    NLPIntegrationTests,
    LoadTests
};
