#!/bin/bash

# Local Testing Management Script for Laravel Serverless
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
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
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_header "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        missing_tools+=("docker")
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        missing_tools+=("docker-compose")
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install them before continuing."
        exit 1
    fi
    
    print_status "All prerequisites are installed ✓"
}

# Function to setup environment
setup_environment() {
    print_header "Setting up local environment..."
    
    # Create necessary directories
    mkdir -p docker
    mkdir -p storage/logs
    mkdir -p database
    
    # Create SQLite database if it doesn't exist
    if [ ! -f database/database.sqlite ]; then
        touch database/database.sqlite
        print_status "Created SQLite database"
    fi
    
    # Install Node.js dependencies
    if [ -f package.json ]; then
        print_status "Installing Node.js dependencies..."
        npm install
    fi
    
    # Copy environment file for local testing
    if [ ! -f .env.local ]; then
        if [ -f .env.example ]; then
            cp .env.example .env.local
            print_status "Created .env.local from .env.example"
        else
            print_warning ".env.example not found, creating basic .env.local"
            cat > .env.local << EOF
APP_NAME="Laravel Serverless Local"
APP_ENV=local
APP_KEY=base64:VERYINSECUREKEYFORLOCALTESTINGONLY=
APP_DEBUG=true
APP_URL=http://localhost:3000

LOG_CHANNEL=stderr

DB_CONNECTION=sqlite
DB_DATABASE=/app/database/database.sqlite

CACHE_DRIVER=array
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=array
SESSION_LIFETIME=120

AWS_DEFAULT_REGION=us-east-1
AWS_ENDPOINT_URL=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test

BREF_BINARY_RESPONSES=1
EOF
        fi
    fi
    
    print_status "Environment setup complete ✓"
}

# Function to start local services
start_services() {
    print_header "Starting local services..."
    
    # Build and start Docker containers
    print_status "Building Docker containers..."
    docker-compose -f docker-compose.local.yml build
    
    print_status "Starting LocalStack and Laravel containers..."
    docker-compose -f docker-compose.local.yml up -d localstack laravel-local
    
    # Wait for LocalStack to be ready
    print_status "Waiting for LocalStack to be ready..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
            print_status "LocalStack is ready ✓"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "LocalStack failed to start after $max_attempts attempts"
            exit 1
        fi
        
        echo "Attempt $attempt/$max_attempts - waiting for LocalStack..."
        sleep 2
        ((attempt++))
    done
    
    print_status "All services started successfully ✓"
}

# Function to start serverless offline
start_serverless() {
    print_header "Starting Serverless Offline..."
    
    # Start serverless container
    print_status "Starting Serverless container..."
    docker-compose -f docker-compose.local.yml up -d serverless-local
    
    print_status "Serverless Offline is starting..."
    print_status "Web interface will be available at: http://localhost:3000"
    print_status "Laravel app (traditional) available at: http://localhost:8000"
    print_status "LocalStack dashboard available at: http://localhost:4566"
}

# Function to show logs
show_logs() {
    local service=${1:-""}
    
    if [ -z "$service" ]; then
        print_header "Showing logs for all services..."
        docker-compose -f docker-compose.local.yml logs -f
    else
        print_header "Showing logs for $service..."
        docker-compose -f docker-compose.local.yml logs -f "$service"
    fi
}

# Function to stop services
stop_services() {
    print_header "Stopping local services..."
    docker-compose -f docker-compose.local.yml down
    print_status "All services stopped ✓"
}

# Function to test the setup
test_setup() {
    print_header "Testing local setup..."
    
    # Test LocalStack
    print_status "Testing LocalStack..."
    if curl -s http://localhost:4566/_localstack/health | grep -q "running"; then
        print_status "LocalStack is healthy ✓"
    else
        print_error "LocalStack health check failed"
        return 1
    fi
    
    # Test Laravel app
    print_status "Testing Laravel app..."
    if curl -s http://localhost:8000 > /dev/null; then
        print_status "Laravel app is responding ✓"
    else
        print_warning "Laravel app is not responding (this might be normal if not started)"
    fi
    
    # Test Serverless endpoint
    print_status "Testing Serverless endpoint..."
    if curl -s http://localhost:3000 > /dev/null; then
        print_status "Serverless endpoint is responding ✓"
    else
        print_warning "Serverless endpoint is not responding (this might be normal if not started)"
    fi
}

# Function to run Laravel commands in container
run_artisan() {
    local command="$*"
    print_status "Running: php artisan $command"
    docker-compose -f docker-compose.local.yml exec laravel-local php artisan $command
}

# Function to invoke Lambda function locally
invoke_lambda() {
    local function_name="${1:-web}"
    local payload="${2:-{}}"
    
    print_status "Invoking Lambda function: $function_name"
    docker-compose -f docker-compose.local.yml exec serverless-local \
        serverless invoke local --function "$function_name" --data "$payload" --config serverless.local.yml
}

# Function to show status
show_status() {
    print_header "Local Environment Status"
    
    echo "Docker containers:"
    docker-compose -f docker-compose.local.yml ps
    
    echo ""
    echo "Available endpoints:"
    echo "  - Serverless (Lambda): http://localhost:3000"
    echo "  - Laravel (Traditional): http://localhost:8000"
    echo "  - LocalStack: http://localhost:4566"
    
    echo ""
    echo "Container logs:"
    echo "  - All logs: ./local-test.sh logs"
    echo "  - Specific service: ./local-test.sh logs [service-name]"
}

# Function to clean up
cleanup() {
    print_header "Cleaning up local environment..."
    
    # Stop all containers
    docker-compose -f docker-compose.local.yml down
    
    # Remove containers and volumes
    docker-compose -f docker-compose.local.yml down -v --remove-orphans
    
    # Remove built images
    docker-compose -f docker-compose.local.yml down --rmi local
    
    print_status "Cleanup completed ✓"
}

# Main script logic
case "${1:-}" in
    "setup")
        check_prerequisites
        setup_environment
        ;;
    "start")
        check_prerequisites
        setup_environment
        start_services
        start_serverless
        show_status
        ;;
    "stop")
        stop_services
        ;;
    "restart")
        stop_services
        start_services
        start_serverless
        ;;
    "logs")
        show_logs "${2:-}"
        ;;
    "test")
        test_setup
        ;;
    "artisan")
        shift
        run_artisan "$@"
        ;;
    "invoke")
        invoke_lambda "${2:-web}" "${3:-{}}"
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "Laravel Serverless Local Testing Manager"
        echo ""
        echo "Usage: $0 {setup|start|stop|restart|logs|test|artisan|invoke|status|cleanup}"
        echo ""
        echo "Commands:"
        echo "  setup     - Check prerequisites and setup environment"
        echo "  start     - Start all local services (LocalStack + Laravel + Serverless)"
        echo "  stop      - Stop all local services"
        echo "  restart   - Restart all local services"
        echo "  logs      - Show logs (optional: specify service name)"
        echo "  test      - Test the local setup"
        echo "  artisan   - Run Laravel artisan commands in container"
        echo "  invoke    - Invoke Lambda function locally"
        echo "  status    - Show status of local environment"
        echo "  cleanup   - Clean up containers and images"
        echo ""
        echo "Examples:"
        echo "  $0 start                          # Start all services"
        echo "  $0 logs localstack               # Show LocalStack logs"
        echo "  $0 artisan migrate               # Run Laravel migrations"
        echo "  $0 invoke web '{\"name\":\"test\"}'  # Invoke web function with payload"
        exit 1
        ;;
esac
