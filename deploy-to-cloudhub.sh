#!/bin/bash

# Employee Onboarding System - CloudHub Deployment Script
# This script deploys all MCP servers to CloudHub with proper configuration

set -e

echo "🚀 Starting CloudHub deployment for Employee Onboarding System..."

# Check if Anypoint CLI is installed
if ! command -v anypoint-cli &> /dev/null; then
    echo "❌ Anypoint CLI is not installed. Please install it first:"
    echo "npm install -g anypoint-cli"
    exit 1
fi

# Check environment variables
if [ -z "$ANYPOINT_USERNAME" ] || [ -z "$ANYPOINT_PASSWORD" ]; then
    echo "❌ Please set ANYPOINT_USERNAME and ANYPOINT_PASSWORD environment variables"
    exit 1
fi

echo "📝 Logging into Anypoint Platform..."
anypoint-cli conf username "$ANYPOINT_USERNAME"
anypoint-cli conf password "$ANYPOINT_PASSWORD"

# Set common deployment parameters
ENVIRONMENT="Sandbox"
REGION="us-east-1"
WORKER_TYPE="MICRO"
WORKERS=1
BUSINESS_GROUP="COE"

echo "🔧 Building all applications..."

# Build Employee Onboarding MCP Server
echo "📦 Building Employee Onboarding MCP Server..."
cd "$(dirname "$0")"
mvn clean package -DskipTests

# Build Asset Allocation MCP Server
echo "📦 Building Asset Allocation MCP Server..."
cd asset-allocation-mcp
mvn clean package -DskipTests
cd ..

# Build Notification MCP Server
echo "📦 Building Notification MCP Server..."
cd notification-mcp
mvn clean package -DskipTests
cd ..

# Build Agent Broker
echo "📦 Building Employee Onboarding Agent Broker..."
cd employee-onboarding-agent-broker
mvn clean package -DskipTests
cd ..

echo "🚀 Starting CloudHub deployments..."

# Deploy Employee Onboarding MCP Server
echo "📡 Deploying Employee Onboarding MCP Server..."
anypoint-cli cloudhub application deploy \
  --applicationName "employee-onboarding-mcp-server" \
  --runtime "4.11.1:40e-java17" \
  --workers $WORKERS \
  --workerType $WORKER_TYPE \
  --region $REGION \
  --environment $ENVIRONMENT \
  --businessGroup "$BUSINESS_GROUP" \
  --property "http.port:8081" \
  --property "db.host:${DATABASE_HOST}" \
  --property "db.port:5432" \
  --property "db.database:employee_db" \
  --property "db.username:${DATABASE_USERNAME}" \
  --property "db.password:${DATABASE_PASSWORD}" \
  --property "mcp.serverName:Employee Onboarding MCP Server" \
  --property "mcp.serverVersion:1.0.0" \
  target/employee-onboarding-mcp-server-1.0.0-mule-application.jar

# Deploy Asset Allocation MCP Server  
echo "📡 Deploying Asset Allocation MCP Server..."
anypoint-cli cloudhub application deploy \
  --applicationName "asset-allocation-mcp-server" \
  --runtime "4.11.1:40e-java17" \
  --workers $WORKERS \
  --workerType $WORKER_TYPE \
  --region $REGION \
  --environment $ENVIRONMENT \
  --businessGroup "$BUSINESS_GROUP" \
  --property "http.port:8082" \
  --property "db.host:${DATABASE_HOST}" \
  --property "db.port:5432" \
  --property "db.database:asset_db" \
  --property "db.username:${DATABASE_USERNAME}" \
  --property "db.password:${DATABASE_PASSWORD}" \
  --property "mcp.serverName:Asset Allocation MCP Server" \
  --property "mcp.serverVersion:1.0.0" \
  asset-allocation-mcp/target/asset-allocation-mcp-server-1.0.0-mule-application.jar

# Deploy Notification MCP Server
echo "📡 Deploying Notification MCP Server..."
anypoint-cli cloudhub application deploy \
  --applicationName "notification-mcp-server" \
  --runtime "4.11.1:40e-java17" \
  --workers $WORKERS \
  --workerType $WORKER_TYPE \
  --region $REGION \
  --environment $ENVIRONMENT \
  --businessGroup "$BUSINESS_GROUP" \
  --property "http.port:8083" \
  --property "email.from.address:${EMAIL_FROM_ADDRESS}" \
  --property "email.password:${EMAIL_PASSWORD}" \
  --property "email.smtp.host:smtp.gmail.com" \
  --property "email.smtp.port:587" \
  --property "notification.cc.hr:${NOTIFICATION_CC_HR}" \
  --property "notification.cc.it:${NOTIFICATION_CC_IT}" \
  --property "mcp.serverName:Notification MCP Server" \
  --property "mcp.serverVersion:1.0.0" \
  notification-mcp/target/notification-mcp-server-1.0.0-mule-application.jar

# Deploy Agent Broker
echo "📡 Deploying Employee Onboarding Agent Broker..."
anypoint-cli cloudhub application deploy \
  --applicationName "employee-onboarding-agent-broker" \
  --runtime "4.11.1:40e-java17" \
  --workers $WORKERS \
  --workerType $WORKER_TYPE \
  --region $REGION \
  --environment $ENVIRONMENT \
  --businessGroup "$BUSINESS_GROUP" \
  --property "http.port:8084" \
  --property "employee.onboarding.mcp.url:https://employee-onboarding-mcp-server.sandbox.anypoint.mulesoft.com" \
  --property "asset.allocation.mcp.url:https://asset-allocation-mcp-server.sandbox.anypoint.mulesoft.com" \
  --property "notification.mcp.url:https://notification-mcp-server.sandbox.anypoint.mulesoft.com" \
  --property "mcp.serverName:Employee Onboarding Agent Broker" \
  --property "mcp.serverVersion:1.0.0" \
  employee-onboarding-agent-broker/target/employee-onboarding-agent-broker-1.0.0-mule-application.jar

echo "⏳ Waiting for applications to start..."
sleep 60

echo "🏥 Checking application health..."

# Health check function
check_health() {
    local app_name=$1
    local url="https://${app_name}.sandbox.anypoint.mulesoft.com/health"
    
    echo "Checking health for $app_name..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$response" = "200" ]; then
        echo "✅ $app_name is healthy"
        return 0
    else
        echo "❌ $app_name health check failed (HTTP $response)"
        return 1
    fi
}

# Perform health checks
check_health "employee-onboarding-mcp-server"
check_health "asset-allocation-mcp-server" 
check_health "notification-mcp-server"
check_health "employee-onboarding-agent-broker"

echo "🎉 CloudHub deployment completed successfully!"
echo ""
echo "📋 Deployed Applications:"
echo "• Employee Onboarding MCP Server: https://employee-onboarding-mcp-server.sandbox.anypoint.mulesoft.com"
echo "• Asset Allocation MCP Server: https://asset-allocation-mcp-server.sandbox.anypoint.mulesoft.com"  
echo "• Notification MCP Server: https://notification-mcp-server.sandbox.anypoint.mulesoft.com"
echo "• Agent Broker: https://employee-onboarding-agent-broker.sandbox.anypoint.mulesoft.com"
echo ""
echo "🔧 Next Steps:"
echo "1. Deploy Flex Gateway configuration: kubectl apply -f employee-onboarding-gateway-config.yaml"
echo "2. Test the complete system with NLP capabilities"
echo "3. Verify agent network functionality"

exit 0
