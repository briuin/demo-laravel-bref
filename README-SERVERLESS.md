# Laravel Serverless with Bref.sh

A Laravel application configured for serverless deployment using Bref.sh and AWS Lambda, with support for multiple environments.

## 🚀 Features

- **Serverless Laravel**: Deploy Laravel to AWS Lambda using Bref.sh
- **Multi-Environment Support**: Separate configurations for dev, staging, and production
- **Optimized for Lambda**: Custom middleware and service providers for optimal performance
- **Easy Deployment**: Simple scripts for deployment and environment management
- **Asset Optimization**: Configured for efficient static asset serving

## 📋 Prerequisites

- PHP 8.2+
- Node.js 18+
- Composer
- AWS CLI configured with appropriate credentials
- Docker (for local development with Laravel Sail)

## 🛠 Installation

1. **Install dependencies:**
   ```bash
   composer install
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

3. **Start local development (with Docker):**
   ```bash
   ./vendor/bin/sail up -d
   ./vendor/bin/sail artisan migrate
   ```

## 🌍 Environment Configuration

### Available Environments

- **dev** (`env.dev.yml`) - Development environment
- **staging** (`env.staging.yml`) - Staging environment  
- **production** (`env.production.yml`) - Production environment

### Environment Manager

Use the environment manager script to handle different environments:

```bash
# List available environments
./env-manager.sh list

# Show environment configuration
./env-manager.sh show dev

# Create new environment
./env-manager.sh create staging

# Deploy to environment
./env-manager.sh deploy dev

# View logs
./env-manager.sh logs production

# Run artisan commands
./env-manager.sh invoke staging "migrate --force"
```

## 🚀 Deployment

### Quick Deployment

```bash
# Deploy to development
./deploy.sh dev

# Deploy to staging
./deploy.sh staging

# Deploy to production
./deploy.sh production
```

### Manual Deployment Steps

1. **Build assets:**
   ```bash
   npm run build
   ```

2. **Optimize Laravel:**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

3. **Deploy with Serverless:**
   ```bash
   ./vendor/bin/serverless deploy --stage=production
   ```

## 🔧 Configuration

### Environment Variables

Each environment file (`env.{stage}.yml`) contains:

- **Application settings** (APP_ENV, APP_KEY, APP_DEBUG)
- **Database configuration** (DB_CONNECTION, DB_HOST, etc.)
- **Cache and session settings** (CACHE_DRIVER, SESSION_DRIVER)
- **Queue configuration** (QUEUE_CONNECTION)
- **Mail settings** (MAIL_MAILER)
- **Logging configuration** (LOG_CHANNEL, LOG_LEVEL)

### Serverless Configuration

The `serverless.yml` file includes:

- **Web function**: Handles HTTP requests via API Gateway
- **Artisan function**: Executes Laravel commands
- **Environment variables**: Loaded from environment-specific files
- **Asset optimization**: Static assets served via CloudFront

## 📊 Monitoring and Debugging

### View Logs

```bash
# Real-time logs
./env-manager.sh logs production

# Serverless logs
./vendor/bin/serverless logs -f web --stage=production --tail
```

### Run Commands

```bash
# Run artisan commands in Lambda
./env-manager.sh invoke production "queue:work --once"
./env-manager.sh invoke staging "migrate:status"
```

### Check Deployment Status

```bash
./env-manager.sh status production
```

## 🎯 Performance Optimizations

### Lambda-Specific Optimizations

- **ServerlessServiceProvider**: Optimizes Laravel for Lambda execution
- **LambdaMiddleware**: Adds Lambda-specific headers and optimizations
- **OPcache configuration**: Optimized for serverless execution
- **View caching**: Compiled views stored in `/tmp`

### Asset Management

- Static assets served via CloudFront CDN
- Optimized build process with Vite
- Cache headers for maximum performance

## 🧪 Local Development

### With Docker (Laravel Sail)

```bash
# Start containers
./vendor/bin/sail up -d

# Run migrations
./vendor/bin/sail artisan migrate

# Install dependencies
./vendor/bin/sail composer install
./vendor/bin/sail npm install

# Build assets
./vendor/bin/sail npm run dev
```

### Without Docker

```bash
# Start PHP development server
php artisan serve

# Watch assets
npm run dev
```

## 🔒 Security Considerations

### Environment Variables

- Store sensitive data in AWS Systems Manager Parameter Store
- Use AWS Secrets Manager for database credentials
- Never commit environment files to version control

### Lambda Security

- Functions run with minimal IAM permissions
- VPC configuration for database access
- HTTPS-only endpoints via API Gateway

## 📚 Useful Commands

### Environment Management

```bash
# Create new environment
./env-manager.sh create my-env

# Copy environment
./env-manager.sh copy production staging

# Remove deployment
./env-manager.sh remove old-env
```

### Deployment

```bash
# Deploy with verbose output
./deploy.sh production --verbose

# Deploy specific function
./vendor/bin/serverless deploy function -f web --stage=production
```

### Debugging

```bash
# Invoke function locally
./vendor/bin/serverless invoke local -f artisan --data '{"cli":"route:list"}'

# Test function
./vendor/bin/serverless invoke -f web --stage=dev
```

## 🆘 Troubleshooting

### Common Issues

1. **Cold Start Performance**: Implement warmup functions for production
2. **Memory Limits**: Adjust Lambda memory settings in `serverless.yml`
3. **Timeout Issues**: Increase timeout for long-running operations
4. **Database Connections**: Configure connection pooling for RDS

### Error Handling

- Check CloudWatch logs for detailed error information
- Use X-Ray tracing for performance debugging
- Monitor Lambda metrics in AWS Console

## 📝 License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
