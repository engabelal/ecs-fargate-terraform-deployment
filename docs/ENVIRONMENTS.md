# 🌍 Multi-Environment Setup

## Overview
This project supports multiple environments using the same wildcard SSL certificate.

---

## 🔐 SSL Certificate

**Certificate**: `*.awsapp.cloudycode.dev`  
**ARN**: `arn:aws:acm:eu-north-1:501235162976:certificate/9fe6f1d4-22c8-4918-8901-e396482d05a8`

This wildcard certificate covers:
- ✅ `dev.awsapp.cloudycode.dev`
- ✅ `staging.awsapp.cloudycode.dev`
- ✅ `awsapp.cloudycode.dev` (root)
- ✅ Any other subdomain: `*.awsapp.cloudycode.dev`

---

## 🌐 Environment URLs

### 🔵 Development
- **URL**: https://dev.awsapp.cloudycode.dev
- **Purpose**: Testing and development
- **Resources**: 
  - 1 task (256 CPU, 512 MB)
  - VPC: 10.0.0.0/16
- **Cost**: ~$28/month

### 🟡 Staging (Optional)
- **URL**: https://staging.awsapp.cloudycode.dev
- **Purpose**: Pre-production testing
- **Resources**: 
  - 1 task (256 CPU, 512 MB)
  - VPC: 10.2.0.0/16
- **Cost**: ~$28/month

### 🟢 Production
- **URL**: https://awsapp.cloudycode.dev
- **Purpose**: Live production environment
- **Resources**: 
  - 2 tasks (512 CPU, 1024 MB each)
  - VPC: 10.1.0.0/16
  - Auto-scaling enabled
- **Cost**: ~$50/month

---

## 📁 Environment Structure

```
terraform/environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars    # dev.awsapp.cloudycode.dev
│   └── outputs.tf
├── staging/                 # Optional
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars    # staging.awsapp.cloudycode.dev
│   └── outputs.tf
└── prod/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars    # awsapp.cloudycode.dev
    └── outputs.tf
```

---

## 🚀 Deployment Strategy

### Using Automation Scripts (Recommended)

**Initial Setup:**
```bash
# 1. Setup GitHub Actions OIDC
cd scripts/03-setup
./01-setup-github-actions-oidc.sh

# 2. Setup Terraform Backend
./02-setup-terraform-backend.sh

# 3. Deploy Infrastructure
./03-deploy-infrastructure.sh
```

**Deploy Application:**
```bash
# Build and push Docker image
cd scripts/02-deploy
./01-build-and-push-image.sh
```

**Cleanup:**
```bash
# Destroy infrastructure
cd scripts/01-cleanup
./01-destroy-infrastructure.sh
./02-cleanup-resources.sh
```

### Manual Deployment

**Development:**
```bash
cd terraform/environments/dev
terraform apply
```
- Deploys to: `dev.awsapp.cloudycode.dev`
- Auto-deploys on push to `main` branch (via GitHub Actions)

**Production:**
```bash
cd terraform/environments/prod
terraform apply
```
- Deploys to: `awsapp.cloudycode.dev`
- Manual deployment or auto-deploy on tag release

---

## 🔄 CI/CD Workflow

### Development Flow (Blue/Green)
```
Push to main → GitHub Actions → Build Docker → Push to ECR → 
Register Task Definition → CodeDeploy Blue/Green → Zero Downtime
```

**Deployment Steps:**
1. New tasks start in Green target group
2. Health checks pass
3. Traffic shifts from Blue to Green
4. Old tasks terminate after 5 minutes

### Production Flow
```
Create Release Tag → Build → ECR → CodeDeploy Blue/Green → Production
```

---

## 📊 Environment Comparison

| Feature | Dev | Staging | Prod |
|---------|-----|---------|------|
| **URL** | dev.awsapp.cloudycode.dev | staging.awsapp.cloudycode.dev | awsapp.cloudycode.dev |
| **Tasks** | 1 | 1 | 2 |
| **CPU** | 256 | 256 | 512 |
| **Memory** | 512 MB | 512 MB | 1024 MB |
| **Auto-scaling** | ❌ | ❌ | ✅ |
| **WAF** | ❌ | ❌ | ✅ |
| **Monitoring** | Basic | Basic | Advanced |
| **Cost/Month** | $28 | $28 | $50 |

---

## 🔧 Configuration Differences

### Dev Environment
```hcl
# terraform/environments/dev/terraform.tfvars
subdomain     = "dev.awsapp.cloudycode.dev"
task_cpu      = "256"
task_memory   = "512"
desired_count = 1
```

### Prod Environment
```hcl
# terraform/environments/prod/terraform.tfvars
subdomain     = "awsapp.cloudycode.dev"
task_cpu      = "512"
task_memory   = "1024"
desired_count = 2
```

---

## 🎯 Best Practices

### 1. **Separate AWS Accounts** (Recommended)
- Dev/Staging: AWS Account A
- Production: AWS Account B

### 2. **Separate VPCs** (Current Setup)
- Dev: 10.0.0.0/16
- Staging: 10.2.0.0/16
- Prod: 10.1.0.0/16

### 3. **Separate State Files**
Each environment has its own Terraform state in S3:
- `dev/terraform.tfstate`
- `staging/terraform.tfstate`
- `prod/terraform.tfstate`

### 4. **Environment Variables**
Use different DynamoDB tables per environment:
- Dev: `urls-dev`
- Staging: `urls-staging`
- Prod: `urls-prod`

---

## 🧪 Testing Flow

```
1. Develop locally
   ↓
2. Push to main → Deploy to dev.awsapp.cloudycode.dev
   ↓
3. Test on dev
   ↓
4. Merge to staging → Deploy to staging.awsapp.cloudycode.dev
   ↓
5. QA testing on staging
   ↓
6. Create release tag → Deploy to awsapp.cloudycode.dev
   ↓
7. Production live! 🎉
```

---

## 📝 Adding Staging Environment

```bash
# 1. Copy dev environment
cp -r terraform/environments/dev terraform/environments/staging

# 2. Update terraform.tfvars
# Change subdomain to: staging.awsapp.cloudycode.dev
# Change VPC CIDR to: 10.2.0.0/16

# 3. Deploy
cd terraform/environments/staging
terraform init
terraform apply

# 4. Update GitHub Actions
# Add staging workflow for staging branch
```

---

## 🔍 Monitoring Per Environment

### CloudWatch Logs
```bash
# Dev logs
aws logs tail /ecs/url-shortener-dev --follow

# Prod logs
aws logs tail /ecs/url-shortener-prod --follow
```

### Service Status
```bash
# Dev
aws ecs describe-services \
  --cluster url-shortener-cluster-dev \
  --services url-shortener-service-dev

# Prod
aws ecs describe-services \
  --cluster url-shortener-cluster-prod \
  --services url-shortener-service-prod
```

---

## 💰 Cost Optimization

### Development
- Use spot instances (not available for Fargate)
- Scale down to 0 tasks after hours
- Use smaller task sizes

### Production
- Enable auto-scaling
- Use Savings Plans
- Monitor and optimize

---

## 🎉 Summary

✅ **One SSL Certificate** covers all environments  
✅ **Separate infrastructure** per environment  
✅ **Automated deployments** per environment  
✅ **Cost-effective** multi-environment setup  

**Current Setup:**
- 🔵 Dev: https://dev.awsapp.cloudycode.dev
- 🟢 Prod: https://awsapp.cloudycode.dev

**Ready to add Staging?** Just copy dev and update the subdomain! 🚀
