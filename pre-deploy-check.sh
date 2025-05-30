#!/bin/bash

# Pre-deployment checklist for Laravel Serverless
# Usage: ./pre-deploy-check.sh [stage]

set -e

STAGE=${1:-dev}
ERRORS=0

echo "🔍 Pre-deployment checklist for $STAGE environment"
echo "=================================================="

# Check if environment file exists
echo -n "✓ Environment file (env.$STAGE.yml)... "
if [[ ! -f "env.$STAGE.yml" ]]; then
    echo "❌ MISSING"
    echo "  Create env.$STAGE.yml or run: ./env-manager.sh create $STAGE"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Found"
fi

# Check AWS CLI
echo -n "✓ AWS CLI configuration... "
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ FAILED"
    echo "  Configure AWS CLI: aws configure"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Configured"
fi

# Check Serverless Framework
echo -n "✓ Serverless Framework... "
if ! command -v serverless &> /dev/null; then
    echo "❌ MISSING"
    echo "  Install: npm install -g serverless"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Installed ($(serverless --version))"
fi

# Check PHP dependencies
echo -n "✓ PHP dependencies... "
if [[ ! -d "vendor" ]] || [[ ! -f "vendor/autoload.php" ]]; then
    echo "❌ MISSING"
    echo "  Run: composer install --optimize-autoloader --no-dev"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Installed"
fi

# Check if we have Node.js dependencies (for asset building)
echo -n "✓ Node.js dependencies... "
if [[ -f "package.json" ]]; then
    if [[ ! -d "node_modules" ]]; then
        echo "❌ MISSING"
        echo "  Run: npm ci"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Installed"
    fi
else
    echo "⚠️  No package.json found (skipped)"
fi

# Check if assets are built
echo -n "✓ Frontend assets... "
if [[ -f "package.json" ]]; then
    if [[ ! -d "public/build" ]] || [[ ! -f "public/build/manifest.json" ]]; then
        echo "❌ NOT BUILT"
        echo "  Run: npm run build"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Built"
    fi
else
    echo "⚠️  No package.json found (skipped)"
fi

# Check Laravel optimizations
echo -n "✓ Laravel config cache... "
if [[ ! -f "bootstrap/cache/config.php" ]]; then
    echo "⚠️  NOT CACHED"
    echo "  Recommend: php artisan config:cache"
else
    echo "✅ Cached"
fi

echo -n "✓ Laravel route cache... "
if [[ ! -f "bootstrap/cache/routes-v7.php" ]]; then
    echo "⚠️  NOT CACHED"
    echo "  Recommend: php artisan route:cache"
else
    echo "✅ Cached"
fi

# Check environment-specific settings
echo -n "✓ Environment-specific APP_KEY... "
if grep -q "your-.*-app-key" "env.$STAGE.yml" 2>/dev/null; then
    echo "❌ PLACEHOLDER"
    echo "  Generate: php artisan key:generate --show"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Set"
fi

echo -n "✓ Environment-specific database... "
if grep -q "your-.*-db-host" "env.$STAGE.yml" 2>/dev/null; then
    echo "❌ PLACEHOLDER"
    echo "  Update database configuration in env.$STAGE.yml"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Configured"
fi

# Check file permissions
echo -n "✓ Script permissions... "
if [[ ! -x "deploy.sh" ]] || [[ ! -x "env-manager.sh" ]]; then
    echo "❌ INCORRECT"
    echo "  Run: chmod +x deploy.sh env-manager.sh"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Correct"
fi

echo ""
echo "=================================================="

if [[ $ERRORS -eq 0 ]]; then
    echo "🎉 All checks passed! Ready to deploy to $STAGE"
    echo ""
    echo "Next steps:"
    echo "  ./deploy.sh $STAGE"
    echo "  or"
    echo "  ./env-manager.sh deploy $STAGE"
    exit 0
else
    echo "❌ Found $ERRORS issue(s). Please fix them before deployment."
    exit 1
fi
