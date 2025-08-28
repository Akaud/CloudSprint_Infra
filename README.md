# CloudSprint Infrastructure - Terraform

## 🏗️ Overview

This repository contains Terraform infrastructure code for the CloudSprint project - a Wagtail CMS deployment on AWS with modern cloud architecture.

## 🎯 Architecture

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS Infrastructure                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   VPC & Network │  │   Compute Layer │  │   Data Layer    │ │
│  │                 │  │                 │  │                 │ │
│  │ • VPC           │  │ • ECS Cluster   │  │ • Aurora PG     │ │
│  │ • Private Subnet│  │ • ECS Service   │  │ • RDS Proxy     │ │
│  │ • Public Subnet │  │ • Task Def      │  │ • Secrets Mgr   │ │
│  │ • Security Grps │  │ • Security Grps │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Storage Layer │  │   CDN & Edge    │  │   Container     │ │
│  │                 │  │                 │  │                 │ │
│  │ • S3 Static     │  │ • CloudFront    │  │ • ECR Repo      │ │
│  │ • S3 Media      │  │ • OAI           │  │ • Docker Images │ │
│  │ • Lifecycle     │  │ • Distribution  │  │                 │ │
│  │ • Versioning    │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Network Architecture

- **VPC**: `vpc-030d14759050848aa` (provided by team)
- **Region**: `eu-west-1` (Ireland)
- **Private Subnet**: `10.0.1.0/24` (for Aurora, ECS)
- **Public Subnet**: `10.0.2.0/24` (for ALB, future use)

## 📁 Repository Structure

```
├── .github/
│   └── workflows/
│       ├── ci.yml          # CI pipeline (format, validate)
│       ├── cd.yml          # CD pipeline (deploy to prod)
│       └── destroy.yml     # Infrastructure cleanup
├── modules/
│   ├── vpc/               # VPC and subnet configuration
│   ├── aurora_dsql/       # Aurora Serverless v2 PostgreSQL
│   ├── ecs/               # ECS cluster and service
│   ├── ecr/               # Docker image repository
│   └── s3/                # S3 buckets with CloudFront
├── environments/
│   ├── dev/               # Development environment
│   └── prod/              # Production environment
└── README.md              # This documentation
```

## 🧩 Modules

### VPC Module (`modules/vpc/`)

**Purpose**: Network infrastructure using existing VPC

**Resources**:
- Data source for existing VPC
- Private subnet for Aurora and ECS
- Public subnet for future ALB

**Variables**:
- `ENV`: Environment name (dev/prod)
- `AWS_REGION`: AWS region

**Outputs**:
- `vpc_id`: VPC ID
- `private_subnet_ids`: List of private subnet IDs

### Aurora Module (`modules/aurora_dsql/`)

**Purpose**: PostgreSQL database with Aurora Serverless v2

**Resources**:
- Aurora PostgreSQL cluster
- RDS Proxy for connection pooling
- Security groups
- Secrets Manager for credentials
- IAM roles and policies

**Features**:
- Serverless v2 scaling (0.5 - 2.0 ACU)
- Auto-pause after 5 minutes of inactivity
- SSL/TLS encryption enabled by default
- Monitoring and performance insights

### ECS Module (`modules/ecs/`)

**Purpose**: Container orchestration for Wagtail CMS

**Resources**:
- ECS cluster
- ECS service
- Task definition
- Security groups
- IAM execution role

**Configuration**:
- Auto-scaling based on CPU/memory
- Health checks and load balancing
- Integration with ECR and Aurora

### S3 Module (`modules/s3/`)

**Purpose**: Object storage for static files and media

**Resources**:
- S3 buckets with versioning
- CloudFront distribution
- Origin Access Identity (OAI)
- Lifecycle policies
- Public access policies

**Buckets**:
- `wagtail-static-site-{env}`: Static website files
- `wagtail-media-{env}`: User uploads and media

### ECR Module (`modules/ecr/`)

**Purpose**: Docker image repository

**Resources**:
- ECR repository
- Image scanning
- Lifecycle policies

## 🚀 Getting Started

### Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0
- **Git** for repository management

### AWS Profile Setup

```bash
# Configure AWS profile for MFA
aws configure --profile dev-mfa

# Set environment variables
export AWS_PROFILE=dev-mfa
export AWS_REGION=eu-west-1
```

### Local Development

```bash
# Clone repository
git clone https://github.com/Akaud/CloudSprint_Infra.git
cd CloudSprint_Infra/environments/dev

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply infrastructure
terraform apply
```

### Environment Variables

