# Laravel Serverless - Local Testing Guide

This guide explains how to test your Laravel serverless application locally using Docker containers that simulate the AWS Lambda environment.

## Overview

The local testing setup includes:
- **LocalStack**: AWS services emulator (Lambda, S3, DynamoDB, etc.)
- **Laravel Container**: Traditional Laravel app for development
- **Serverless Container**: Serverless Framework with offline support
- **Docker Compose**: Orchestrates all services

## Quick Start

### 1. Setup Environment
```bash
# Make the script executable
chmod +x local-test.sh

# Setup the local environment
./local-test.sh setup
```

### 2. Start All Services
```bash
# Start LocalStack, Laravel, and Serverless
./local-test.sh start
```

### 3. Access Your Applications
- **Serverless Lambda Simulation**: http://localhost:3000
- **Traditional Laravel App**: http://localhost:8000
- **LocalStack Dashboard**: http://localhost:4566

## Available Commands

### Environment Management
```bash
# Setup environment and install dependencies
./local-test.sh setup

# Check status of all services
./local-test.sh status

# Test the setup
./local-test.sh test
```

### Service Control
```bash
# Start all services
./local-test.sh start

# Stop all services
./local-test.sh stop

# Restart all services
./local-test.sh restart

# Clean up everything (containers, volumes, images)
./local-test.sh cleanup
```

### Debugging and Monitoring
```bash
# Show logs from all services
./local-test.sh logs

# Show logs from specific service
./local-test.sh logs localstack
./local-test.sh logs laravel-local
./local-test.sh logs serverless-local
```

### Laravel Commands
```bash
# Run artisan commands in the container
./local-test.sh artisan migrate
./local-test.sh artisan make:model Post
./local-test.sh artisan test
./local-test.sh artisan queue:work
```

### Lambda Function Testing
```bash
# Invoke web function (default)
./local-test.sh invoke web

# Invoke with custom payload
./local-test.sh invoke web '{"name": "test", "email": "test@example.com"}'

# Invoke artisan function
./local-test.sh invoke artisan '{"command": "route:list"}'
```

## Manual Docker Commands

If you prefer using Docker Compose directly:

```bash
# Build containers
docker-compose -f docker-compose.local.yml build

# Start services
docker-compose -f docker-compose.local.yml up -d

# View logs
docker-compose -f docker-compose.local.yml logs -f

# Stop services
docker-compose -f docker-compose.local.yml down

# Execute commands in containers
docker-compose -f docker-compose.local.yml exec laravel-local php artisan migrate
docker-compose -f docker-compose.local.yml exec serverless-local serverless invoke local --function web
```

## Using npm Scripts

Alternative npm scripts for local testing:

```bash
# Install serverless dependencies
npm install

# Start serverless offline (requires LocalStack to be running)
npm run local:start

# Deploy to LocalStack
npm run local:deploy

# Docker management
npm run docker:up
npm run docker:down
npm run docker:build
npm run docker:logs

# Run tests in container
npm run test:local
```

## Services Explained

### LocalStack
- **Purpose**: Emulates AWS services locally
- **Port**: 4566
- **Services**: Lambda, S3, DynamoDB, SQS, SNS, API Gateway, CloudFormation
- **Health Check**: http://localhost:4566/_localstack/health

### Laravel Local Container
- **Purpose**: Traditional Laravel development environment
- **Port**: 8000
- **Database**: SQLite (for simplicity)
- **Use Case**: Development and testing Laravel features

### Serverless Container
- **Purpose**: Runs Serverless Framework with offline support
- **Port**: 3000
- **Use Case**: Simulates Lambda functions locally

## Testing Your Application

### 1. Web Function Testing
```bash
# Test the web function (HTTP requests)
curl http://localhost:3000/

# Test with parameters
curl "http://localhost:3000/api/users"

# POST request
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John", "email": "john@example.com"}'
```

### 2. Artisan Function Testing
```bash
# Invoke artisan commands via Lambda
./local-test.sh invoke artisan '{"command": "route:list"}'
./local-test.sh invoke artisan '{"command": "make:model", "arguments": ["Post"]}'
```

### 3. AWS Services Testing
```bash
# Test S3 with LocalStack
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket
aws --endpoint-url=http://localhost:4566 s3 ls

# Test Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

## Environment Variables

The local environment uses `.env.local` with these key configurations:

```env
# Application
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:3000

# Database
DB_CONNECTION=sqlite
DB_DATABASE=/app/database/database.sqlite

# AWS (LocalStack)
AWS_ENDPOINT_URL=http://localstack:4566
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test

# Bref
BREF_BINARY_RESPONSES=1
```

## Troubleshooting

### Common Issues

1. **LocalStack not starting**
   ```bash
   # Check if port 4566 is available
   lsof -i :4566
   
   # Restart with cleanup
   ./local-test.sh cleanup
   ./local-test.sh start
   ```

2. **Permission errors**
   ```bash
   # Fix file permissions
   chmod +x local-test.sh
   chmod 775 storage/
   chmod 775 bootstrap/cache/
   ```

3. **Database issues**
   ```bash
   # Reset database
   rm database/database.sqlite
   touch database/database.sqlite
   ./local-test.sh artisan migrate
   ```

4. **Serverless offline not starting**
   ```bash
   # Check Node.js dependencies
   npm install
   
   # Restart serverless container
   docker-compose -f docker-compose.local.yml restart serverless-local
   ```

### Debugging Tips

1. **Check service health**
   ```bash
   ./local-test.sh status
   ./local-test.sh test
   ```

2. **View logs for specific services**
   ```bash
   ./local-test.sh logs localstack
   ./local-test.sh logs laravel-local
   ./local-test.sh logs serverless-local
   ```

3. **Execute commands inside containers**
   ```bash
   # Laravel container
   docker-compose -f docker-compose.local.yml exec laravel-local bash
   
   # Serverless container
   docker-compose -f docker-compose.local.yml exec serverless-local bash
   ```

## Performance Testing

### Load Testing
```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test web function
ab -n 100 -c 10 http://localhost:3000/

# Test traditional Laravel
ab -n 100 -c 10 http://localhost:8000/
```

### Memory and CPU Monitoring
```bash
# Monitor Docker resource usage
docker stats

# Monitor specific container
docker stats laravel-local serverless-local localstack
```

## Next Steps

Once local testing is complete:

1. **Configure AWS credentials** using `aws-setup.sh`
2. **Update environment files** with real AWS resources
3. **Deploy to AWS** using `deploy.sh`
4. **Monitor production** with CloudWatch logs

## Development Workflow

1. **Make code changes** in your Laravel app
2. **Test locally** using the containers
3. **Run tests** with `./local-test.sh artisan test`
4. **Validate serverless** with function invocation
5. **Deploy** when ready with `./deploy.sh`

This local testing environment provides a complete simulation of your production serverless environment, allowing you to catch issues early and develop with confidence.
