# 🔄 Test Rollback Guide

## Method 1: Automatic Rollback (Failed Health Check)

### Step 1: Break the health check
```python
# Edit app/src/main.py
@app.get("/health")
def health_check():
    return {"status": "unhealthy"}  # This will fail
```

### Step 2: Push and watch rollback
```bash
git add app/src/main.py
git commit -m "test: Break health check for rollback test"
git push origin main
```

### Step 3: Monitor rollback
```bash
# Watch deployment fail and rollback
aws deploy get-deployment \
  --deployment-id <DEPLOYMENT_ID> \
  --region eu-north-1
```

### Step 4: Fix it
```python
# Revert app/src/main.py
@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "url-shortener"}
```

---

## Method 2: Manual Rollback

### Stop deployment manually:
```bash
# Get deployment ID
DEPLOYMENT_ID=$(aws deploy list-deployments \
  --application-name url-shortener-dev \
  --deployment-group-name url-shortener-dg-dev \
  --region eu-north-1 \
  --include-only-statuses InProgress \
  --query 'deployments[0]' --output text)

# Stop deployment (triggers rollback)
aws deploy stop-deployment \
  --deployment-id $DEPLOYMENT_ID \
  --auto-rollback-enabled \
  --region eu-north-1
```

---

## Method 3: Redeploy Previous Version

### Get previous task definition:
```bash
# List task definitions
aws ecs list-task-definitions \
  --family-prefix url-shortener-dev \
  --region eu-north-1 \
  --sort DESC

# Create deployment with old revision
aws deploy create-deployment \
  --application-name url-shortener-dev \
  --deployment-group-name url-shortener-dg-dev \
  --revision revisionType=AppSpecContent,appSpecContent="{content='{\"version\":0.0,\"Resources\":[{\"TargetService\":{\"Type\":\"AWS::ECS::Service\",\"Properties\":{\"TaskDefinition\":\"arn:aws:ecs:eu-north-1:501235162976:task-definition/url-shortener-dev:13\",\"LoadBalancerInfo\":{\"ContainerName\":\"url-shortener\",\"ContainerPort\":8000}}}}]}'}" \
  --region eu-north-1
```

---

## Expected Behavior:

### Automatic Rollback:
1. ❌ New version fails health checks
2. 🔄 CodeDeploy detects failure
3. ⏪ Traffic shifts back to old version
4. ✅ Old version continues serving

### Manual Rollback:
1. 🛑 Stop deployment command
2. ⏪ Traffic shifts back immediately
3. ✅ Old version restored
