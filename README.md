# 🚀 ECS Fargate Terraform Deployment - URL Shortener

> **Status**: ✅ Live & Production Ready

## 📋 Project Summary

Production-ready URL shortener deployed on **AWS ECS Fargate** using **Terraform** Infrastructure as Code with **fully automated CI/CD pipeline**.

### Key Features:
- ✅ **Fully Automated CI/CD** (Push → Build → Deploy)
- ✅ **Blue/Green Deployment** with AWS CodeDeploy
- ✅ **ECS Fargate** serverless containers
- ✅ **Application Load Balancer** with HTTPS
- ✅ **DynamoDB** for data persistence
- ✅ **S3 Backend** with DynamoDB locking for Terraform state
- ✅ **Reusable Terraform Modules** (9 modules)
- ✅ **GitHub Actions** with OIDC authentication
- ✅ **Multi-environment Support** (dev/staging/prod)

### Tech Stack:
- **App**: Python FastAPI + Beautiful Web UI
- **Infrastructure**: AWS ECS Fargate, ALB, Route53, DynamoDB, ACM, CodeDeploy
- **IaC**: Terraform (modular architecture)
- **CI/CD**: GitHub Actions with OIDC
- **Deployment**: Blue/Green with CodeDeploy
- **Region**: eu-north-1

### Architecture:
```
User → Route53 → ALB (HTTPS) → Blue/Green Target Groups → ECS Fargate → DynamoDB
                    ↓                      ↓
              SSL Certificate          CodeDeploy
```

### Live Demo:
- 🔵 **Dev**: https://dev.awsapp.cloudycode.dev
- 🟢 **Prod**: https://awsapp.cloudycode.dev

### Deployment Flow:
```
Push to main → GitHub Actions → Build Docker → Push to ECR → CodeDeploy Blue/Green → Live!
```

---

## 🚀 Quick Start

### Prerequisites
- AWS Account
- Terraform >= 1.0
- AWS CLI configured
- Domain with Route53 hosted zone
- SSL certificate in ACM

### 1. Setup Backend (One-time)
```bash
cd terraform/backend-setup
terraform init
terraform apply
```

### 2. Deploy Infrastructure
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 3. Setup GitHub Actions
- Create OIDC provider in AWS
- Create IAM role: `github-actions-ecs-deploy`
- Add secrets to GitHub repository

### 4. Deploy Application
```bash
# Push to main branch
git add .
git commit -m "Deploy app"
git push origin main

# GitHub Actions will automatically:
# 1. Build Docker image
# 2. Push to ECR
# 3. Register new task definition
# 4. Trigger CodeDeploy Blue/Green deployment
# 5. Zero downtime update!
```

---

## 📁 Project Structure

```
.
├── app/
│   ├── src/main.py          # FastAPI application
│   ├── Dockerfile           # Multi-stage Docker build
│   └── requirements.txt     # Python dependencies
├── terraform/
│   ├── backend-setup/       # S3 + DynamoDB for state
│   ├── modules/
│   │   ├── vpc/            # VPC with public subnets
│   │   ├── security/       # Security groups
│   │   ├── iam/            # IAM roles & policies
│   │   ├── dynamodb/       # DynamoDB table
│   │   ├── alb/            # Application Load Balancer
│   │   ├── ecs/            # ECS Fargate cluster & service
│   │   ├── codedeploy/     # CodeDeploy for Blue/Green
│   │   └── route53/        # DNS records
│   └── environments/
│       └── dev/            # Dev environment config
├── .github/workflows/
│   ├── build-and-push.yml  # Automated build & deploy
│   └── security-scan.yml   # Trivy & Checkov scans
└── scripts/
    └── build-and-push.sh   # Manual build script
```

---

## 🏗️ Infrastructure Modules

### 1. VPC Module
- VPC with public subnets across 2 AZs
- Internet Gateway
- Route tables

### 2. Security Module
- ALB security group (80, 443)
- ECS security group (8000)

