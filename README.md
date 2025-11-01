# 🚀 ECS Fargate Blue/Green Deployment with Terraform & CodeDeploy

> **Production-ready URL Shortener with Zero-Downtime Blue/Green Deployments**

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20Fargate-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/fargate/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Docker](https://img.shields.io/badge/Docker-Multi--stage-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![DynamoDB](https://img.shields.io/badge/DynamoDB-NoSQL-4053D6?logo=amazon-dynamodb&logoColor=white)](https://aws.amazon.com/dynamodb/)
[![CodeDeploy](https://img.shields.io/badge/CodeDeploy-Blue%2FGreen-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/codedeploy/)
[![ALB](https://img.shields.io/badge/ALB-Load%20Balancer-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/elasticloadbalancing/)
[![ECR](https://img.shields.io/badge/ECR-Container%20Registry-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/ecr/)
[![Route53](https://img.shields.io/badge/Route53-DNS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/route53/)
[![ACM](https://img.shields.io/badge/ACM-SSL%2FTLS-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/certificate-manager/)
[![CloudWatch](https://img.shields.io/badge/CloudWatch-Monitoring-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/cloudwatch/)
[![IAM](https://img.shields.io/badge/IAM-Security-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/iam/)
[![VPC](https://img.shields.io/badge/VPC-Networking-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/vpc/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎬 Quick Start

**New to this project?** → [📖 START HERE - Step-by-Step Guide](START-HERE.md)

---

## 📸 Live Application

![Application Screenshot](images/app_website.png)

**Live Demo:** https://dev.awsapp.cloudycode.dev

---

## 🎯 What is This Application?

### URL Shortener Service

A **production-grade URL shortening service** built with modern cloud-native technologies. Think of it as a mini bit.ly or TinyURL.

**What it does:**
- 🔗 **Shortens URLs** - Converts long URLs into short, shareable links
- 📊 **Tracks Statistics** - Monitors click counts and usage
- ⚡ **Fast & Reliable** - Built on AWS serverless infrastructure
- 🔒 **Secure** - HTTPS-only with SSL/TLS encryption

**Example:**
```
Long URL:  https://example.com/very/long/path/to/resource?param1=value&param2=value
           ↓
Short URL: https://dev.awsapp.cloudycode.dev/abc123
```

### Technology Stack

**Application Layer:**
- **FastAPI** - Modern Python web framework (async, high-performance)
- **Uvicorn** - ASGI server for production
- **Python 3.11** - Latest stable Python version

**Data Storage:**
- **DynamoDB** - NoSQL database for URL mappings
  - **Key:** `short_code` (e.g., "abc123")
  - **Attributes:** `original_url`, `created_at`, `click_count`
  - **Why DynamoDB?** Serverless, auto-scaling, single-digit millisecond latency

**Infrastructure:**
- **ECS Fargate** - Serverless containers (no EC2 to manage)
- **Application Load Balancer** - Distributes traffic, SSL termination
- **Route53** - DNS management
- **ECR** - Docker image registry
- **CloudWatch** - Logs and monitoring

**Deployment:**
- **Terraform** - Infrastructure as Code (9 modular components)
- **CodeDeploy** - Blue/Green deployments with zero downtime
- **GitHub Actions** - Automated CI/CD pipeline

### Data Flow

```
1. User Request
   ↓
2. Route53 DNS → Resolves domain to ALB
   ↓
3. Application Load Balancer → SSL termination, routes to ECS
   ↓
4. ECS Fargate Task → FastAPI application
   ↓
5. DynamoDB → Stores/retrieves URL mappings
   ↓
6. Response → Returns shortened URL or redirects
```

**Example API Endpoints:**
- `GET /` - Home page with UI
- `GET /health` - Health check for ALB
- `POST /api/shorten` - Create short URL
- `GET /{short_code}` - Redirect to original URL

---

## 📋 Table of Contents

- [What is This Application?](#-what-is-this-application)
- [Overview](#-overview)
- [Architecture](#-architecture)
- [Key Features](#-key-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Blue/Green Deployment](#-bluegreen-deployment)
- [Custom Domain Setup](#-custom-domain-setup)
- [Project Structure](#-project-structure)
- [Infrastructure Modules](#%EF%B8%8F-infrastructure-modules)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring & Rollback](#-monitoring--rollback)
- [Cost Breakdown](#-cost-breakdown)
- [Cleanup](#-cleanup)
- [Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This project demonstrates a **production-ready** deployment of a URL shortener application on **AWS ECS Fargate** using:

- ✅ **Infrastructure as Code** with Terraform (9 reusable modules)
- ✅ **Blue/Green Deployment** with AWS CodeDeploy
- ✅ **Zero Downtime** deployments with automatic rollback
- ✅ **CI/CD Pipeline** with GitHub Actions & OIDC
- ✅ **HTTPS** with custom domain and SSL certificate
- ✅ **Serverless Containers** with ECS Fargate
- ✅ **NoSQL Database** with DynamoDB

### 🐳 What is ECS Fargate?

**Amazon ECS (Elastic Container Service) Fargate** is a serverless compute engine for containers:

- **No EC2 Management** - AWS manages the infrastructure
- **Pay Per Use** - Only pay for vCPU and memory used
- **Auto Scaling** - Scales automatically based on demand
- **Secure** - Isolated compute environment per task
- **Integrated** - Works seamlessly with AWS services

**Why Fargate over EC2?**
- ❌ No server provisioning or patching
- ❌ No cluster capacity management
- ❌ No infrastructure maintenance
- ✅ Focus on application, not infrastructure

---

## 🏗️ Architecture

### Multi-Environment Architecture

```
                    ┌─────────────────────────────────────┐
                    │         Internet Users              │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────┴──────────────────────┐
                    │                                     │
                    ▼                                     ▼
        ┌───────────────────────┐           ┌───────────────────────┐
        │   Route53 DNS         │           │   Route53 DNS         │
        │ dev.awsapp.domain.com │           │ prod.awsapp.domain.com│
        └───────────┬───────────┘           └───────────┬───────────┘
                    │                                   │
                    ▼                                   ▼
        ┌───────────────────────┐           ┌───────────────────────┐
        │   DEV Environment     │           │   PROD Environment    │
        │   ┌───────────────┐   │           │   ┌───────────────┐   │
        │   │      ALB      │   │           │   │      ALB      │   │
        │   │  (HTTPS:443)  │   │           │   │  (HTTPS:443)  │   │
        │   │  ACM Cert     │   │           │   │  ACM Cert     │   │
        │   └───────┬───────┘   │           │   └───────┬───────┘   │
        │           │           │           │           │           │
        │   ┌───────┴───────┐   │           │   ┌───────┴───────┐   │
        │   │               │   │           │   │               │   │
        │   ▼               ▼   │           │   ▼               ▼   │
        │ ┌─────┐       ┌─────┐ │           │ ┌─────┐       ┌─────┐ │
        │ │Blue │◄─────►│Green│ │           │ │Blue │◄─────►│Green│ │
        │ │ TG  │       │ TG  │ │           │ │ TG  │       │ TG  │ │
        │ └──┬──┘       └──┬──┘ │           │ └──┬──┘       └──┬──┘ │
        │    │   CodeDeploy │   │           │    │   CodeDeploy │   │
        │    │  (Traffic    │   │           │    │  (Traffic    │   │
        │    │   Switch)    │   │           │    │   Switch)    │   │
        │    ▼              ▼   │           │    ▼              ▼   │
        │ ┌──────────────────┐  │           │ ┌──────────────────┐  │
        │ │  ECS Fargate     │  │           │ │  ECS Fargate     │  │
        │ │  Cluster (Dev)   │  │           │ │  Cluster (Prod)  │  │
        │ │ ┌──────┐ ┌──────┐│  │           │ │ ┌──────┐ ┌──────┐│  │
        │ │ │Task  │ │Task  ││  │           │ │ │Task  │ │Task  ││  │
        │ │ │(Old) │ │(New) ││  │           │ │ │(Old) │ │(New) ││  │
        │ │ └──┬───┘ └──┬───┘│  │           │ │ └──┬───┘ └──┬───┘│  │
        │ └────┼────────┼────┘  │           │ └────┼────────┼────┘  │
        └──────┼────────┼───────┘           └──────┼────────┼───────┘
               │        │                          │        │
               └────┬───┘                          └────┬───┘
                    │                                   │
                    ▼                                   ▼
            ┌───────────────┐                   ┌───────────────┐
            │  DynamoDB     │                   │  DynamoDB     │
            │  (urls-dev)   │                   │  (urls-prod)  │
            └───────────────┘                   └───────────────┘

                    ┌─────────────────────────────────┐
                    │   Shared Services (Region)      │
                    │  ┌──────────┐  ┌──────────┐    │
                    │  │   ECR    │  │    S3    │    │
                    │  │ (Images) │  │ (State)  │    │
                    │  └──────────┘  └──────────┘    │
                    └─────────────────────────────────┘
```

### Key Components

| Component | Purpose | Multi-Env |
|-----------|---------|----------|
| **Route53** | DNS routing to environments | ✅ Per environment |
| **ALB** | Load balancing & SSL termination | ✅ Per environment |
| **Target Groups** | Blue/Green traffic routing | ✅ Per environment |
| **ECS Fargate** | Serverless container runtime | ✅ Per environment |
| **CodeDeploy** | Blue/Green deployment automation | ✅ Per environment |
| **DynamoDB** | NoSQL database | ✅ Per environment |
| **ECR** | Container image registry | ✅ Shared |
| **S3** | Terraform state storage | ✅ Shared |

---

## ✨ Key Features

### Infrastructure
- 🔵 **Blue/Green Deployment** - Zero downtime with instant rollback
- 🏗️ **Modular Terraform** - 9 reusable, production-ready modules
- 🔐 **Security First** - HTTPS only, IAM roles, security groups
- 📦 **Serverless** - No EC2 instances to manage
- 🌍 **Multi-AZ** - High availability across 2 availability zones
- 🔄 **Auto Rollback** - Automatic rollback on deployment failure

### CI/CD
- ⚡ **Automated Pipeline** - Push to deploy in minutes
- 🔒 **OIDC Authentication** - No long-lived AWS credentials
- 🐳 **Multi-stage Docker** - Optimized container images
- 🔍 **Security Scanning** - Trivy & Checkov integration
- 📊 **CloudWatch Logs** - Centralized logging

### Application
- ✨ **Modern UI** - Beautiful gradient design
- 🔗 **URL Shortening** - Fast and reliable
- 📊 **Statistics** - Real-time URL tracking
- 🏥 **Health Checks** - ALB health monitoring
- ⚡ **High Performance** - DynamoDB for speed

---

## 📋 Prerequisites

Before you begin, ensure you have:

### Required
- ✅ **AWS Account** with admin access
- ✅ **Terraform** >= 1.0 ([Install](https://www.terraform.io/downloads))
- ✅ **AWS CLI** configured ([Install](https://aws.amazon.com/cli/))
- ✅ **Git** installed
- ✅ **Docker** (for local testing)

### For Custom Domain (Optional)
- ✅ **Domain Name** (e.g., example.com)
- ✅ **Route53 Hosted Zone** for your domain
- ✅ **ACM SSL Certificate** in the same region

> **💡 Tip:** You can use the project without a custom domain by accessing the ALB DNS directly.

---

## 🚀 Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/engabelal/ecs-fargate-terraform-deployment.git
cd ecs-fargate-terraform-deployment
```

### Step 2: Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: eu-north-1 (or your preferred region)
```

### Step 3: Setup Terraform Backend (One-time)

```bash
cd terraform/backend-setup
terraform init
terraform apply
```

**This creates:**
- S3 bucket for Terraform state
- DynamoDB table for state locking

### Step 4: Configure Variables

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
# Required
project_name = "url-shortener"
environment  = "dev"
aws_region   = "eu-north-1"

# Custom Domain (Optional - see Custom Domain Setup section)
domain_name     = "cloudycode.dev"           # Your domain
subdomain       = "dev.awsapp.cloudycode.dev" # Full subdomain
certificate_arn = "arn:aws:acm:..."          # Your ACM certificate ARN

# Container
container_image = "501235162976.dkr.ecr.eu-north-1.amazonaws.com/url-shortener:latest"

# Resources
task_cpu    = "256"
task_memory = "512"
desired_count = 1
```

### Step 5: Deploy Infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

**⏱️ Deployment time:** ~5-7 minutes

**This creates:**
- VPC with 2 public subnets
- Application Load Balancer
- Blue & Green Target Groups
- ECS Fargate Cluster & Service
- CodeDeploy Application
- DynamoDB Table
- Route53 DNS Record
- IAM Roles & Security Groups

### Step 6: Setup GitHub Actions (Optional)

For automated CI/CD:

1. **Create OIDC Provider in AWS:**
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

2. **Create IAM Role:** `github-actions-ecs-deploy`

3. **Add GitHub Secrets:**
   - `AWS_REGION`: eu-north-1
   - `ECR_REPOSITORY`: url-shortener

### Step 7: Deploy Application

**Option A: Manual (First Time)**
```bash
cd app
docker build -t url-shortener:latest .
# Push to ECR and update ECS service
```

**Option B: Automated (After GitHub Actions setup)**
```bash
git add .
git commit -m "Deploy application"
git push origin main
```

---

## 🔵🟢 Blue/Green Deployment

### How It Works

Blue/Green deployment provides **zero-downtime** updates with instant rollback capability.

#### Deployment Flow

1. **Current State (Blue is Live)**
   ```
   ALB → Blue Target Group → Tasks (v1.0) ✅ LIVE
         Green Target Group → Empty
   ```

2. **New Deployment Starts**
   ```
   ALB → Blue Target Group → Tasks (v1.0) ✅ LIVE (100% traffic)
         Green Target Group → Tasks (v2.0) 🔄 Starting
   ```

3. **Health Checks Pass**
   ```
   ALB → Blue Target Group → Tasks (v1.0) ⏳ Draining
         Green Target Group → Tasks (v2.0) ✅ LIVE (100% traffic)
   ```

4. **Cleanup (After 5 minutes)**
   ```
   ALB → Blue Target Group → Empty
         Green Target Group → Tasks (v2.0) ✅ LIVE
   ```

### Visual Proof

![CodeDeploy Deployment](images/codedeploy01.png)
*CodeDeploy deployment in progress*

![Blue/Green Switch](images/codedeploy02.png)
*Traffic shifting from Blue to Green*

![Deployment Complete](images/finishBluegreen.png)
*Successful Blue/Green deployment*

### Deployment Commands

**Trigger Deployment:**
```bash
# Make changes to app/
git add app/
git commit -m "Update application"
git push origin main
```

**Monitor Deployment:**
```bash
# Via AWS CLI
aws deploy get-deployment \
  --deployment-id <DEPLOYMENT_ID> \
  --region eu-north-1

# Via Console
# https://console.aws.amazon.com/codesuite/codedeploy/deployments
```

**Manual Rollback:**
```bash
# Stop current deployment (triggers rollback)
aws deploy stop-deployment \
  --deployment-id <DEPLOYMENT_ID> \
  --auto-rollback-enabled \
  --region eu-north-1
```

---

## 🌐 Custom Domain Setup

### Prerequisites

1. **Domain Name** - Purchase from Route53 or any registrar
2. **Route53 Hosted Zone** - Create for your domain
3. **SSL Certificate** - Request from ACM

### Step-by-Step Guide

#### 1. Create Route53 Hosted Zone

```bash
aws route53 create-hosted-zone \
  --name cloudycode.dev \
  --caller-reference $(date +%s)
```

**Note the Name Servers** and update them at your domain registrar.

#### 2. Request SSL Certificate

```bash
aws acm request-certificate \
  --domain-name "*.awsapp.cloudycode.dev" \
  --validation-method DNS \
  --region eu-north-1
```

**Validate Certificate:**
- Go to ACM Console
- Copy CNAME record
- Add to Route53 Hosted Zone
- Wait for validation (~5-10 minutes)

#### 3. Update Terraform Variables

```hcl
# terraform/environments/dev/terraform.tfvars
domain_name     = "cloudycode.dev"
subdomain       = "dev.awsapp.cloudycode.dev"
certificate_arn = "arn:aws:acm:eu-north-1:123456789:certificate/xxx"
```

#### 4. Apply Changes

```bash
terraform apply
```

#### 5. Verify

```bash
curl https://dev.awsapp.cloudycode.dev/health
```

### Without Custom Domain

If you don't have a domain, you can:

1. **Comment out Route53 module** in `main.tf`
2. **Access via ALB DNS:**
   ```bash
   terraform output alb_dns_name
   # url-shortener-alb-dev-xxx.eu-north-1.elb.amazonaws.com
   ```
3. **Use HTTP** (remove HTTPS listener or use self-signed cert)

---

## 📁 Project Structure

```
ecs-fargate-terraform-deployment/
├── app/
│   ├── src/
│   │   └── main.py              # FastAPI application
│   ├── Dockerfile               # Multi-stage Docker build
│   └── requirements.txt         # Python dependencies
│
├── terraform/
│   ├── backend-setup/           # S3 + DynamoDB for state
│   │   ├── main.tf
│   │   └── variables.tf
│   │
│   ├── modules/                 # Reusable Terraform modules
│   │   ├── vpc/                 # VPC, Subnets, IGW
│   │   ├── security/            # Security Groups
│   │   ├── iam/                 # IAM Roles & Policies
│   │   ├── dynamodb/            # DynamoDB Table
│   │   ├── ecr/                 # ECR Repository
│   │   ├── alb/                 # ALB + Blue/Green TGs
│   │   ├── ecs/                 # ECS Cluster & Service
│   │   ├── codedeploy/          # CodeDeploy App & DG
│   │   └── route53/             # DNS Records
│   │
│   └── environments/
│       └── dev/                 # Dev environment
│           ├── main.tf          # Module composition
│           ├── variables.tf     # Variable definitions
│           ├── terraform.tfvars # Variable values
│           └── outputs.tf       # Output values
│
├── .github/
│   └── workflows/
│       ├── build-and-push.yml   # CI/CD Pipeline
│       └── security-scan.yml    # Security scanning
│
├── images/                      # Screenshots
│   ├── app_website.png
│   ├── codedeploy01.png
│   ├── codedeploy02.png
│   └── finishBluegreen.png
│
├── appspec.yml                  # CodeDeploy specification
└── README.md                    # This file
```

---

## 🏗️ Infrastructure Modules

### 1. VPC Module (`terraform/modules/vpc/`)
- VPC with CIDR 10.0.0.0/16
- 2 Public Subnets across different AZs
- Internet Gateway
- Route Tables

### 2. Security Module (`terraform/modules/security/`)
- **ALB Security Group:** Ports 80, 443
- **ECS Security Group:** Port 8000 (from ALB only)

### 3. IAM Module (`terraform/modules/iam/`)
- **ECS Task Execution Role:** Pull images, write logs
- **ECS Task Role:** DynamoDB access
- **CodeDeploy Role:** ECS deployment permissions

### 4. DynamoDB Module (`terraform/modules/dynamodb/`)
- Table: `urls-{environment}`
- Hash Key: `short_code`
- Billing: On-demand

### 5. ECR Module (`terraform/modules/ecr/`)
- Repository: `url-shortener`
- Image Scanning: Enabled
- Lifecycle Policy: Keep last 10 images

### 6. ALB Module (`terraform/modules/alb/`)
- Application Load Balancer
- **Blue Target Group:** Production traffic
- **Green Target Group:** New deployments
- HTTPS Listener (Port 443)
- HTTP → HTTPS Redirect

### 7. ECS Module (`terraform/modules/ecs/`)
- Fargate Cluster
- Task Definition (256 CPU, 512 MB)
- Service with `CODE_DEPLOY` controller
- CloudWatch Log Group

### 8. CodeDeploy Module (`terraform/modules/codedeploy/`)
- Application: ECS platform
- Deployment Group
- Blue/Green Configuration
- Auto Rollback on failure

### 9. Route53 Module (`terraform/modules/route53/`)
- A Record (Alias to ALB)
- Subdomain configuration

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
Trigger: Push to main (app/ changes)
  ↓
1. Checkout Code
  ↓
2. Configure AWS Credentials (OIDC)
  ↓
3. Login to ECR
  ↓
4. Build Docker Image
   - Multi-stage build
   - Platform: linux/amd64
  ↓
5. Tag Image
   - Version tag (v20241101-123456)
   - Git SHA tag
   - Latest tag
  ↓
6. Push to ECR
  ↓
7. Register New Task Definition
   - Update image
   - Keep other settings
  ↓
8. Create CodeDeploy Deployment
   - AppSpec content
   - Blue/Green deployment
  ↓
9. Monitor Deployment
   - Health checks
   - Traffic shift
   - Cleanup
```

### Deployment Strategy

| Setting | Value |
|---------|-------|
| **Type** | Blue/Green |
| **Traffic Shift** | All at once (CodeDeployDefault.ECSAllAtOnce) |
| **Health Check** | `/health` endpoint |
| **Rollback** | Automatic on failure |
| **Termination Wait** | 5 minutes |

---

## 📊 Monitoring & Rollback

### CloudWatch Logs

```bash
# Tail logs in real-time
aws logs tail /ecs/url-shortener-dev --follow --region eu-north-1

# Filter errors
aws logs filter-log-events \
  --log-group-name /ecs/url-shortener-dev \
  --filter-pattern "ERROR" \
  --region eu-north-1
```

### ECS Service Status

```bash
aws ecs describe-services \
  --cluster url-shortener-cluster-dev \
  --services url-shortener-service-dev \
  --region eu-north-1 \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

### CodeDeploy Deployments

```bash
# List recent deployments
aws deploy list-deployments \
  --application-name url-shortener-dev \
  --deployment-group-name url-shortener-dg-dev \
  --region eu-north-1

# Get deployment details
aws deploy get-deployment \
  --deployment-id d-XXXXXXXXX \
  --region eu-north-1
```

### Manual Rollback

**Option 1: Stop Current Deployment**
```bash
aws deploy stop-deployment \
  --deployment-id d-XXXXXXXXX \
  --auto-rollback-enabled \
  --region eu-north-1
```

**Option 2: Via AWS Console**
1. Go to CodeDeploy Console
2. Select deployment
3. Click "Stop deployment"
4. Choose "Stop and roll back"

**Option 3: Redeploy Previous Version**
1. Go to CodeDeploy Console
2. Find previous successful deployment
3. Click "Redeploy"

---

## 💰 Cost Breakdown

### Monthly Costs (Dev Environment)

| Service | Usage | Cost |
|---------|-------|------|
| **ECS Fargate** | 1 task (0.25 vCPU, 0.5 GB) | ~$10 |
| **Application Load Balancer** | 1 ALB | ~$16 |
| **DynamoDB** | On-demand, low traffic | ~$1 |
| **Route53** | 1 hosted zone | $0.50 |
| **ECR** | <500 MB storage | Free |
| **CloudWatch Logs** | <5 GB | Free |
| **Data Transfer** | <1 GB | Free |
| **CodeDeploy** | ECS deployments | Free |
| **S3** | Terraform state | <$0.10 |
| **Total** | | **~$27-30/month** |

### Cost Optimization Tips

1. **Use Fargate Spot** - Save up to 70%
2. **Reduce Task Count** - Scale down in dev
3. **Delete Unused Resources** - Clean up regularly
4. **Use Reserved Capacity** - For production
5. **Enable S3 Lifecycle** - Delete old logs

---

## 🧹 Cleanup

### Destroy All Resources

```bash
cd terraform/environments/dev

# Destroy infrastructure
terraform destroy -auto-approve

# Delete ECR images (if needed)
aws ecr batch-delete-image \
  --repository-name url-shortener \
  --region eu-north-1 \
  --image-ids "$(aws ecr list-images --repository-name url-shortener --region eu-north-1 --query 'imageIds[*]' --output json)"

# Delete ECR repository
aws ecr delete-repository \
  --repository-name url-shortener \
  --region eu-north-1 \
  --force

# Delete Route53 hosted zone (if created)
aws route53 delete-hosted-zone --id Z08774931MPILO50GC8SS

# Delete S3 backend bucket
aws s3 rb s3://terraform-state-url-shortener-ACCOUNT_ID --force
```

### Verify Cleanup

```bash
# Check for remaining resources
aws ecs list-clusters --region eu-north-1
aws elbv2 describe-load-balancers --region eu-north-1
aws ec2 describe-vpcs --region eu-north-1
aws dynamodb list-tables --region eu-north-1
```

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Terraform State Lock

**Error:** `Error acquiring the state lock`

**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### 2. ECR Repository Not Empty

**Error:** `RepositoryNotEmptyException`

**Solution:**
```bash
# Delete all images first
aws ecr batch-delete-image \
  --repository-name url-shortener \
  --region eu-north-1 \
  --image-ids "$(aws ecr list-images --repository-name url-shortener --region eu-north-1 --query 'imageIds[*]' --output json)"
```

#### 3. Certificate Validation Pending

**Error:** Certificate stuck in "Pending validation"

**Solution:**
1. Check CNAME record in Route53
2. Ensure record matches ACM validation
3. Wait 5-10 minutes for DNS propagation

#### 4. ECS Tasks Failing Health Checks

**Error:** Tasks keep restarting

**Solution:**
```bash
# Check logs
aws logs tail /ecs/url-shortener-dev --follow

# Common causes:
# - Wrong container port (should be 8000)
# - Missing environment variables
# - DynamoDB permissions
```

#### 5. CodeDeploy Deployment Failed

**Error:** Deployment fails immediately

**Solution:**
1. Check ECS service has CODE_DEPLOY controller
2. Verify target groups exist
3. Check IAM role permissions
4. Review CloudWatch logs

---

## 📚 Additional Resources

### Documentation
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [CodeDeploy for ECS](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-steps-ecs.html)

### Related Projects
- [Terraform ECS Modules](https://github.com/terraform-aws-modules/terraform-aws-ecs)
- [AWS Samples](https://github.com/aws-samples)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Ahmed Belal**

- GitHub: [@engabelal](https://github.com/engabelal)
- LinkedIn: [Ahmed Belal](https://linkedin.com/in/engabelal)
- Email: eng.ahmed.belal@example.com

---

## ⭐ Show Your Support

If this project helped you, please give it a ⭐️!

---

## 🙏 Acknowledgments

- AWS for excellent documentation
- Terraform community for modules and examples
- FastAPI for the amazing framework

---

<div align="center">

**Made with ❤️ by Ahmed Belal**

[⬆ Back to Top](#-ecs-fargate-bluegreen-deployment-with-terraform--codedeploy)

</div>
