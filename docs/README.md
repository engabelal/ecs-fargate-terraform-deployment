# 📚 Documentation

Complete documentation for the ECS Fargate Terraform Deployment project.

---

## 🎬 Quick Start

**New to this project?** → [📖 START HERE - Step-by-Step Guide](../START-HERE.md)

---

## 📖 Table of Contents

### 🌍 Environments
1. **[Multi-Environment Setup](ENVIRONMENTS.md)**
   - Environment URLs (dev/prod)
   - SSL certificate configuration
   - Blue/Green deployment strategy
   - Automation scripts usage
   - Environment comparison
   - CI/CD workflows per environment
   - Cost breakdown
   - Adding new environments

---

## 🎯 Quick Links

### Development Environment
- **URL**: https://dev.awsapp.cloudycode.dev
- **Purpose**: Testing and development
- **Auto-deploy**: Push to `main` branch (Blue/Green)
- **Deployment Time**: ~5 minutes

### Production Environment
- **URL**: https://awsapp.cloudycode.dev
- **Purpose**: Live production
- **Deploy**: Manual or release tags (Blue/Green)
- **Deployment Time**: ~5 minutes

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼────┐
                    │ Route53 │
                    └────┬────┘
                         │
                    ┌────▼────┐
                    │   ALB   │ (HTTPS)
                    │  + SSL  │
                    └────┬────┘
                         │
              ┌──────────┴──────────┐
              │                     │
         ┌────▼────┐           ┌────▼────┐
         │ ECS Task│           │ ECS Task│
         │ (Blue)  │           │ (Green) │
         └────┬────┘           └────┬────┘
              │                     │
              └──────────┬──────────┘
                         │
                    ┌────▼────┐
                    │DynamoDB │
                    └─────────┘
```

---

## 🔑 Key Concepts

### Blue/Green Deployment
- **Strategy**: CodeDeploy manages traffic shift between Blue and Green target groups
- **Zero Downtime**: New version (Green) starts before old version (Blue) stops
- **Health Checks**: Ensures new tasks are healthy before traffic shift
- **Auto Rollback**: Automatic rollback on deployment failure
- **Deployment Time**: ~5 minutes (includes health checks and traffic shift)
- **Termination Wait**: Old tasks terminate 5 minutes after successful deployment

### Infrastructure as Code
- **Terraform Modules**: Reusable, modular architecture
- **State Management**: S3 backend with DynamoDB locking
- **Multi-Environment**: Separate configs for dev/staging/prod

### CI/CD Pipeline
- **Trigger**: Push to main branch (app/ directory changes)
- **Build**: Docker image with multi-stage build
- **Push**: To ECR with versioned tags (version, SHA, latest)
- **Register**: New ECS task definition with updated image
- **Deploy**: CodeDeploy Blue/Green deployment
- **Verify**: Health checks + traffic shift + auto rollback on failure

---

## 🛠️ Common Tasks

### Deploy Application (Automated)
```bash
# Make changes to app/
git add .
git commit -m "feature: add new functionality"
git push origin main
# GitHub Actions triggers Blue/Green deployment automatically
```

### Deploy Infrastructure
```bash
# Using scripts (recommended)
cd scripts/03-setup
./03-deploy-infrastructure.sh

# Or manually
cd terraform/environments/dev
terraform apply
```

### Build and Push Image Manually
```bash
cd scripts/02-deploy
./01-build-and-push-image.sh
```

### View Logs
```bash
aws logs tail /ecs/url-shortener-dev --follow
```

### Check Service Status
```bash
aws ecs describe-services \
  --cluster url-shortener-cluster-dev \
  --services url-shortener-service-dev \
  --region eu-north-1
```

### Rollback Deployment
```bash
# Stop current CodeDeploy deployment (triggers automatic rollback)
aws deploy stop-deployment \
  --deployment-id <DEPLOYMENT_ID> \
  --auto-rollback-enabled \
  --region eu-north-1

# Or redeploy previous version via Console:
# CodeDeploy → Deployments → Select previous successful → Redeploy
```

### Monitor CodeDeploy Deployment
```bash
# List recent deployments
aws deploy list-deployments \
  --application-name url-shortener-dev \
  --deployment-group-name url-shortener-dg-dev \
  --region eu-north-1

# Get deployment status
aws deploy get-deployment \
  --deployment-id <DEPLOYMENT_ID> \
  --region eu-north-1
