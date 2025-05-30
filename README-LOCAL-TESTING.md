# Local Docker Testing Setup - Complete Guide

## Overview

This setup provides a complete local testing environment for your Laravel serverless application using Docker containers that simulate AWS Lambda and other AWS services.

## What's Included

### 🐳 Docker Services
- **LocalStack**: Full AWS services emulator (Lambda, S3, DynamoDB, API Gateway, etc.)
- **Laravel Local**: Traditional Laravel development container
- **Serverless Container**: Serverless Framework with offline support

### 🛠️ Management Scripts
- **`quick-start.sh`**: One-command setup and start
- **`local-test.sh`**: Comprehensive environment management
- **`test-local-setup.sh`**: Full test suite validation

### 📁 Configuration Files
- **`docker-compose.local.yml`**: Docker services orchestration
- **`serverless.local.yml`**: Serverless Framework local configuration
- **`.env.local`**: Local environment variables

## Quick Start (Recommended)

### 1. One-Command Setup
```bash
./quick-start.sh
```

This script will:
- Check prerequisites (Docker, Node.js, etc.)
- Install dependencies
- Setup environment
- Start all services
- Show available endpoints

### 2. Manual Setup (Alternative)

```bash
# 1. Setup environment
./local-test.sh setup

# 2. Start services
./local-test.sh start

# 3. Run tests
./test-local-setup.sh
```

## Available Endpoints

After starting the services, you'll have access to:

| Service | URL | Purpose |
|---------|-----|---------|
| **Serverless Lambda** | http://localhost:3000 | Lambda function simulation |
| **Traditional Laravel** | http://localhost:8000 | Standard Laravel development |
| **LocalStack** | http://localhost:4566 | AWS services emulator |
| **Health Check** | http://localhost:3000/api/health | Service health status |
| **Serverless Test** | http://localhost:3000/serverless-test | Lambda-specific test endpoint |

## Management Commands

### Environment Control
```bash
# Start all services
./local-test.sh start

# Stop all services
./local-test.sh stop

# Restart services
./local-test.sh restart

# Check status
./local-test.sh status

# View logs
./local-test.sh logs

# View specific service logs
./local-test.sh logs localstack
./local-test.sh logs laravel-local
./local-test.sh logs serverless-local
```

### Laravel Commands
```bash
# Run artisan commands
./local-test.sh artisan migrate
./local-test.sh artisan make:model Post
./local-test.sh artisan test
./local-test.sh artisan route:list
```

### Lambda Function Testing
```bash
# Invoke web function
./local-test.sh invoke web

# Invoke with payload
./local-test.sh invoke web '{"name": "test"}'

# Invoke artisan function
./local-test.sh invoke artisan '{"command": "route:list"}'
```

### Testing and Validation
```bash
# Run comprehensive test suite
./test-local-setup.sh

# Test individual components
./local-test.sh test
```

## Testing Your Application

### 1. HTTP Endpoint Testing
```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Test serverless endpoint
curl http://localhost:3000/serverless-test

# Test traditional Laravel
curl http://localhost:8000/serverless-test

# Test with data
curl -X POST http://localhost:3000/api/lambda-test \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Lambda!"}'
```

### 2. AWS Services Testing
```bash
# Test S3 with LocalStack
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket
aws --endpoint-url=http://localhost:4566 s3 ls

# Test Lambda functions
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Test DynamoDB
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### 3. Performance Testing
```bash
# Install Apache Bench (if not installed)
# macOS: brew install httpd
# Linux: sudo apt-get install apache2-utils

# Load test serverless endpoint
ab -n 100 -c 10 http://localhost:3000/api/health

# Load test traditional Laravel
ab -n 100 -c 10 http://localhost:8000/api/health
```

## Development Workflow

### 1. Daily Development
```bash
# Start environment
./local-test.sh start

# Make code changes
# Your changes are automatically reflected due to volume mounts

# Test changes
curl http://localhost:3000/your-endpoint

