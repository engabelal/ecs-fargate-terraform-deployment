# 🚀 Automation Scripts

This directory contains automation scripts for setting up, deploying, and cleaning up the ECS Fargate infrastructure.

---

## 📂 Directory Structure

```
scripts/
├── 01-cleanup/     # Cleanup scripts
├── 02-deploy/      # Deployment scripts
├── 03-setup/       # Initial setup scripts
└── README.md       # This file
```

---

## 🔧 Setup Scripts

### 1. `03-setup/01-setup-github-actions-oidc.sh`

**Purpose:** Setup GitHub Actions OIDC provider and IAM role

**Prerequisites:**
- AWS CLI configured
- GitHub repository created

**Configuration Required:**
- `AWS_ACCOUNT_ID` - Your AWS Account ID
- `GITHUB_REPO` - Your GitHub repository (format: username/repo-name)

**Usage:**
```bash
cd scripts/03-setup
chmod +x 01-setup-github-actions-oidc.sh
./01-setup-github-actions-oidc.sh
```

**What it does:**
- Creates OIDC provider for GitHub Actions
- Creates IAM role: `github-actions-ecs-deploy`
- Attaches permissions policy from `terraform/modules/iam/github-actions-policy.json`
- Displays Role ARN for use in GitHub Actions workflow

---

### 2. `03-setup/02-setup-terraform-backend.sh`

**Purpose:** Setup Terraform backend (S3 + DynamoDB)

**Prerequisites:**
- AWS CLI configured
- Script 01 completed (optional)

**Usage:**
```bash
cd scripts/03-setup
chmod +x 02-setup-terraform-backend.sh
./02-setup-terraform-backend.sh
```

**What it does:**
- Creates S3 bucket for Terraform state
- Creates DynamoDB table for state locking
- Enables versioning and encryption

---

### 3. `03-setup/03-deploy-infrastructure.sh`

**Purpose:** Deploy AWS infrastructure using Terraform

**Prerequisites:**
- Script 02 completed
- `terraform.tfvars` configured in `terraform/environments/dev/`

**Required in terraform.tfvars:**
- `domain_name` - Your domain
- `subdomain` - Full subdomain (e.g., dev.awsapp.example.com)
- `certificate_arn` - ACM certificate ARN
- `vpc_cidr` - VPC CIDR block
- `public_subnet_cidrs` - List of subnet CIDRs
- `availability_zones` - List of AZs
- `container_image` - ECR image URL

**Usage:**
```bash
cd scripts/03-setup
chmod +x 03-deploy-infrastructure.sh
./03-deploy-infrastructure.sh
```

**What it does:**
- Initializes Terraform
- Validates configuration
- Plans and applies infrastructure
- Displays outputs (ALB DNS, etc.)

**Time:** ~5-7 minutes

---

## 🚀 Deploy Scripts

### 1. `02-deploy/01-build-and-push-image.sh`

**Purpose:** Build Docker image and push to ECR

**Prerequisites:**
- Docker installed
- AWS CLI configured
- ECR repository created (by script 03)

**Usage:**
```bash
cd scripts/02-deploy
chmod +x 01-build-and-push-image.sh
./01-build-and-push-image.sh
```

**What it does:**
- Logs in to ECR
- Builds Docker image for linux/amd64
- Tags image
- Pushes to ECR

---

## 🧹 Cleanup Scripts

### 1. `01-cleanup/01-destroy-infrastructure.sh`

**Purpose:** Destroy all AWS infrastructure

**Usage:**
```bash
cd scripts/01-cleanup
chmod +x 01-destroy-infrastructure.sh
./01-destroy-infrastructure.sh
```

**What it does:**
- Destroys all Terraform-managed resources
- Checks for remaining resources
- Provides next steps

**⚠️ WARNING:** This action cannot be undone!

---

### 2. `01-cleanup/02-cleanup-resources.sh`

**Purpose:** Cleanup remaining resources (ECR, Route53, S3)

**Configuration Required:**
- `HOSTED_ZONE_ID` - Your Route53 Hosted Zone ID (if exists)

**Usage:**
```bash
cd scripts/01-cleanup
chmod +x 02-cleanup-resources.sh
./02-cleanup-resources.sh
```

**What it does:**
- Deletes ECR images and repository
- Optionally deletes Route53 hosted zone
- Optionally deletes S3 backend bucket

---

## 📋 Complete Setup Flow

### First Time Setup:

```bash
# 1. Setup GitHub Actions
cd scripts/03-setup
./01-setup-github-actions-oidc.sh

# 2. Setup Terraform Backend
./02-setup-terraform-backend.sh

# 3. Configure terraform.tfvars
# Edit: terraform/environments/dev/terraform.tfvars

# 4. Deploy Infrastructure
./03-deploy-infrastructure.sh

# 5. Build and Push Image
cd ../02-deploy
./01-build-and-push-image.sh

# 6. Push to GitHub to trigger CI/CD
git push origin main
```

### Cleanup:

```bash
# 1. Destroy Infrastructure
cd scripts/01-cleanup
./01-destroy-infrastructure.sh

# 2. Cleanup Remaining Resources
./02-cleanup-resources.sh
```

---

## 🔍 Troubleshooting

### Script Permission Denied

```bash
chmod +x scripts/**/*.sh
```

### AWS CLI Not Configured

```bash
aws configure
```

### Terraform Not Found

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

---

## 📝 Notes

- All scripts use `set -e` to exit on error
- Scripts are idempotent where possible
- Color-coded output for better readability
- Interactive confirmations for destructive operations
- Automatic AWS Account ID detection

---

## 🤝 Contributing

Feel free to improve these scripts and submit PRs!

---

**Made with ❤️ by Ahmed Belal**
