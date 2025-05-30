#!/bin/bash

# Comprehensive Test Suite for Laravel Serverless Local Environment
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to print colored output
print_test_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    ((TOTAL_TESTS++))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $test_name: $message"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗${NC} $test_name: $message"
        ((FAILED_TESTS++))
    fi
}

print_summary() {
    echo -e "\n${BLUE}=== Test Summary ===${NC}"
    echo -e "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "\n${RED}❌ Some tests failed. Check the output above.${NC}"
        exit 1
    fi
}

# Test 1: Check prerequisites
test_prerequisites() {
    print_test_header "Testing Prerequisites"
    
    # Docker
    if command -v docker &> /dev/null; then
        print_test_result "Docker" "PASS" "Docker is installed"
    else
        print_test_result "Docker" "FAIL" "Docker is not installed"
    fi
    
    # Docker Compose
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
        print_test_result "Docker Compose" "PASS" "Docker Compose is available"
    else
        print_test_result "Docker Compose" "FAIL" "Docker Compose is not available"
    fi
    
    # Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        print_test_result "Node.js" "PASS" "Node.js is installed ($node_version)"
    else
        print_test_result "Node.js" "FAIL" "Node.js is not installed"
    fi
    
    # npm
    if command -v npm &> /dev/null; then
        local npm_version=$(npm --version)
        print_test_result "npm" "PASS" "npm is installed ($npm_version)"
    else
        print_test_result "npm" "FAIL" "npm is not installed"
    fi
}