```

---

## 📈 Monitoring & Observability

### CloudWatch Logs
- **Log Group**: `/ecs/url-shortener-{environment}`
- **Retention**: 3 days (dev), 7 days (prod)
- **Access**: AWS Console or CLI

### ECS Metrics
- **CPU Utilization**: Target 70%
- **Memory Utilization**: Target 80%
- **Task Count**: Monitor running vs desired

### ALB Metrics
- **Target Response Time**: < 200ms
- **Healthy Host Count**: Should match desired count
- **HTTP 5xx Errors**: Should be 0

---

## 🔐 Security Best Practices

### Infrastructure
- ✅ HTTPS only (HTTP redirects)
- ✅ Security groups with least privilege
- ✅ IAM roles with minimal permissions
- ✅ No hardcoded credentials
- ✅ Encrypted data at rest (DynamoDB, S3)

### CI/CD
- ✅ OIDC authentication (no static credentials)
- ✅ Container vulnerability scanning (Trivy)
- ✅ IaC security scanning (Checkov)
- ✅ Secrets stored in GitHub Secrets

### Application
- ✅ Health check endpoint
- ✅ Graceful shutdown handling
- ✅ Input validation
- ✅ Error handling and logging

---

## 💰 Cost Management

### Development Environment (~$28/month)
- ECS Fargate (1 task): $10
- ALB: $16
- DynamoDB: $1
- Route53: $0.50
- ECR + S3: $0.50

### Production Environment (~$50/month)
- ECS Fargate (2 tasks): $20
- ALB: $16
- DynamoDB: $5
- Route53: $0.50
- ECR + S3: $0.50
- CloudWatch: $8

### Cost Optimization Tips
- Scale down dev environment after hours
- Use on-demand DynamoDB billing
- Clean up old ECR images (lifecycle policy)
- Monitor and set billing alarms

---

## 🐛 Troubleshooting

### Common Issues

#### CodeDeploy Deployment Failed
- Check ECS service has `CODE_DEPLOY` deployment controller
- Verify Blue and Green target groups exist
- Check IAM role permissions for CodeDeploy
- Review CloudWatch logs for application errors

#### Service Not Starting
- Check CloudWatch logs: `aws logs tail /ecs/url-shortener-dev --follow`
- Verify security groups allow ALB → ECS traffic (port 8000)
- Ensure IAM task role has DynamoDB permissions
- Check task definition has correct image URI

#### Health Checks Failing
- Verify `/health` endpoint returns 200 OK
- Check container port is 8000
- Review application logs for startup errors
- Ensure environment variables are set correctly

#### Deployment Stuck
- Check CodeDeploy deployment events in Console
- Verify new tasks are passing health checks
- Stop deployment to trigger rollback if needed
- Check for resource limits (CPU/Memory)

#### High Costs
- Check for orphaned resources (old task definitions, ECR images)
- Review CloudWatch metrics for unused resources
- Scale down dev environment when not in use
- Use automation scripts for complete cleanup

---

## 📞 Support

### Resources
- **GitHub Issues**: Report bugs or request features
- **AWS Documentation**: https://docs.aws.amazon.com/
- **Terraform Docs**: https://registry.terraform.io/

### Getting Help
1. Check documentation first
2. Review CloudWatch logs
3. Search GitHub issues
4. Create new issue with details

---

## 🎓 Learning Resources

### AWS Services
- [ECS Fargate](https://aws.amazon.com/fargate/)
- [Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/)
- [DynamoDB](https://aws.amazon.com/dynamodb/)
- [Route53](https://aws.amazon.com/route53/)

### Tools
- [Terraform](https://www.terraform.io/)
- [Docker](https://www.docker.com/)
- [GitHub Actions](https://github.com/features/actions)

### Best Practices
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [12-Factor App](https://12factor.net/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 🚀 Next Steps

1. ✅ Complete initial setup using [START-HERE.md](../START-HERE.md)
2. ✅ Deploy to development with Blue/Green
3. ✅ Test automated deployments via GitHub Actions
4. ⬜ Add staging environment
5. ⬜ Deploy to production
6. ⬜ Setup CloudWatch alarms and dashboards
7. ⬜ Implement ECS auto-scaling
8. ⬜ Add WAF for security
9. ⬜ Add ElastiCache for caching
10. ⬜ Implement distributed tracing with X-Ray

---

**Happy Building!** 🎉
