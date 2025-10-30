# 🗑️ Cleanup Guide

## Overview

This guide explains how to safely destroy infrastructure to avoid ongoing costs.

---

## 💰 Cost Impact

### Current Monthly Costs:
- **Dev**: $27.50
- **Staging**: $27.50
- **Prod**: $37.50
- **Backend**: $1.00
- **Hosted Zone**: $0.50
- **Total**: $93.50/month

### After Cleanup:
- **Option 1** (Keep Hosted Zone): $0.50/month
- **Option 2** (Delete Everything): $0.00/month

---

## 🛠️ Cleanup Options

### Option 1: Destroy Specific Environment
```bash
./scripts/cleanup.sh
# Select: 1
# Enter: dev (or staging/prod)
```

**Deletes**:
- ECS Service + Tasks
- ALB + Target Groups
- DynamoDB Table
- Security Groups
- VPC + Subnets

**Keeps**:
- Backend (S3 + DynamoDB)
- Hosted Zone
- Other environments

**Cost After**: Reduces by ~$27.50/month

---

### Option 2: Destroy All Environments
```bash
./scripts/cleanup.sh
# Select: 2
```

**Deletes**:
- All dev/staging/prod resources

**Keeps**:
- Backend (S3 + DynamoDB)
- Hosted Zone

**Cost After**: $1.50/month (backend + hosted zone)

---

### Option 3: Destroy All + Backend
```bash
./scripts/cleanup.sh
# Select: 3
```

**Deletes**:
- All environments
- S3 bucket (Terraform state)
- DynamoDB table (state lock)

**Keeps**:
- Hosted Zone

**Cost After**: $0.50/month (hosted zone only)

---

### Option 4: Destroy Everything
```bash
./scripts/cleanup.sh
# Select: 4
```

**Deletes**:
- All environments
- Backend (S3 + DynamoDB)
- Route53 Hosted Zone
- All DNS records

**Cost After**: $0.00/month

⚠️ **Warning**: You'll need to recreate Hosted Zone and update Namecheap if you want to redeploy.

---

## 📋 Manual Cleanup (Alternative)

### Step 1: Destroy Environments
```bash
# Dev
cd terraform/environments/dev
terraform destroy

# Staging
cd terraform/environments/staging
terraform destroy

# Prod
cd terraform/environments/prod
terraform destroy
```

### Step 2: Destroy Backend
```bash
cd terraform/backend-setup
terraform destroy
```

### Step 3: Delete Hosted Zone (Optional)
```bash
# List records
aws route53 list-resource-record-sets \
  --hosted-zone-id Z08774931MPILO50GC8SS

# Delete A records (if any)
aws route53 change-resource-record-sets \
  --hosted-zone-id Z08774931MPILO50GC8SS \
  --change-batch file://delete-record.json

# Delete hosted zone
aws route53 delete-hosted-zone \
  --id Z08774931MPILO50GC8SS
```

---

## ⚠️ Important Notes

### Before Cleanup:
1. ✅ Backup any important data from DynamoDB
2. ✅ Download Terraform state files (if needed)
3. ✅ Note down any configuration values
4. ✅ Verify you're deleting the right environment

### After Cleanup:
1. ✅ Verify all resources deleted in AWS Console
2. ✅ Check billing dashboard (may take 24-48 hours to reflect)
3. ✅ Update Namecheap DNS if you deleted Hosted Zone

---

## 🔄 Redeployment After Cleanup

### If you kept Hosted Zone:
```bash
# Just redeploy
cd terraform/backend-setup
terraform apply

cd terraform/environments/prod
terraform apply
```

### If you deleted Hosted Zone:
```bash
# Recreate Hosted Zone
aws route53 create-hosted-zone \
  --name awsapp.cloudycode.dev \
  --caller-reference $(date +%s)

# Update Namecheap with new NS records
# Then redeploy infrastructure
```

---

## 💡 Recommendations

### For Learning/Testing:
- ✅ Use **Option 2** (destroy all environments, keep backend)
- ✅ Keeps Hosted Zone for quick redeployment
- ✅ Cost: $1.50/month

### For Long-term Pause:
- ✅ Use **Option 3** (destroy all + backend)
- ✅ Keep Hosted Zone only
- ✅ Cost: $0.50/month

### For Complete Removal:
- ✅ Use **Option 4** (destroy everything)
- ✅ Zero cost
- ⚠️ Need to recreate Hosted Zone for redeployment

---

## 🆘 Troubleshooting

### Error: "Resource still in use"
```bash
# Wait a few minutes and retry
# Or manually delete dependencies first
```

### Error: "State file not found"
```bash
# If using S3 backend, download state first
aws s3 cp s3://terraform-state-url-shortener-501235162976/prod/terraform.tfstate .
```

### Error: "Cannot delete Hosted Zone"
```bash
# Delete all records except NS and SOA first
aws route53 list-resource-record-sets --hosted-zone-id Z08774931MPILO50GC8SS
```

---

## 📊 Cleanup Verification

### Check AWS Resources:
```bash
# ECS
aws ecs list-clusters --region eu-north-1

# ALB
aws elbv2 describe-load-balancers --region eu-north-1

# DynamoDB
aws dynamodb list-tables --region eu-north-1

# VPC
aws ec2 describe-vpcs --region eu-north-1

# S3
aws s3 ls | grep terraform-state

# Hosted Zone
aws route53 list-hosted-zones
```

### Check Billing:
1. Go to AWS Console → Billing Dashboard
2. Check "Bills" section
3. Verify charges stopped (may take 24-48 hours)

---

**Remember**: Always verify deletions in AWS Console! 🔍
