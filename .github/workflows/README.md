# 🚀 CI/CD Workflows

## 📋 Available Workflows:

### 1. **Build and Deploy** (Automated) - `build-and-push.yml`
- **Trigger:** Push to `main` branch (when `app/` changes)
- **What it does:**
  1. Builds Docker image (multi-stage, linux/amd64)
  2. Pushes to ECR with 3 tags (version, SHA, latest)
  3. Registers new ECS task definition
  4. Triggers CodeDeploy Blue/Green deployment
  5. Zero-downtime traffic shift
- **Deployment Strategy:** Blue/Green with automatic rollback
- **Time:** ~5 minutes

### 2. **Security Scan** (Automated) - `security-scan.yml`
- **Trigger:** Push/PR to `main` branch (when `app/` or `terraform/` changes)
- **What it does:**
  - Scans application code with Trivy (vulnerabilities)
  - Scans Terraform with Checkov (best practices)
  - Reports security issues
- **Severity:** CRITICAL, HIGH

---

## 🎯 How to Use:

### **Automated Deployment (Recommended):**
```bash
# 1. Make changes to app
vim app/src/main.py

# 2. Commit and push
git add .
git commit -m "feat: add new feature"
git push origin main

# 3. GitHub Actions automatically:
#    ✅ Builds Docker image
#    ✅ Pushes to ECR
#    ✅ Registers task definition
#    ✅ Triggers CodeDeploy Blue/Green
#    ✅ Shifts traffic with zero downtime
#    ✅ Auto-rollback on failure
```

### **Monitor Deployment:**
```bash
# Via GitHub Actions
https://github.com/engabelal/ecs-fargate-terraform-deployment/actions

# Via AWS Console
https://console.aws.amazon.com/codesuite/codedeploy/deployments

# Via CLI
aws deploy list-deployments \
  --application-name url-shortener-dev \
  --deployment-group-name url-shortener-dg-dev \
  --region eu-north-1
```

---

## 🔐 Security:

- ✅ **OIDC Authentication** - No long-lived AWS credentials in GitHub
- ✅ **Trivy Scanning** - Container vulnerability detection
- ✅ **Checkov Scanning** - Terraform security best practices
- ✅ **IAM Least Privilege** - Minimal permissions for GitHub Actions
- ✅ **Secrets Management** - No hardcoded credentials

---

## 🔵🟢 Blue/Green Deployment Flow:

```
1. Push to main (app/ changes)
   ↓
2. GitHub Actions triggered
   ↓
3. Build Docker image
   ↓
4. Push to ECR (3 tags)
   ↓
5. Register new task definition
   ↓
6. CodeDeploy starts Blue/Green
   ├─ Start new tasks (Green)
   ├─ Health checks pass
   ├─ Shift traffic (Blue → Green)
   └─ Terminate old tasks (5 min wait)
   ↓
7. Deployment complete! ✅
```

**Rollback:** Automatic on health check failure or manual via AWS Console

---

## 📊 Workflow Status:

**Check status:** https://github.com/engabelal/ecs-fargate-terraform-deployment/actions

**Deployment logs:** AWS Console → CodeDeploy → Deployments

**Application logs:** CloudWatch Logs → `/ecs/url-shortener-dev`

---

## 🛠️ Troubleshooting:

### Workflow Failed
```bash
# Check GitHub Actions logs
# Common issues:
# - ECR login failed → Check IAM role permissions
# - Build failed → Check Dockerfile syntax
# - CodeDeploy failed → Check ECS service configuration
```

### Deployment Stuck
```bash
# Check CodeDeploy deployment
aws deploy get-deployment --deployment-id <ID> --region eu-north-1

# Stop and rollback
aws deploy stop-deployment --deployment-id <ID> --auto-rollback-enabled
```

### Health Checks Failing
```bash
# Check application logs
aws logs tail /ecs/url-shortener-dev --follow --region eu-north-1

# Common issues:
# - Container port mismatch (should be 8000)
# - /health endpoint not responding
# - DynamoDB permissions missing
```

---

**Made with ❤️ by Ahmed Belal**
