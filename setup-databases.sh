#!/bin/bash

echo "==============================================="
echo "MCP Employee Onboarding - Database Setup"
echo "==============================================="
echo

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check Docker availability
print_header "Checking Docker availability..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    echo "Please install Docker:"
    echo "  Ubuntu/Debian: sudo apt-get install docker.io docker-compose"
    echo "  CentOS/RHEL:   sudo yum install docker docker-compose"
    echo "  macOS:         brew install docker docker-compose"
    echo "  Or visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    echo "Please start Docker daemon:"
    echo "  Linux: sudo systemctl start docker"
    echo "  macOS: Start Docker Desktop application"
    exit 1
fi

print_status "Docker is available and running"

# Check Docker Compose availability
if ! command -v docker-compose &> /dev/null; then
    print_warning "docker-compose not found, trying docker compose (v2)"
    if ! docker compose version &> /dev/null; then
        print_error "Neither docker-compose nor 'docker compose' is available"
        echo "Please install Docker Compose:"
        echo "  https://docs.docker.com/compose/install/"
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

print_status "Using: $DOCKER_COMPOSE"
echo

# Start database containers
print_header "Starting Docker containers..."
$DOCKER_COMPOSE -f docker-compose-databases.yml up -d

if [ $? -ne 0 ]; then
    print_error "Failed to start database containers"
    echo "Check Docker logs for more information:"
    echo "  $DOCKER_COMPOSE -f docker-compose-databases.yml logs"
    exit 1
fi

print_status "Database containers started successfully"
echo

# Wait for databases to initialize
print_header "Waiting for databases to initialize (30 seconds)..."
print_warning "This may take longer on first run while images are downloaded"

# Animated waiting indicator
for i in {1..30}; do
    printf "\rWaiting... %d/30 seconds " $i
    sleep 1
done
echo
echo

# Health checks
print_header "Checking database health..."
echo

print_status "Testing PostgreSQL connection..."
if docker exec mcp-postgres pg_isready -U mcp_user -d employee_onboarding &> /dev/null; then
    echo -e "${GREEN}✓${NC} PostgreSQL is ready"
else
    echo -e "${RED}✗${NC} PostgreSQL connection failed"
fi

print_status "Testing H2 availability..."
if curl -s -f http://localhost:8082 &> /dev/null; then
    echo -e "${GREEN}✓${NC} H2 Web Console is available"
else
    echo -e "${RED}✗${NC} H2 Web Console not responding"
fi

print_status "Testing pgAdmin availability..."
if curl -s -f http://localhost:8083 &> /dev/null; then
    echo -e "${GREEN}✓${NC} pgAdmin is available"
else
    echo -e "${RED}✗${NC} pgAdmin not responding"
fi

echo

# Test MCP Server endpoints if they're running
print_header "Testing MCP Server endpoints (if running)..."

test_endpoint() {
    local url=$1
    local name=$2
    
    if curl -s -f "$url" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name: Available"
    else
        echo -e "${YELLOW}?${NC} $name: Not running yet (this is normal if MCP servers aren't started)"
    fi
}

test_endpoint "http://localhost:8085/health" "Asset Allocation MCP"
test_endpoint "http://localhost:8083/health" "Employee Onboarding MCP" 
test_endpoint "http://localhost:8084/health" "Agent Broker MCP"

echo

# Display summary
echo "==============================================="
echo -e "${GREEN}Database Setup Complete!${NC}"
echo "==============================================="
echo

echo -e "${BLUE}Services Available:${NC}"
echo
echo "📊 PostgreSQL Database:"
echo "   - Host: localhost:5432"
echo "   - Database: employee_onboarding"
echo "   - Username: mcp_user"
echo "   - Password: mcp_password"
echo

echo "🗄️  H2 Database:"
echo "   - Web Console: http://localhost:8082"
echo "   - JDBC URL: jdbc:h2:tcp://localhost:9092/~/testdb"
echo "   - Username: sa"
echo "   - Password: (empty)"
echo

echo "🖥️  pgAdmin (PostgreSQL Web UI):"
echo "   - URL: http://localhost:8083"
echo "   - Email: admin@mcp.local"
echo "   - Password: admin123"
echo

echo "🚀 Redis Cache:"
echo "   - Host: localhost:6379"
echo

echo -e "${BLUE}Management Commands:${NC}"
echo "   $DOCKER_COMPOSE -f docker-compose-databases.yml ps      # Check status"
echo "   $DOCKER_COMPOSE -f docker-compose-databases.yml logs    # View logs"
echo "   $DOCKER_COMPOSE -f docker-compose-databases.yml stop    # Stop containers"
echo "   $DOCKER_COMPOSE -f docker-compose-databases.yml down    # Stop and remove"
echo "   $DOCKER_COMPOSE -f docker-compose-databases.yml down -v # Stop and remove with volumes (⚠️  deletes data)"
echo

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Configure your MCP servers to use the databases"
echo "2. Run your MCP error validation tests: ./test-mcp-error-fixes.bat"
echo "3. Check the DATABASE_SETUP_GUIDE.md for detailed configuration instructions"
echo

# Option to open web interfaces
read -p "Would you like to open the web interfaces in your browser? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Opening web interfaces..."
    
    # Try different browser commands based on OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open http://localhost:8082 &  # H2 Console
        open http://localhost:8083 &  # pgAdmin
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:8082 &  # H2 Console
            xdg-open http://localhost:8083 &  # pgAdmin
        elif command -v firefox &> /dev/null; then
            firefox http://localhost:8082 &
            firefox http://localhost:8083 &
        elif command -v google-chrome &> /dev/null; then
            google-chrome http://localhost:8082 &
            google-chrome http://localhost:8083 &
        else
            print_warning "Could not detect browser. Please manually open:"
            echo "  - H2 Console: http://localhost:8082"
            echo "  - pgAdmin: http://localhost:8083"
        fi
    else
        print_warning "Unsupported OS for automatic browser opening. Please manually open:"
        echo "  - H2 Console: http://localhost:8082"
        echo "  - pgAdmin: http://localhost:8083"
    fi
fi

print_status "Database setup completed successfully!"
