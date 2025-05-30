# AWS Setup Guide for Laravel Serverless

## 1. AWS Account Setup

### Option A: Using AWS CLI Configure (Recommended for Development)
```bash
aws configure
```
You'll be prompted for:
- **AWS Access Key ID**: Your AWS access key
- **AWS Secret Access Key**: Your AWS secret key
- **Default region**: e.g., `us-east-1` or `us-west-2`
- **Default output format**: `json`

### Option B: Using Environment Variables
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

### Option C: Using AWS Profiles (Recommended for Multiple Environments)
```bash
# Configure development profile
aws configure --profile dev
aws configure --profile staging  
aws configure --profile production

# Use specific profile
export AWS_PROFILE=dev
```

## 2. Required AWS Services

Your serverless Laravel app will use these AWS services:

### Core Services (Required)
- **Lambda** - For running your PHP application
- **API Gateway** - For HTTP routing to Lambda
- **CloudFormation** - For infrastructure management
- **S3** - For asset storage and deployment artifacts

### Additional Services (Optional but Recommended)
- **RDS/Aurora Serverless** - For MySQL database
- **DynamoDB** - For cache/sessions (faster than RDS for cache)
- **SQS** - For job queues
- **SES** - For email sending
- **CloudWatch** - For logging and monitoring

## 3. AWS Resource Creation Options

### Option A: Manual Setup (Traditional)
1. Create RDS MySQL instance
2. Create DynamoDB tables
3. Create SQS queues
4. Configure SES for email

### Option B: Infrastructure as Code (Recommended)
Your `serverless.yml` can create AWS resources automatically:

```yaml
resources:
  Resources:
    # DynamoDB table for cache/sessions
    CacheTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: \${self:service}-\${self:provider.stage}-cache
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
```

## 4. Quick Start Commands

After configuring AWS CLI:

```bash
# Test AWS connection
aws sts get-caller-identity

# Deploy to development
./deploy.sh dev

# Check deployment status
serverless info --stage dev
```

## 5. Cost Optimization Tips

- Use **Aurora Serverless v2** for database (scales to zero)
- Use **DynamoDB** for cache/sessions (pay per request)
- Use **SQS** for queues (very cheap)
- Monitor costs with AWS Cost Explorer

## 6. Security Best Practices

- Use **IAM roles** instead of hardcoded credentials in production
- Enable **VPC** for database security
- Use **AWS Secrets Manager** for sensitive data
- Enable **CloudTrail** for audit logging

## Next Steps After AWS Setup

1. Update environment files with real AWS resource endpoints
2. Run pre-deployment check: `./pre-deploy-check.sh`
3. Deploy to development: `./deploy.sh dev`
4. Test the deployed application
5. Configure staging and production environments