### 3. IAM Module
- ECS task execution role
- ECS task role (DynamoDB access)
- CodeDeploy role (if needed)

### 4. DynamoDB Module
- Table: `urls-dev`
- Hash key: `short_code`
- On-demand billing

### 5. ALB Module
- Application Load Balancer
- Blue target group
- Green target group
- HTTPS listener (SSL certificate)
- HTTP → HTTPS redirect

### 6. ECS Module
- Fargate cluster
- Task definition (256 CPU, 512 Memory)
- Service with CODE_DEPLOY controller
- CloudWatch logs

### 7. CodeDeploy Module
- CodeDeploy application (ECS)
- Deployment group
- Blue/Green deployment config
- Auto rollback on failure

### 8. Route53 Module
- A record with ALB alias
- Domain: awsapp.cloudycode.dev

---

## 🔄 CI/CD Pipeline

### Automated Workflow
1. **Trigger**: Push to `main` branch (app/ changes)
2. **Build**: Docker image with multi-stage build
3. **Tag**: 3 tags (version, SHA, latest)
4. **Push**: To ECR repository
5. **Register**: New ECS task definition
6. **Deploy**: CodeDeploy Blue/Green deployment
7. **Update**: Zero downtime traffic shift

### Deployment Strategy
- **Type**: Blue/Green with CodeDeploy
- **Traffic Shift**: Instant (CodeDeployDefault.ECSAllAtOnce)
- **Health Check**: `/health` endpoint
- **Rollback**: Automatic on failure
- **Termination**: Blue tasks after 5 minutes

### Security Scanning
- **Trivy**: Container vulnerability scanning
- **Checkov**: IaC security scanning

---

## 🔐 Security

- ✅ HTTPS only (HTTP redirects to HTTPS)
- ✅ SSL certificate from ACM
- ✅ Security groups with least privilege
- ✅ IAM roles with minimal permissions
- ✅ No hardcoded credentials
- ✅ OIDC authentication for GitHub Actions
- ✅ Container vulnerability scanning
- ✅ IaC security scanning

---

## 📊 Monitoring

### CloudWatch Logs
```bash
aws logs tail /ecs/url-shortener-dev --follow
```

### ECS Service Status
```bash
aws ecs describe-services \
  --cluster url-shortener-cluster-dev \
  --services url-shortener-service-dev \
  --region eu-north-1
```

### Health Check
```bash
curl https://awsapp.cloudycode.dev/health
```

---

## 🎯 Features

### Application
- ✨ Beautiful gradient UI
- 🔗 URL shortening with DynamoDB
- 📊 Real-time statistics
- 📋 One-click copy
- ⚡ Fast & responsive
- 🏥 Health check endpoint

### Infrastructure
- 🚀 Fully automated deployment
- 🔄 Zero downtime updates
- 📦 Modular Terraform architecture
- 🔐 Secure by default
- 📈 Scalable & production-ready
- 🌍 Multi-environment support

---

## 💰 Cost Optimization

- **ECS Fargate**: Pay per second (1 task = ~$10/month)
- **ALB**: ~$16/month
- **DynamoDB**: On-demand (pay per request)
- **Route53**: $0.50/month per hosted zone
- **S3**: Minimal (state files)
- **Total**: ~$30-40/month for dev environment

---

## 📚 Documentation

- 📖 [Setup Guide](docs/SETUP-GUIDE.md) - Complete setup instructions
- 🚀 [Deployment Guide](docs/DEPLOYMENT.md) - Deployment and troubleshooting
- 🌍 [Multi-Environment Setup](docs/ENVIRONMENTS.md) - Dev/Staging/Prod configuration

---

## 📝 License

MIT License - feel free to use for your projects!

---

## 👤 Author

**Ahmed Belal**
- GitHub: [@engabelal](https://github.com/engabelal)
- Project: [ecs-fargate-terraform-deployment](https://github.com/engabelal/ecs-fargate-terraform-deployment)

---

⭐ If you find this project helpful, please give it a star!
