# Employee Onboarding Agent Fabric Cleanup Plan

## Current Issues Identified:
1. Duplicate files in root directory and agent-fabric folder
2. Numerous test scripts and troubleshooting batch files
3. Multiple deployment scripts for debugging purposes
4. Documentation files scattered in multiple locations
5. Temporary files and backup configurations

## Standard Mule Agent Fabric Structure Should Be:
```
employee-onboarding-agent-fabric/
├── README.md
├── pom.xml
├── exchange.json
├── .gitignore
├── .env.example
├── docker-compose.yml
├── agent-network.yaml
├── src/
│   └── main/
│       └── resources/
│           └── api/
├── mcp-servers/
│   ├── agent-broker-mcp/
│   ├── employee-onboarding-mcp/
│   ├── asset-allocation-mcp/
│   └── notification-mcp/
├── react-client/
├── database/
├── docs/ (consolidated documentation)
├── cicd/ (CI/CD configurations)
└── shared-components/
```

## Files to Remove from Root Directory:
- All .bat test files
- All .md troubleshooting documents  
- Duplicate configuration files
- Temporary deployment files

## Files to Remove from Agent Fabric Directory:
- All test-*.bat files
- All deploy-*.bat files (except main deployment script)
- All debug-*.bat files
- All fix-*.bat files
- Duplicate documentation files
- Temporary configuration files
- Old backup files

## Files to Keep and Organize:
- Core Mule application files
- Main documentation (consolidated)
- CI/CD configurations
- React client application
- MCP server implementations
- Database setup files
- Docker configurations