```bash
# Required environment variables
ENV=dev                    # Environment name
AWS_REGION=eu-west-1       # AWS region
AWS_PROFILE=dev-mfa        # AWS profile
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

#### CI Pipeline (`.github/workflows/ci.yml`)

**Triggers**: Pull requests, pushes to main/develop
**Actions**:
- Terraform format check
- Terraform validation
- Security scanning

#### CD Pipeline (`.github/workflows/cd.yml`)

**Triggers**: Push to release branch
**Actions**:
- AWS authentication via OIDC
- Terraform apply to production
- Infrastructure deployment

#### Destroy Pipeline (`.github/workflows/destroy.yml`)

**Purpose**: Cleanup infrastructure
**Use**: Manual trigger for cleanup

## 🛠️ Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Modify Terraform modules
- Update environment configurations
- Test with `terraform plan`

### 3. Commit and Push

```bash
git add .
git commit -m "feat: Description of changes"
git push origin feature/your-feature-name
```

### 4. Create Pull Request

- Create PR on GitHub
- Wait for CI checks to pass
- Get code review approval
- Merge to develop/main

## 🔧 Common Commands

### Terraform Operations

```bash
# Initialize modules
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### State Management

```bash
# List resources
terraform state list

# Show resource details
terraform state show module.vpc.data.aws_vpc.existing

# Remove resource from state
terraform state rm module.resource_name
```

### Module Management

```bash
# Update modules
terraform get -update

# Reconfigure backend
terraform init -reconfigure
```

## 🚨 Troubleshooting

### Common Issues

#### VPC Limit Exceeded
```bash
# Check VPC count in region
aws ec2 describe-vpcs --region eu-west-1 --profile dev-mfa

# Use existing VPC instead of creating new one
```

#### SSL Parameter Errors
```bash
# Aurora PostgreSQL doesn't support custom SSL parameters
# SSL is enabled by default - remove custom parameters
```

#### Region Mismatch
```bash
# Ensure all resources use same region
# Check variables.tf and provider.tf
```

### Debug Commands

```bash
# Check AWS credentials
aws sts get-caller-identity --profile dev-mfa

# Verify VPC exists
aws ec2 describe-vpcs --vpc-ids vpc-030d14759050848aa

# Check subnet availability
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-030d14759050848aa"
```

## 📊 Monitoring and Logging

### CloudWatch Metrics

- **ECS**: CPU, memory utilization, task count
- **Aurora**: Database connections, query performance
- **S3**: Request counts, error rates
- **CloudFront**: Cache hit rates, origin latency

### Logs

- **ECS**: Application logs via CloudWatch Logs
- **Aurora**: Database logs via CloudWatch Logs
- **CloudFront**: Access logs to S3

## 🔒 Security

### IAM Roles and Policies

- **ECS Task Execution Role**: Minimal permissions for container execution
- **RDS Proxy Role**: Secrets Manager access for database credentials
- **GitHub Actions Role**: OIDC-based authentication for CI/CD

### Network Security

- **Security Groups**: Restrict access to necessary ports only
- **VPC**: Private subnets for sensitive resources
- **CloudFront**: HTTPS-only access with modern TLS

### Data Protection

- **Encryption**: S3, Aurora, and EBS encryption at rest
- **Secrets**: Database credentials stored in Secrets Manager
- **Access Control**: Principle of least privilege

## 📈 Scaling and Performance

### Auto-scaling

- **ECS**: CPU/memory-based scaling policies
- **Aurora**: Serverless v2 with 0.5-2.0 ACU range
- **S3**: Intelligent Tiering for cost optimization

### Performance Optimization

- **CloudFront**: Global CDN for static content
- **RDS Proxy**: Connection pooling for database
- **S3**: Lifecycle policies for storage optimization

## 💰 Cost Optimization

### Resource Optimization

- **Aurora Serverless**: Pay only for used capacity
- **S3 Lifecycle**: Automatic transition to cheaper storage
- **ECS Spot**: Use spot instances for non-critical workloads

### Monitoring Costs

- **AWS Cost Explorer**: Track spending by service
- **Billing Alerts**: Set up cost thresholds
- **Resource Tagging**: Track costs by environment/project

## 🤝 Contributing

### Code Standards

- **Terraform**: Use consistent formatting (`terraform fmt`)
- **Variables**: Use descriptive names and add descriptions
- **Tags**: Tag all resources with Environment and Purpose
- **Documentation**: Update README for significant changes

### Review Process

1. **Code Review**: All changes require PR review
2. **Testing**: Test changes in dev environment first
3. **Validation**: Ensure `terraform validate` passes
4. **Documentation**: Update relevant documentation

## 📞 Support

### Team Contacts

- **Infrastructure Team**: [Contact Info]
- **DevOps Lead**: [Contact Info]
- **Project Manager**: [Contact Info]

### Resources

- **AWS Documentation**: [AWS Docs]
- **Terraform Documentation**: [Terraform Docs]
- **Internal Wiki**: [Team Wiki]

## 📝 Changelog

### [Unreleased]
- Initial infrastructure setup
- VPC module with existing VPC
- Aurora Serverless v2 configuration
- ECS cluster for Wagtail CMS
- S3 buckets with CloudFront CDN

### [v1.0.0] - 2025-01-XX
- Initial release
- Complete infrastructure stack
- CI/CD pipeline setup
- Documentation and guides

---

**Last Updated**: January 2025  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: ~> 6.0