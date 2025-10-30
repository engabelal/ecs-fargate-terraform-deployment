# 🚀 ECS Fargate Terraform Deployment - Final Plan
## Layered Architecture with Blue/Green Deployment

**Project**: URL Shortener on AWS ECS Fargate  
**Domain**: `awsapp.cloudycode.dev`  
**Region**: `eu-north-1`  
**Account**: `501235162976`  
**Strategy**: Layered Terraform + Blue/Green Deployment

---

## 📋 What We're Building

- ✅ **Layered Terraform** (dev/staging/prod)
- ✅ **Shared S3 Backend** (single bucket, multiple states)
- ✅ **Blue/Green Deployment** with CodeDeploy
- ✅ **Reusable Modules** across environments
- ✅ **ECS Fargate** + **DynamoDB** + **ALB HTTPS**

---

## 📁 Project Structure

```
ecs-fargate-terraform-deployment/
├── app/                              # FastAPI app
├── terraform/
│   ├── modules/                      # Reusable (8 modules)
│   │   ├── vpc/
│   │   ├── security/
│   │   ├── iam/
│   │   ├── dynamodb/
│   │   ├── alb/
│   │   ├── ecs/
│   │   ├── codedeploy/
│   │   └── route53/
│   ├── environments/                 # Environment-specific
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── backend-setup/                # One-time S3 setup
├── scripts/
├── docs/
└── README.md
```

---

## 🗂️ S3 Backend

**Single Bucket**:
```
s3://terraform-state-url-shortener-501235162976/
├── dev/terraform.tfstate
├── staging/terraform.tfstate
└── prod/terraform.tfstate
```

**Shared Lock Table**: `terraform-state-lock`

---

## 🎯 Implementation Steps

### Phase 0: Backend Setup (One-time)
```bash
cd terraform/backend-setup
terraform init && terraform apply
```

### Phase 1: Build 8 Modules
1. VPC
2. Security Groups
3. IAM Roles
4. DynamoDB
5. ALB (2 target groups)
6. ECS
7. CodeDeploy
8. Route53

### Phase 2: Deploy Environments
```bash
# Dev
cd terraform/environments/dev
terraform init && terraform apply

# Staging
cd terraform/environments/staging
terraform init && terraform apply

# Prod
cd terraform/environments/prod
terraform init && terraform apply
```

---

## 🔵🟢 Blue/Green Flow

1. Blue tasks running (production)
2. Deploy new version → Green tasks
3. Shift 10% traffic (5 min)
4. Shift 100% traffic
5. Terminate Blue tasks

---

## 💰 Cost

| Environment | Monthly Cost |
|-------------|--------------|
| Dev | $27.50 |
| Staging | $27.50 |
| Prod | $37.50 |
| **Total** | **$92.50** |

**Prod Only**: $38.50/month

---

## 📋 Environment Differences

| Resource | Dev | Prod |
|----------|-----|------|
| ECS Tasks | 1 | 2 |
| CPU | 256 | 512 |
| Memory | 512 | 1024 |
| Domain | dev.awsapp.cloudycode.dev | awsapp.cloudycode.dev |
| DynamoDB | urls-dev | urls |

---

## ✅ Next Steps

1. Setup backend
2. Create modules
3. Deploy to dev
4. Test
5. Deploy to prod

**Ready to build!** 🚀
