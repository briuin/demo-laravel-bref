#!/bin/bash

# Laravel Serverless Deployment Script
# Usage: ./deploy.sh [stage] [options]
# Example: ./deploy.sh dev
# Example: ./deploy.sh production --verbose

set -e

# Default values
STAGE=${1:-dev}
VERBOSE=""

# Parse additional arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Deploying Laravel application to $STAGE environment..."

# Check if environment file exists
if [[ ! -f "env.$STAGE.yml" ]]; then
    echo "❌ Environment file env.$STAGE.yml not found!"
    echo "Available environments:"
    ls env.*.yml 2>/dev/null | sed 's/env\.\(.*\)\.yml/  - \1/' || echo "  No environment files found"
    exit 1
fi

echo "📋 Environment file: env.$STAGE.yml"

# Install dependencies
echo "📦 Installing PHP dependencies..."
composer install --optimize-autoloader --no-dev

# Build frontend assets (if applicable)
if [[ -f "package.json" ]]; then
    echo "🎨 Building frontend assets..."
    npm ci
    npm run build
fi

# Clear and cache Laravel configuration
echo "⚙️  Optimizing Laravel..."
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Deploy with Serverless Framework
echo "☁️  Deploying to AWS Lambda..."
./vendor/bin/serverless deploy --stage=$STAGE $VERBOSE

echo "✅ Deployment to $STAGE completed successfully!"
echo ""
echo "🔗 Your application endpoints:"
echo "   Web: Check the AWS Console for the API Gateway URL"
echo "   Artisan: aws lambda invoke --function-name laravel-serverless-env-$STAGE-artisan"
echo ""
echo "💡 Useful commands:"
echo "   - View logs: ./vendor/bin/serverless logs -f web --stage=$STAGE"
echo "   - Run artisan: ./vendor/bin/serverless invoke -f artisan --stage=$STAGE --data '{\"cli\":\"migrate --force\"}'"
echo "   - Remove deployment: ./vendor/bin/serverless remove --stage=$STAGE"
