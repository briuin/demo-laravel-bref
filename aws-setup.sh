#!/bin/bash

# AWS Setup Helper for Laravel Serverless
# This script helps you configure AWS credentials and resources

set -e

echo "🔧 AWS Setup Helper for Laravel Serverless"
echo "==========================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first:"
    echo "   brew install awscli"
    exit 1
fi

echo "✅ AWS CLI found"

# Check current AWS configuration
echo ""
echo "📋 Current AWS Configuration:"
echo "-----------------------------"

if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials are configured"
    aws sts get-caller-identity --output table
    echo ""
    echo "Region: $(aws configure get region || echo 'Not set')"
else
    echo "❌ AWS credentials not configured"
    echo ""
    echo "To configure AWS credentials, you have several options:"
    echo ""
    echo "1. Using AWS CLI:"
    echo "   aws configure"
    echo ""
    echo "2. Using environment variables:"
    echo "   export AWS_ACCESS_KEY_ID=your_access_key"
    echo "   export AWS_SECRET_ACCESS_KEY=your_secret_key"
    echo "   export AWS_DEFAULT_REGION=us-east-1"
    echo ""
    echo "3. Using AWS profiles:"
    echo "   aws configure --profile serverless"
    echo "   export AWS_PROFILE=serverless"
    echo ""
    read -p "Would you like to configure AWS now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        aws configure
    fi
fi

echo ""
echo "🔧 Required AWS Services for Laravel Serverless:"
echo "-----------------------------------------------"
echo "✓ Lambda - For running your application"
echo "✓ API Gateway - For HTTP endpoints"
echo "✓ CloudFormation - For infrastructure management"
echo "✓ S3 - For deployment packages and static assets"
echo "✓ CloudWatch - For logging and monitoring"
echo "✓ RDS/Aurora - For database (recommended)"
echo "✓ DynamoDB - For cache/sessions (optional)"
echo "✓ SQS - For queues (optional)"
echo "✓ SES - For email sending (optional)"

echo ""
echo "🔑 Recommended IAM Policy for Serverless Deployment:"
echo "--------------------------------------------------"
cat << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*",
                "lambda:*",
                "apigateway:*",
                "s3:*",
                "iam:GetRole",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "logs:*",
                "events:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF

echo ""
echo "💡 Next Steps:"
echo "-------------"
echo "1. Ensure your AWS credentials are configured"
echo "2. Update your environment files (env.*.yml) with actual AWS resources"
echo "3. Run: ./pre-deploy-check.sh dev"
echo "4. Deploy: ./deploy.sh dev"
