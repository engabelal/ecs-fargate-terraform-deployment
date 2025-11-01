# 🚀 START HERE - Quick Setup Guide

Follow these steps in order to deploy your ECS Fargate application from scratch.

---

## 📋 Prerequisites

Before you start, make sure you have:

- [ ] AWS Account with admin access
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform installed (v1.0+)
- [ ] Docker installed
- [ ] GitHub account
- [ ] Domain name (optional, for custom domain)

---

## 🎯 Step-by-Step Setup

### Step 1: Configure Your Values

Edit the following files with your information:

#### 1.1 GitHub Actions OIDC Script
```bash
# File: scripts/01-setup/01-setup-github-actions-oidc.sh
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"
GITHUB_REPO="your-username/your-repo-name"
```

#### 1.2 Terraform Variables
```bash
# File: terraform/environments/dev/terraform.tfvars

# Network Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones  = ["eu-north-1a", "eu-north-1b"]

# SSL Certificate (if using custom domain)
certificate_arn = "YOUR_ACM_CERTIFICATE_ARN"

# Domain Configuration (if using custom domain)
domain_name = "your-domain.com"
subdomain   = "dev.your-domain.com"

# ECR Configuration
ecr_repository_name = "url-shortener"

# Container Configuration
container_image = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/url-shortener:latest"

# Task Configuration
task_cpu      = "256"
task_memory   = "512"
desired_count = 1
```

---

### Step 2: Setup GitHub Actions (One-time)

```bash
cd scripts/01-setup
chmod +x 01-setup-github-actions-oidc.sh
./01-setup-github-actions-oidc.sh
```

**Output:** Copy the Role ARN and add it to `.github/workflows/build-and-push.yml`

---

### Step 3: Setup Terraform Backend (One-time)

```bash
chmod +x 02-setup-terraform-backend.sh
./02-setup-terraform-backend.sh
```

**What it creates:**
- S3 bucket: `terraform-state-{account-id}`
- DynamoDB table: `terraform-state-lock`

---

### Step 4: Deploy Infrastructure

```bash
chmod +x 03-deploy-infrastructure.sh
./03-deploy-infrastructure.sh
```

**Time:** ~5-7 minutes

**What it creates:**
- VPC with 2 public subnets
- Application Load Balancer (Blue/Green)
- ECS Cluster + Service
- DynamoDB table
- ECR repository
- CodeDeploy application
- Route53 DNS record (if domain configured)

---

### Step 5: Build and Push First Image

```bash
cd ../02-deploy
chmod +x 01-build-and-push-image.sh
./01-build-and-push-image.sh
```

**What it does:**
- Builds Docker image
- Pushes to ECR
- Tags as `latest`

---

### Step 6: Push to GitHub

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

**What happens:**
- GitHub Actions workflow triggers
- Builds new Docker image
- Registers new ECS task definition
- Triggers CodeDeploy Blue/Green deployment

---

### Step 7: Verify Deployment

1. **Check GitHub Actions:**
   - Go to your repo → Actions tab
   - Verify workflow completed successfully

2. **Check AWS Console:**
   - ECS → Clusters → url-shortener-dev
   - CodeDeploy → Deployments
   - EC2 → Load Balancers

3. **Test Application:**
   ```bash
   # Get ALB DNS from Terraform output
   curl https://dev.your-domain.com/health
   # or
   curl http://your-alb-dns-name/health
   ```

---

## 🎉 You're Done!

Your application is now running with:
- ✅ Blue/Green deployment
- ✅ Auto-scaling capability
- ✅ HTTPS enabled
- ✅ CI/CD pipeline

---

## 🔄 Daily Workflow

After initial setup, your workflow is simple:

1. **Make code changes** in `app/src/main.py`
2. **Commit and push** to GitHub
3. **GitHub Actions automatically:**
   - Builds new image
   - Deploys with Blue/Green strategy
   - Rolls back on failure

---

## 🧹 Cleanup (When Done)

To destroy everything and stop billing:

```bash
# Step 1: Destroy infrastructure
cd scripts/03-cleanup
chmod +x 01-destroy-infrastructure.sh
./01-destroy-infrastructure.sh

# Step 2: Cleanup remaining resources
chmod +x 02-cleanup-resources.sh
./02-cleanup-resources.sh
```

---

## 📚 Additional Resources

- **Detailed Documentation:** See `README.md`
- **Scripts Documentation:** See `scripts/README.md`
- **Deployment Guide:** See `docs/DEPLOYMENT.md`
- **Troubleshooting:** See `docs/SETUP-GUIDE.md`

---

## 💰 Cost Estimate

**Monthly Cost (dev environment):**
- ALB: ~$16/month
- ECS Fargate (1 task): ~$10/month
- DynamoDB (on-demand): ~$1/month
- Route53 Hosted Zone: $0.50/month
- **Total: ~$27-30/month**

**To minimize costs:**
- Use `desired_count = 1` for dev
- Delete resources when not in use
- Use on-demand pricing for DynamoDB

---

## 🆘 Common Issues

### Issue: "No default VPC available"
**Solution:** The project creates its own VPC, no action needed.

### Issue: "Certificate not found"
**Solution:** Create ACM certificate first or remove HTTPS listener from ALB module.

### Issue: "ECR repository not found"
**Solution:** Run Step 4 (deploy infrastructure) before Step 5 (build image).

### Issue: "GitHub Actions permission denied"
**Solution:** Verify Role ARN in workflow file matches output from Step 2.

---

**Need Help?** Check the detailed README.md or open an issue on GitHub.

**Made with ❤️ by Ahmed Belal**
