# 🚀 ECS Fargate Terraform Deployment

> **Status**: 🚧 Coming Soon - Under Development

## 📋 Project Summary

Production-ready URL shortener deployed on **AWS ECS Fargate** using **Terraform** Infrastructure as Code with **Blue/Green deployment** strategy.

### Key Features:
- ✅ **Layered Terraform** (dev/staging/prod environments)
- ✅ **Blue/Green Deployment** with AWS CodeDeploy (zero-downtime)
- ✅ **ECS Fargate** serverless containers
- ✅ **Application Load Balancer** with HTTPS
- ✅ **DynamoDB** for data persistence
- ✅ **Shared S3 Backend** for state management
- ✅ **Reusable Terraform Modules**

### Tech Stack:
- **App**: Python FastAPI
- **Infrastructure**: AWS ECS Fargate, ALB, Route53, DynamoDB
- **IaC**: Terraform (modular architecture)
- **Deployment**: CodeDeploy (Canary: 10% → 100%)
- **Region**: eu-north-1

### Architecture:
```
User → Route53 → ALB (HTTPS) → ECS Fargate (Blue/Green) → DynamoDB
```

---

**Coming Soon**: Full implementation with step-by-step deployment guide.

**Domain**: `awsapp.cloudycode.dev`