# Test 2: Check file structure
test_file_structure() {
    print_test_header "Testing File Structure"
    
    local required_files=(
        "docker-compose.local.yml"
        "serverless.local.yml"
        ".env.local"
        "docker/Dockerfile.local"
        "docker/Dockerfile.serverless"
        "local-test.sh"
        "package.json"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_test_result "File Structure" "PASS" "$file exists"
        else
            print_test_result "File Structure" "FAIL" "$file is missing"
        fi
    done
}

# Test 3: Check Docker containers
test_docker_containers() {
    print_test_header "Testing Docker Containers"
    
    # Check if containers are running
    if docker-compose -f docker-compose.local.yml ps | grep -q "Up"; then
        print_test_result "Docker Containers" "PASS" "Containers are running"
    else
        print_test_result "Docker Containers" "FAIL" "Containers are not running"
        return
    fi
    
    # Check individual containers
    local containers=("localstack" "laravel-local" "serverless-local")
    
    for container in "${containers[@]}"; do
        if docker-compose -f docker-compose.local.yml ps | grep "$container" | grep -q "Up"; then
            print_test_result "Container Status" "PASS" "$container is running"
        else
            print_test_result "Container Status" "FAIL" "$container is not running"
        fi
    done
}

# Test 4: Check service connectivity
test_service_connectivity() {
    print_test_header "Testing Service Connectivity"
    
    # Wait a moment for services to be ready
    sleep 5
    
    # LocalStack health check
    if curl -s -f http://localhost:4566/_localstack/health > /dev/null 2>&1; then
        print_test_result "LocalStack Health" "PASS" "LocalStack is healthy"
    else
        print_test_result "LocalStack Health" "FAIL" "LocalStack health check failed"
    fi
    
    # Laravel app connectivity
    if curl -s -f http://localhost:8000 > /dev/null 2>&1; then
        print_test_result "Laravel App" "PASS" "Laravel app is responding"
    else
        print_test_result "Laravel App" "FAIL" "Laravel app is not responding"
    fi
    
    # Serverless offline connectivity
    if curl -s -f http://localhost:3000 > /dev/null 2>&1; then
        print_test_result "Serverless Offline" "PASS" "Serverless endpoint is responding"
    else
        print_test_result "Serverless Offline" "FAIL" "Serverless endpoint is not responding"
    fi
}

# Test 5: Test AWS services with LocalStack
test_localstack_services() {
    print_test_header "Testing LocalStack AWS Services"
    
    # Set AWS credentials for LocalStack
    export AWS_ACCESS_KEY_ID=test
    export AWS_SECRET_ACCESS_KEY=test
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_ENDPOINT_URL=http://localhost:4566
    
    # Test S3
    if aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket 2>/dev/null; then
        print_test_result "S3 Service" "PASS" "S3 bucket creation successful"
        aws --endpoint-url=http://localhost:4566 s3 rb s3://test-bucket 2>/dev/null || true
    else
        print_test_result "S3 Service" "FAIL" "S3 bucket creation failed"
    fi
    
    # Test Lambda
    if aws --endpoint-url=http://localhost:4566 lambda list-functions > /dev/null 2>&1; then
        print_test_result "Lambda Service" "PASS" "Lambda service is accessible"
    else
        print_test_result "Lambda Service" "FAIL" "Lambda service is not accessible"
    fi
}

# Test 6: Test Laravel artisan commands
test_laravel_artisan() {
    print_test_header "Testing Laravel Artisan Commands"
    
    # Test basic artisan command
    if docker-compose -f docker-compose.local.yml exec -T laravel-local php artisan --version > /dev/null 2>&1; then
        print_test_result "Artisan Command" "PASS" "Artisan commands work"
    else
        print_test_result "Artisan Command" "FAIL" "Artisan commands failed"
    fi
    
    # Test route list
    if docker-compose -f docker-compose.local.yml exec -T laravel-local php artisan route:list > /dev/null 2>&1; then
        print_test_result "Route List" "PASS" "Route listing works"
    else
        print_test_result "Route List" "FAIL" "Route listing failed"
    fi
    
    # Test database connection
    if docker-compose -f docker-compose.local.yml exec -T laravel-local php artisan migrate:status > /dev/null 2>&1; then
        print_test_result "Database Connection" "PASS" "Database connection works"
    else
        print_test_result "Database Connection" "FAIL" "Database connection failed"
    fi
}

# Test 7: Test serverless function invocation
test_serverless_functions() {
    print_test_header "Testing Serverless Function Invocation"
    
    # Test web function invocation
    local web_result=$(docker-compose -f docker-compose.local.yml exec -T serverless-local \
        serverless invoke local --function web --config serverless.local.yml 2>&1 || echo "FAILED")
    
    if [[ "$web_result" != *"FAILED"* ]] && [[ "$web_result" != *"error"* ]]; then
        print_test_result "Web Function" "PASS" "Web function invocation successful"
    else
        print_test_result "Web Function" "FAIL" "Web function invocation failed"
    fi
    
    # Test artisan function invocation
    local artisan_result=$(docker-compose -f docker-compose.local.yml exec -T serverless-local \
        serverless invoke local --function artisan --config serverless.local.yml \
        --data '{"command": "route:list"}' 2>&1 || echo "FAILED")
    
    if [[ "$artisan_result" != *"FAILED"* ]] && [[ "$artisan_result" != *"error"* ]]; then
        print_test_result "Artisan Function" "PASS" "Artisan function invocation successful"
    else
        print_test_result "Artisan Function" "FAIL" "Artisan function invocation failed"
    fi
}

# Test 8: Test HTTP endpoints
test_http_endpoints() {
    print_test_header "Testing HTTP Endpoints"
    
    # Test Laravel traditional endpoint
    local laravel_response=$(curl -s -w "%{http_code}" http://localhost:8000 -o /dev/null 2>/dev/null || echo "000")
    if [ "$laravel_response" = "200" ]; then
        print_test_result "Laravel HTTP" "PASS" "Laravel HTTP endpoint returns 200"
    else
        print_test_result "Laravel HTTP" "FAIL" "Laravel HTTP endpoint returned $laravel_response"
    fi
    
    # Test serverless endpoint
    local serverless_response=$(curl -s -w "%{http_code}" http://localhost:3000 -o /dev/null 2>/dev/null || echo "000")
    if [ "$serverless_response" = "200" ] || [ "$serverless_response" = "404" ]; then
        print_test_result "Serverless HTTP" "PASS" "Serverless HTTP endpoint is accessible"
    else
        print_test_result "Serverless HTTP" "FAIL" "Serverless HTTP endpoint returned $serverless_response"
    fi
}

# Test 9: Test environment configuration
test_environment_config() {
    print_test_header "Testing Environment Configuration"
    
    # Check if .env.local exists
    if [ -f ".env.local" ]; then
        print_test_result "Environment File" "PASS" ".env.local exists"
    else
        print_test_result "Environment File" "FAIL" ".env.local is missing"
    fi
    
    # Check Laravel environment in container
    local app_env=$(docker-compose -f docker-compose.local.yml exec -T laravel-local php artisan tinker --execute="echo app()->environment();" 2>/dev/null | tail -1 || echo "unknown")
    if [ "$app_env" = "local" ]; then
        print_test_result "Laravel Environment" "PASS" "Laravel environment is set to local"
    else
        print_test_result "Laravel Environment" "FAIL" "Laravel environment is $app_env (expected: local)"
    fi
}

# Test 10: Test file permissions
test_file_permissions() {
    print_test_header "Testing File Permissions"
    
    # Check if local-test.sh is executable
    if [ -x "local-test.sh" ]; then
        print_test_result "Script Permissions" "PASS" "local-test.sh is executable"
    else
        print_test_result "Script Permissions" "FAIL" "local-test.sh is not executable"
    fi
    
    # Check Laravel storage permissions
    if docker-compose -f docker-compose.local.yml exec -T laravel-local test -w /app/storage; then
        print_test_result "Storage Permissions" "PASS" "Laravel storage is writable"
    else
        print_test_result "Storage Permissions" "FAIL" "Laravel storage is not writable"
    fi
}

# Main test execution
main() {
    echo -e "${BLUE}Starting comprehensive test suite for Laravel Serverless Local Environment${NC}\n"
    
    test_prerequisites
    test_file_structure
    test_docker_containers
    test_service_connectivity
    test_localstack_services
    test_laravel_artisan
    test_serverless_functions
    test_http_endpoints
    test_environment_config
    test_file_permissions
    
    print_summary
}

# Run tests
main "$@"