# Run tests
./local-test.sh artisan test

# Stop when done
./local-test.sh stop
```

### 2. Lambda Function Development
```bash
# Test function locally
./local-test.sh invoke web '{"test": "data"}'

# Check function logs
./local-test.sh logs serverless-local

# Debug issues
docker-compose -f docker-compose.local.yml exec serverless-local bash
```

### 3. Database Development
```bash
# Run migrations
./local-test.sh artisan migrate

# Seed database
./local-test.sh artisan db:seed

# Access database directly
./local-test.sh artisan tinker
```

## Troubleshooting

### Common Issues

#### 1. Ports Already in Use
```bash
# Check what's using the ports
lsof -i :4566  # LocalStack
lsof -i :8000  # Laravel
lsof -i :3000  # Serverless

# Kill processes or change ports in docker-compose.local.yml
```

#### 2. Permission Errors
```bash
# Fix script permissions
chmod +x *.sh

# Fix Laravel permissions
./local-test.sh artisan storage:link
sudo chown -R $USER:$USER storage bootstrap/cache
```

#### 3. Docker Issues
```bash
# Clean up Docker
docker system prune -a

# Rebuild containers
./local-test.sh cleanup
./local-test.sh start
```

#### 4. LocalStack Not Starting
```bash
# Check Docker daemon
docker ps

# Check LocalStack logs
./local-test.sh logs localstack

# Reset LocalStack data
rm -rf /tmp/localstack
./local-test.sh restart
```

### Debug Mode

Enable detailed logging by setting environment variables:

```bash
# In .env.local
LOG_LEVEL=debug
SLS_DEBUG=1
AWS_DEBUG=1
```

### Container Access

Access containers for debugging:

```bash
# Laravel container
docker-compose -f docker-compose.local.yml exec laravel-local bash

# Serverless container
docker-compose -f docker-compose.local.yml exec serverless-local bash

# Check LocalStack
docker-compose -f docker-compose.local.yml exec localstack bash
```

## Environment Files

### .env.local
Local environment configuration with:
- SQLite database
- LocalStack AWS endpoints
- Debug settings
- Local-specific configurations

### serverless.local.yml
Serverless Framework configuration for local testing:
- LocalStack endpoints
- Local environment variables
- Simplified resource definitions

### docker-compose.local.yml
Docker services definition:
- LocalStack with AWS services
- Laravel development container
- Serverless Framework container
- Network configuration

## Performance Monitoring

### Resource Usage
```bash
# Monitor Docker containers
docker stats

# Monitor specific containers
docker stats localstack laravel-local serverless-local

# Check container logs
./local-test.sh logs
```

### Application Metrics
```bash
# Laravel performance
./local-test.sh artisan route:list --columns=Method,URI,Name,Action
./local-test.sh artisan config:cache
./local-test.sh artisan view:cache

# Test response times
curl -w "@curl-format.txt" -s -o /dev/null http://localhost:3000/api/health
```

## Next Steps

Once local testing is complete:

1. **Configure AWS** - Use `aws-setup.sh` for real AWS setup
2. **Deploy to Staging** - Use `./deploy.sh staging`
3. **Deploy to Production** - Use `./deploy.sh production`
4. **Monitor** - Set up CloudWatch logging and monitoring

## Files Structure

```
test-env/
├── docker-compose.local.yml    # Docker services
├── serverless.local.yml        # Serverless local config
├── .env.local                  # Local environment
├── quick-start.sh              # One-command setup
├── local-test.sh               # Environment management
├── test-local-setup.sh         # Test suite
├── docker/
│   ├── Dockerfile.local        # Laravel container
│   └── Dockerfile.serverless   # Serverless container
└── LOCAL-TESTING-GUIDE.md      # Detailed testing guide
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Run `./test-local-setup.sh` for diagnostic information
3. Check logs with `./local-test.sh logs`
4. Review the detailed `LOCAL-TESTING-GUIDE.md`

Happy coding! 🚀
