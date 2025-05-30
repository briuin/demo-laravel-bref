#!/bin/bash

# Environment Management Script for Laravel Serverless
# Usage: ./env-manager.sh [command] [stage] [args...]

set -e

COMMAND=${1:-help}
STAGE=${2:-dev}

case $COMMAND in
    "list")
        echo "📋 Available environments:"
        ls env.*.yml 2>/dev/null | sed 's/env\.\(.*\)\.yml/  - \1/' || echo "  No environment files found"
        ;;
        
    "show")
        if [[ -f "env.$STAGE.yml" ]]; then
            echo "📄 Environment configuration for $STAGE:"
            cat "env.$STAGE.yml"
        else
            echo "❌ Environment file env.$STAGE.yml not found!"
            exit 1
        fi
        ;;
        
    "create")
        if [[ -f "env.$STAGE.yml" ]]; then
            echo "❌ Environment file env.$STAGE.yml already exists!"
            echo "Use 'edit' command to modify existing environment."
            exit 1
        fi
        
        echo "🆕 Creating new environment: $STAGE"
        cp env.dev.yml "env.$STAGE.yml"
        echo "✅ Created env.$STAGE.yml (copied from dev template)"
        echo "🔧 Please edit the file to configure your $STAGE environment"
        ;;
        
    "copy")
        SOURCE=${3:-dev}
        if [[ ! -f "env.$SOURCE.yml" ]]; then
            echo "❌ Source environment env.$SOURCE.yml not found!"
            exit 1
        fi
        
        echo "📋 Copying $SOURCE environment to $STAGE..."
        cp "env.$SOURCE.yml" "env.$STAGE.yml"
        echo "✅ Created env.$STAGE.yml (copied from $SOURCE)"
        ;;
        
    "deploy")
        shift 2  # Remove command and stage from args
        echo "🚀 Deploying to $STAGE environment..."
        ./deploy.sh $STAGE "$@"
        ;;
        
    "logs")
        echo "📊 Fetching logs for $STAGE environment..."
        ./vendor/bin/serverless logs -f web --stage=$STAGE --tail
        ;;
        
    "invoke")
        ARTISAN_COMMAND=${3:-"--help"}
        echo "🔧 Running artisan command in $STAGE environment: $ARTISAN_COMMAND"
        ./vendor/bin/serverless invoke -f artisan --stage=$STAGE --data "{\"cli\":\"$ARTISAN_COMMAND\"}"
        ;;
        
    "remove")
        echo "⚠️  This will remove the entire $STAGE deployment from AWS!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🗑️  Removing $STAGE deployment..."
            ./vendor/bin/serverless remove --stage=$STAGE
            echo "✅ Deployment removed successfully!"
        else
            echo "❌ Removal cancelled"
        fi
        ;;
        
    "status")
        echo "📊 Checking status of $STAGE deployment..."
        ./vendor/bin/serverless info --stage=$STAGE
        ;;
        
    "help"|*)
        echo "🔧 Laravel Serverless Environment Manager"
        echo ""
        echo "Usage: ./env-manager.sh [command] [stage] [args...]"
        echo ""
        echo "Commands:"
        echo "  list                    - List all available environments"
        echo "  show [stage]           - Show environment configuration"
        echo "  create [stage]         - Create new environment"
        echo "  copy [stage] [source]  - Copy environment from source"
        echo "  deploy [stage]         - Deploy to environment"
        echo "  logs [stage]           - View environment logs"
        echo "  invoke [stage] [cmd]   - Run artisan command"
        echo "  remove [stage]         - Remove deployment"
        echo "  status [stage]         - Show deployment status"
        echo "  help                   - Show this help"
        echo ""
        echo "Examples:"
        echo "  ./env-manager.sh list"
        echo "  ./env-manager.sh show production"
        echo "  ./env-manager.sh create staging"
        echo "  ./env-manager.sh deploy dev"
        echo "  ./env-manager.sh invoke production 'migrate --force'"
        echo "  ./env-manager.sh logs staging"
        ;;
esac
