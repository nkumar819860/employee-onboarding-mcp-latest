#!/bin/bash
# GitLab CI/CD - Deploy to CloudHub Script
# Employee Onboarding Agent Fabric Deployment Helper

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check required environment variables
check_env_vars() {
    print_message $BLUE "🔍 Checking required environment variables..."
    
    local required_vars=(
        "ANYPOINT_CLIENT_ID"
        "ANYPOINT_CLIENT_SECRET"
        "ANYPOINT_ORG_ID"
        "ENVIRONMENT"
        "BUILD_VERSION"
        "CLOUDHUB_REGION"
        "MULE_VERSION"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_message $RED "❌ Missing required environment variables:"
        printf '%s\n' "${missing_vars[@]}"
        exit 1
    fi
    
    print_message $GREEN "✅ All required environment variables are set"
}

# Function to validate Maven settings
validate_maven() {
    print_message $BLUE "🔍 Validating Maven configuration..."
    
    if ! mvn --version > /dev/null 2>&1; then
        print_message $RED "❌ Maven is not installed or not in PATH"
        exit 1
    fi
    
    print_message $GREEN "✅ Maven validation passed"
}

# Function to deploy a single service
deploy_service() {
    local service_name=$1
    local service_path="mcp-servers/${service_name}"
    
    print_message $BLUE "🚀 Deploying ${service_name} to CloudHub..."
    
    # Check if service directory exists
    if [ ! -d "$service_path" ]; then
        print_message $RED "❌ Service directory not found: $service_path"
        exit 1
    fi
    
    cd "$service_path"
    
    # Application name based on environment
    local app_name="${service_name}-${ENVIRONMENT}"
    
    # Deploy to CloudHub
    mvn deploy -DmuleDeploy -B \
        -DskipTests \
        -Danypoint.client_id="${ANYPOINT_CLIENT_ID}" \
        -Danypoint.client_secret="${ANYPOINT_CLIENT_SECRET}" \
        -Dcloudhub.application.name="${app_name}" \
        -Dcloudhub.environment="${ENVIRONMENT}" \
        -Dcloudhub.worker.type="${CLOUDHUB_WORKER_TYPE:-MICRO}" \
        -Dcloudhub.workers="${CLOUDHUB_WORKERS:-1}" \
        -Dcloudhub.region="${CLOUDHUB_REGION}" \
        -Dcloudhub.mule.version="${MULE_VERSION}" \
        -Dcloudhub.objectStoreV2=true \
        -Dcloudhub.persistentQueues="${CLOUDHUB_PERSISTENT_QUEUES:-false}" \
        -Dcloudhub.monitoringEnabled="${CLOUDHUB_MONITORING:-true}" \
        -Dcloudhub.monitoringAutoRestart="${CLOUDHUB_AUTO_RESTART:-true}" \
        -Dversion="${BUILD_VERSION}"
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "✅ ${service_name} deployed successfully"
    else
        print_message $RED "❌ Failed to deploy ${service_name}"
        cd ../..
        exit 1
    fi
    
    cd ../..
}

# Function to perform health check
health_check() {
    local service_name=$1
    local app_name="${service_name}-${ENVIRONMENT}"
    local health_url="https://${app_name}.${CLOUDHUB_REGION}.cloudhub.io/health"
    
    print_message $BLUE "🏥 Performing health check for ${service_name}..."
    
    local max_attempts=20
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$health_url" > /dev/null; then
            print_message $GREEN "✅ ${service_name} is healthy!"
            return 0
        fi
        
        print_message $YELLOW "⏳ Attempt ${attempt}/${max_attempts}: Waiting for ${service_name} to be ready..."
        sleep 30
        ((attempt++))
    done
    
    print_message $RED "❌ Health check failed for ${service_name} after ${max_attempts} attempts"
    return 1
}

# Function to deploy all services
deploy_all_services() {
    local services=("employee-onboarding-mcp" "asset-allocation-mcp" "notification-mcp" "agent-broker-mcp")
    local failed_services=()
    
    print_message $BLUE "🚀 Starting deployment of all MCP services..."
    
    for service in "${services[@]}"; do
        if deploy_service "$service"; then
            if [ "${SKIP_HEALTH_CHECKS:-false}" != "true" ]; then
                if ! health_check "$service"; then
                    failed_services+=("$service")
                fi
            fi
        else
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        print_message $GREEN "🎉 All services deployed successfully!"
        return 0
    else
        print_message $RED "❌ Failed to deploy the following services:"
        printf '%s\n' "${failed_services[@]}"
        return 1
    fi
}

# Function to display deployment summary
deployment_summary() {
    print_message $BLUE "📊 Deployment Summary"
    print_message $BLUE "===================="
    echo "Environment: ${ENVIRONMENT}"
    echo "Build Version: ${BUILD_VERSION}"
    echo "CloudHub Region: ${CLOUDHUB_REGION}"
    echo "Worker Type: ${CLOUDHUB_WORKER_TYPE:-MICRO}"
    echo "Number of Workers: ${CLOUDHUB_WORKERS:-1}"
    echo "Mule Version: ${MULE_VERSION}"
    print_message $BLUE "===================="
}

# Main execution
main() {
    print_message $GREEN "🚀 Employee Onboarding Agent Fabric - CloudHub Deployment"
    print_message $GREEN "========================================================="
    
    # Validate environment
    check_env_vars
    validate_maven
    deployment_summary
    
    # Deploy services
    if deploy_all_services; then
        print_message $GREEN "🎉 Deployment completed successfully!"
        
        # Display application URLs
        print_message $BLUE "📱 Application URLs:"
        local services=("employee-onboarding-mcp" "asset-allocation-mcp" "notification-mcp" "agent-broker-mcp")
        for service in "${services[@]}"; do
            local app_name="${service}-${ENVIRONMENT}"
            echo "  ${service}: https://${app_name}.${CLOUDHUB_REGION}.cloudhub.io"
        done
        
        exit 0
    else
        print_message $RED "💥 Deployment failed!"
        exit 1
    fi
}

# Handle script arguments
case "${1:-all}" in
    "employee-onboarding-mcp"|"asset-allocation-mcp"|"notification-mcp"|"agent-broker-mcp")
        print_message $GREEN "🚀 Deploying single service: $1"
        check_env_vars
        validate_maven
        deployment_summary
        
        if deploy_service "$1"; then
            if [ "${SKIP_HEALTH_CHECKS:-false}" != "true" ]; then
                health_check "$1"
            fi
            print_message $GREEN "🎉 Service $1 deployed successfully!"
        else
            print_message $RED "💥 Failed to deploy service $1"
            exit 1
        fi
        ;;
    "all"|"")
        main
        ;;
    *)
        print_message $RED "❌ Invalid service name: $1"
        print_message $BLUE "Valid options: employee-onboarding-mcp, asset-allocation-mcp, notification-mcp, agent-broker-mcp, all"
        exit 1
        ;;
esac
