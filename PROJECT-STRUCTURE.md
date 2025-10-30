# 📁 Project Structure - Layered Terraform

## Directory Layout

```
ecs-fargate-terraform-deployment/
│
├── app/                              # Application Code
│   ├── src/
│   │   ├── main.py
│   │   └── ddb.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── docker-compose.yml
│
├── terraform/
│   │
│   ├── modules/                      # Reusable Terraform Modules
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── security/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── iam/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── dynamodb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── alb/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── ecs/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   ├── codedeploy/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── route53/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   │
│   ├── environments/                 # Environment-specific configs
│   │   │
│   │   ├── dev/
│   │   │   ├── main.tf              # Calls modules
│   │   │   ├── variables.tf         # Environment variables
│   │   │   ├── terraform.tfvars     # Dev values (gitignored)
│   │   │   ├── backend.tf           # S3 backend config
│   │   │   ├── provider.tf          # AWS provider
│   │   │   └── outputs.tf           # Environment outputs
│   │   │
│   │   ├── staging/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── terraform.tfvars     # Staging values (gitignored)
│   │   │   ├── backend.tf
│   │   │   ├── provider.tf
│   │   │   └── outputs.tf
│   │   │
│   │   └── prod/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── terraform.tfvars     # Prod values (gitignored)
│   │       ├── backend.tf
│   │       ├── provider.tf
│   │       └── outputs.tf
│   │
│   └── backend-setup/                # One-time S3 backend setup
│       ├── main.tf                   # Creates S3 + DynamoDB
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/
│   ├── appspec.yml                   # CodeDeploy AppSpec
│   ├── setup-backend.sh              # Script to create S3 backend
│   └── deploy.sh                     # Deployment helper script
│
├── docs/
│   ├── PROJECT-PLAN-V2.md
│   ├── COMPARISON.md
│   └── architecture.md
│
├── .gitignore
└── README.md
```

---

## 🗂️ S3 Backend Structure

### Single S3 Bucket with Multiple State Files:

```
s3://terraform-state-url-shortener-501235162976/
│
├── dev/
│   └── terraform.tfstate
│
├── staging/
│   └── terraform.tfstate
│
└── prod/
    └── terraform.tfstate
```

### DynamoDB Lock Table (Shared):
```
Table: terraform-state-lock
Key: LockID (String)
```

---

## 🔧 Backend Configuration per Environment

### Dev (`terraform/environments/dev/backend.tf`):
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-url-shortener-501235162976"
    key            = "dev/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Staging (`terraform/environments/staging/backend.tf`):
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-url-shortener-501235162976"
    key            = "staging/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Prod (`terraform/environments/prod/backend.tf`):
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-url-shortener-501235162976"
    key            = "prod/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## 🎯 Environment Differences

| Resource | Dev | Staging | Prod |
|----------|-----|---------|------|
| **ECS Tasks** | 1 | 1 | 2 |
| **CPU** | 256 | 256 | 512 |
| **Memory** | 512 | 512 | 1024 |
| **Domain** | dev.awsapp.cloudycode.dev | staging.awsapp.cloudycode.dev | awsapp.cloudycode.dev |
| **DynamoDB** | urls-dev | urls-staging | urls |
| **Log Retention** | 3 days | 7 days | 30 days |

---

## 🚀 Workflow

### 1. Setup Backend (One-time):
```bash
cd terraform/backend-setup
terraform init
terraform apply
```

### 2. Deploy to Dev:
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### 3. Deploy to Staging:
```bash
cd terraform/environments/staging
terraform init
terraform plan
terraform apply
```

### 4. Deploy to Prod:
```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

---

## 📝 Module Reusability

All environments use the **same modules** but with **different variables**:

```hcl
# terraform/environments/prod/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  environment         = var.environment  # "prod"
}
```

---

## 🔐 Security Best Practices

1. **Separate State Files**: Each environment has isolated state
2. **State Locking**: DynamoDB prevents concurrent modifications
3. **Encryption**: S3 bucket encrypted at rest
4. **Versioning**: S3 versioning enabled for state recovery
5. **No Secrets in Git**: `.tfvars` files are gitignored

---

## 💡 Benefits of This Structure

✅ **Isolation**: Dev changes don't affect prod  
✅ **Reusability**: Same modules for all environments  
✅ **Scalability**: Easy to add new environments  
✅ **Safety**: State locking prevents conflicts  
✅ **Disaster Recovery**: S3 versioning for rollback  
✅ **Cost Optimization**: Different sizes per environment  

---

## 📋 Next Steps

1. Create backend setup
2. Create modules
3. Create environment configs
4. Deploy to dev first
5. Test thoroughly
6. Promote to staging
7. Finally deploy to prod
