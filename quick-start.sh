#!/bin/bash

# Quick Setup Validation for Laravel Serverless Local Environment
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Laravel Serverless Local Environment - Quick Start${NC}\n"

# Step 1: Check prerequisites
echo -e "${YELLOW}Step 1: Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites are installed!${NC}\n"

# Step 2: Install dependencies
echo -e "${YELLOW}Step 2: Installing dependencies...${NC}"
if [ -f "package.json" ]; then
    echo "Installing Node.js dependencies..."
    npm install --silent
    echo -e "${GREEN}✅ Node.js dependencies installed!${NC}"
fi

if [ -f "composer.json" ]; then
    echo "Installing Composer dependencies..."
    composer install --quiet --no-interaction
    echo -e "${GREEN}✅ Composer dependencies installed!${NC}"
fi

echo ""

# Step 3: Setup environment
echo -e "${YELLOW}Step 3: Setting up environment...${NC}"
./local-test.sh setup
echo -e "${GREEN}✅ Environment setup complete!${NC}\n"

# Step 4: Start services
echo -e "${YELLOW}Step 4: Starting services...${NC}"
echo "This may take a few minutes for the first time as Docker images are built..."
./local-test.sh start

echo -e "\n${GREEN}🎉 Setup complete! Your local serverless environment is ready!${NC}\n"

# Step 5: Show available endpoints
echo -e "${BLUE}📋 Available endpoints:${NC}"
echo "  • Serverless (Lambda simulation): http://localhost:3000"
echo "  • Traditional Laravel app: http://localhost:8000"
echo "  • LocalStack (AWS services): http://localhost:4566"
echo "  • Health check: http://localhost:3000/api/health"
echo "  • Serverless test: http://localhost:3000/serverless-test"

echo -e "\n${BLUE}🧪 Test your setup:${NC}"
echo "  • Run comprehensive tests: ./test-local-setup.sh"
echo "  • View logs: ./local-test.sh logs"
echo "  • Stop services: ./local-test.sh stop"

echo -e "\n${BLUE}📚 Documentation:${NC}"
echo "  • Local testing guide: LOCAL-TESTING-GUIDE.md"
echo "  • Serverless setup: README-SERVERLESS.md"
echo "  • AWS setup: AWS-SETUP-GUIDE.md"

echo -e "\n${GREEN}Happy coding! 🚀${NC}"
