# 🚀 CI/CD Workflows

## 📋 Available Workflows:

### 1. **Build and Push to ECR** (Automated)
- **Trigger:** Push to `main` branch (when `app/` changes)
- **What it does:**
  - Builds Docker image
  - Pushes to ECR with commit SHA tag
  - Updates `latest` tag

### 2. **Deploy to ECS** (Manual)
- **Trigger:** Manual (workflow_dispatch)
- **What it does:**
  - Forces new ECS deployment
  - Waits for service stability
  - Uses latest image from ECR

### 3. **Security Scan** (Automated)
- **Trigger:** Push/PR to `main` branch
- **What it does:**
  - Scans Docker image with Trivy
  - Scans Terraform with Checkov
  - Reports vulnerabilities

---

## 🎯 How to Use:

### **Automated Deployment:**
```bash
# 1. Make changes to app
vim app/src/main.py

# 2. Commit and push
git add .
git commit -m "Update app"
git push origin main

# 3. GitHub Actions will:
#    - Build image
#    - Push to ECR
#    - (Optional) Auto-deploy
```

### **Manual Deployment:**
```
GitHub → Actions → Deploy to ECS → Run workflow
```

---

## 🔐 Security:

- ✅ OIDC authentication (no AWS keys in GitHub)
- ✅ Automated security scanning
- ✅ Vulnerability detection
- ✅ Terraform best practices check

---

## 📊 Workflow Status:

Check status at: `https://github.com/engabelal/ecs-fargate-terraform-deployment/actions`
