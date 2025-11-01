# 🚀 START HERE - Complete Setup Guide

Follow this guide to deploy your ECS Fargate application from scratch in **~15 minutes**.

---

## 📊 Progress Tracker

```
☐ Prerequisites Check          (2 min)
☐ Step 1: Configure Values      (3 min)
☐ Step 2: Setup GitHub OIDC     (2 min)
☐ Step 3: Setup Terraform Backend (1 min)
☐ Step 4: Deploy Infrastructure  (5-7 min)
☐ Step 5: Build & Push Image     (2 min)
☐ Step 6: Verify Deployment      (1 min)
✅ Done!
```

**Total Time:** ~15 minutes

---

## 📋 Prerequisites

Before you start, ensure you have:

### Required Tools
- [x] **AWS Account** with admin access ([Sign up](https://aws.amazon.com/))
- [x] **AWS CLI** installed and configured ([Install](https://aws.amazon.com/cli/))
  ```bash
  aws configure
  # Enter: Access Key, Secret Key, Region (eu-north-1)
  ```
- [x] **Terraform** >= 1.0 ([Install](https://www.terraform.io/downloads))
  ```bash
  terraform --version
  ```
- [x] **Docker** installed ([Install](https://www.docker.com/))
  ```bash
  docker --version
  ```
- [x] **Git** installed
  ```bash
  git --version
  ```

### Optional (For Custom Domain)
- [ ] **Domain Name** (e.g., cloudycode.dev)
- [ ] **Route53 Hosted Zone** for your domain
- [ ] **ACM SSL Certificate** in eu-north-1 region

> **💡 Tip:** You can skip custom domain and use ALB DNS directly for testing.

---

## 🎯 Step-by-Step Setup

### Step 1: Clone & Configure (3 min)

#### 1.1 Clone Repository

```bash
git clone https://github.com/engabelal/ecs-fargate-terraform-deployment.git
cd ecs-fargate-terraform-deployment
```

#### 1.2 Get Your AWS Account ID

```bash
aws sts get-caller-identity --query Account --output text
# Example output: 501235162976
```

#### 1.3 Configure Terraform Variables

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
# Network Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones  = ["eu-north-1a", "eu-north-1b"]

# ECR Configuration
ecr_repository_name = "url-shortener"

# Container Configuration
# Replace YOUR_AWS_ACCOUNT_ID with your actual account ID
container_image = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.eu-north-1.amazonaws.com/url-shortener:latest"

# Task Configuration
task_cpu      = "256"
task_memory   = "512"
desired_count = 1

# Optional: Custom Domain (comment out if not using)
# certificate_arn = "arn:aws:acm:eu-north-1:YOUR_ACCOUNT:certificate/xxx"
# domain_name     = "cloudycode.dev"
# subdomain       = "dev.awsapp.cloudycode.dev"
```

**✅ Verification:**
```bash
grep "container_image" terraform/environments/dev/terraform.tfvars
# Should show your AWS account ID
```

---

### Step 2: Setup GitHub Actions OIDC (2 min)

**What you'll create:** IAM OIDC provider + Role for GitHub Actions (no AWS credentials needed!)

#### 2.1 Edit Script

Edit `scripts/01-setup/01-setup-github-actions-oidc.sh`:

```bash
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID"  # Replace with your account ID
GITHUB_REPO="your-username/your-repo-name"  # e.g., engabelal/ecs-fargate-terraform-deployment
```

#### 2.2 Run Script

```bash
cd scripts/01-setup
chmod +x 01-setup-github-actions-oidc.sh
./01-setup-github-actions-oidc.sh
```

#### 2.3 Copy Role ARN

**Output:**
```
✓ OIDC Provider created
✓ IAM Role created: github-actions-ecs-deploy
Role ARN: arn:aws:iam::501235162976:role/github-actions-ecs-deploy
```

**Copy the Role ARN** and add it to `.github/workflows/build-and-push.yml`:

```yaml
env:
  AWS_REGION: eu-north-1
  ECR_REPOSITORY: url-shortener
  AWS_ROLE_ARN: arn:aws:iam::YOUR_ACCOUNT:role/github-actions-ecs-deploy  # Paste here
```

**✅ Verification:**
```bash
aws iam get-role --role-name github-actions-ecs-deploy
# Should return role details
```

**⚠️ Common Issue:** "Role already exists"
- **Solution:** Role was created before, skip this step or delete and recreate.

---

### Step 3: Setup Terraform Backend (1 min)

**What you'll create:** S3 bucket for state + DynamoDB table for locking

```bash
chmod +x 02-setup-terraform-backend.sh
./02-setup-terraform-backend.sh
```

**Output:**
```
✓ S3 bucket created: terraform-state-url-shortener-501235162976
✓ DynamoDB table created: terraform-state-lock
```

**✅ Verification:**
```bash
aws s3 ls | grep terraform-state
aws dynamodb list-tables | grep terraform-state-lock
```

**⚠️ Common Issue:** "Bucket already exists"
- **Solution:** Bucket was created before, skip this step.

---

### Step 4: Deploy Infrastructure (5-7 min)

**What you'll create:**
- VPC with 2 public subnets
- Application Load Balancer (Blue/Green target groups)
- ECS Fargate Cluster + Service
- DynamoDB table (urls-dev)
- ECR repository
- CodeDeploy application
- Route53 DNS record (if configured)
- IAM roles + Security groups

```bash
chmod +x 03-deploy-infrastructure.sh
./03-deploy-infrastructure.sh
```

**Prompts:**
- Type `yes` to confirm deployment

**Output:**
```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "url-shortener-alb-dev-123456.eu-north-1.elb.amazonaws.com"
application_url = "https://dev.awsapp.cloudycode.dev"
ecr_repository_url = "501235162976.dkr.ecr.eu-north-1.amazonaws.com/url-shortener"
ecs_cluster_name = "url-shortener-cluster-dev"
```

**✅ Verification:**
```bash
# Check ECS cluster
aws ecs list-clusters --region eu-north-1

# Check ALB
aws elbv2 describe-load-balancers --region eu-north-1 | grep url-shortener

# Check ECR
aws ecr describe-repositories --repository-names url-shortener --region eu-north-1
```

**⚠️ Common Issues:**

**Issue:** "Certificate not found"
- **Solution:** Comment out `certificate_arn` in terraform.tfvars if not using custom domain.

**Issue:** "No default VPC available"
- **Solution:** This is normal! The project creates its own VPC.

---

### Step 5: Build & Push First Image (2 min)

**What you'll do:** Build Docker image and push to ECR

```bash
cd ../02-deploy
chmod +x 01-build-and-push-image.sh
./01-build-and-push-image.sh
```

**Output:**
```
Step 1: Logging in to ECR...
✓ Logged in to ECR

Step 2: Building Docker image...
✓ Docker image built

Step 3: Tagging image...
✓ Image tagged

Step 4: Pushing image to ECR...
✓ Image pushed successfully

Image: 501235162976.dkr.ecr.eu-north-1.amazonaws.com/url-shortener:latest
```

**✅ Verification:**
```bash
# Check image in ECR
aws ecr list-images --repository-name url-shortener --region eu-north-1
```

**⚠️ Common Issue:** "ECR repository not found"
- **Solution:** Run Step 4 first to create infrastructure.

---

### Step 6: Verify Deployment (1 min)

#### 6.1 Check ECS Service

```bash
aws ecs describe-services \
  --cluster url-shortener-cluster-dev \
  --services url-shortener-service-dev \
  --region eu-north-1 \
  --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'
```

**Expected Output:**
```json
{
  "Status": "ACTIVE",
  "Running": 1,
  "Desired": 1
}
```

#### 6.2 Test Application

**Option A: Using Custom Domain**
```bash
curl https://dev.awsapp.cloudycode.dev/health
```

**Option B: Using ALB DNS**
```bash
# Get ALB DNS from Terraform output
terraform output alb_dns_name

# Test health endpoint
curl http://YOUR-ALB-DNS/health
```

**Expected Response:**
```json
{"status":"healthy","service":"url-shortener"}
```

#### 6.3 Check in Browser

Open in browser:
- Custom domain: `https://dev.awsapp.cloudycode.dev`
- ALB DNS: `http://YOUR-ALB-DNS`

You should see the URL Shortener UI! 🎉

---

## 🎉 You're Done!

Your application is now running with:
- ✅ **ECS Fargate** - Serverless containers
- ✅ **Blue/Green Deployment** - Zero downtime updates
- ✅ **Auto Scaling** - Scales based on demand
- ✅ **HTTPS** - Secure connections (if domain configured)
- ✅ **CI/CD Pipeline** - Automated deployments

---

## 🔄 Daily Workflow

After initial setup, deploying updates is simple:

```bash
# 1. Make code changes
vim app/src/main.py

# 2. Commit and push
git add app/
git commit -m "Update application to v2.0"
git push origin main

# 3. GitHub Actions automatically:
#    - Builds new Docker image
#    - Pushes to ECR
#    - Registers new ECS task definition
#    - Triggers CodeDeploy Blue/Green deployment
#    - Monitors health checks
#    - Rolls back on failure
```

**Monitor Deployment:**
- GitHub Actions: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
- AWS CodeDeploy: AWS Console → CodeDeploy → Deployments

---

## 🧹 Cleanup (When Done)

To destroy everything and stop billing:

### Automated Cleanup (Recommended)

```bash
# Step 1: Destroy infrastructure (includes ECR cleanup)
cd scripts/03-cleanup
./01-destroy-infrastructure.sh
# Type 'destroy' to confirm

# Step 2: Cleanup remaining resources
./02-cleanup-resources.sh
# Answer prompts:
# - DynamoDB state lock table? yes
# - S3 backend bucket? yes
# - Route53 hosted zone? yes (if you want to delete it)
```

**⏱️ Cleanup time:** ~5 minutes

**✅ Verification:**
```bash
# Check no resources remain
aws ecs list-clusters --region eu-north-1
aws elbv2 describe-load-balancers --region eu-north-1
aws dynamodb list-tables --region eu-north-1
```

---

## 💰 Cost Estimate

**Monthly Cost (dev environment):**

| Service | Usage | Cost |
|---------|-------|------|
| ECS Fargate | 1 task (0.25 vCPU, 0.5 GB) | ~$10 |
| Application Load Balancer | 1 ALB | ~$16 |
| DynamoDB | On-demand, low traffic | ~$1 |
| Route53 | 1 hosted zone | $0.50 |
| ECR | <500 MB storage | Free |
| CloudWatch Logs | <5 GB | Free |
| S3 | Terraform state | <$0.10 |
| **Total** | | **~$27-30/month** |

**💡 Cost Optimization Tips:**
- Use `desired_count = 1` for dev
- Delete resources when not in use
- Use Fargate Spot for 70% savings (production)

---

## 🆘 Troubleshooting

### Issue: Terraform State Lock

**Error:** `Error acquiring the state lock`

**Solution:**
```bash
# Force unlock (use with caution)
cd terraform/environments/dev
terraform force-unlock <LOCK_ID>
```

### Issue: ECS Tasks Not Starting

**Error:** Tasks keep restarting

**Solution:**
```bash
# Check logs
aws logs tail /ecs/url-shortener-dev --follow --region eu-north-1

# Common causes:
# 1. Wrong container port (should be 8000)
# 2. Missing environment variables
# 3. DynamoDB permissions
# 4. Image not found in ECR
```

### Issue: GitHub Actions Permission Denied

**Error:** `User: arn:aws:sts::xxx:assumed-role/github-actions-ecs-deploy is not authorized`

**Solution:**
1. Verify Role ARN in `.github/workflows/build-and-push.yml`
2. Check IAM role has correct permissions
3. Ensure OIDC provider is configured correctly

### Issue: Certificate Validation Stuck

**Error:** ACM certificate stuck in "Pending validation"

**Solution:**
1. Go to ACM Console
2. Copy CNAME record
3. Add to Route53 Hosted Zone
4. Wait 5-10 minutes for DNS propagation

---

## 📚 Additional Resources

- **[README.md](README.md)** - Project overview and architecture
- **[scripts/README.md](scripts/README.md)** - Scripts documentation
- **[docs/ENVIRONMENTS.md](docs/ENVIRONMENTS.md)** - Multi-environment setup
- **[AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)**
- **[Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)**

---

## 🆘 Need Help?

- **Issues:** Open an issue on [GitHub](https://github.com/engabelal/ecs-fargate-terraform-deployment/issues)
- **Email:** eng.abelal@gmail.com
- **LinkedIn:** [Ahmed Belal](https://linkedin.com/in/engabelal)

---

<div align="center">

**Made with ❤️ by Ahmed Belal**

[⬆ Back to Top](#-start-here---complete-setup-guide)

</div>
