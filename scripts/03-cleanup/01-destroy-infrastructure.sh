#!/bin/bash

################################################################################
# Script: 01-destroy-infrastructure.sh
# Description: Destroy all AWS infrastructure
# Usage: ./01-destroy-infrastructure.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}Infrastructure Destruction${NC}"
echo -e "${RED}========================================${NC}"

# ============================================================================
# CONFIGURATION
# ============================================================================

ENVIRONMENT="dev"  # TODO: Change if needed
AWS_REGION="eu-north-1"

echo -e "\n${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Region: ${AWS_REGION}${NC}"

# ============================================================================
# WARNING
# ============================================================================

echo -e "\n${RED}⚠️  WARNING ⚠️${NC}"
echo -e "${RED}This will DESTROY all infrastructure including:${NC}"
echo -e "  - ECS Cluster & Service"
echo -e "  - Application Load Balancer"
echo -e "  - VPC & Subnets"
echo -e "  - DynamoDB Table"
echo -e "  - CodeDeploy Application"
echo -e "  - Route53 DNS Record"
echo -e "  - IAM Roles & Security Groups"
echo -e "\n${RED}This action CANNOT be undone!${NC}"
echo -e "\n${YELLOW}Type 'destroy' to confirm:${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "destroy" ]; then
  echo -e "${GREEN}Aborted${NC}"
  exit 0
fi

# Disable Terraform pager
export TF_IN_AUTOMATION=1

# ============================================================================
# STEP 1: Navigate to environment directory
# ============================================================================

echo -e "\n${YELLOW}Step 1: Navigating to ${ENVIRONMENT} environment...${NC}"

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT/terraform/environments/${ENVIRONMENT}"

# ============================================================================
# STEP 2: Terraform Destroy
# ============================================================================

echo -e "\n${YELLOW}Step 2: Deleting ECR images...${NC}"

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="url-shortener"

# Delete all ECR images
aws ecr batch-delete-image \
  --repository-name ${ECR_REPOSITORY} \
  --region ${AWS_REGION} \
  --image-ids "$(aws ecr list-images \
    --repository-name ${ECR_REPOSITORY} \
    --region ${AWS_REGION} \
    --query 'imageIds[*]' \
    --output json)" 2>/dev/null || echo -e "${YELLOW}No images found or already deleted${NC}"

echo -e "${GREEN}✓ ECR images deleted${NC}"

echo -e "\n${YELLOW}Step 3: Initializing Terraform...${NC}"

terraform init -reconfigure

echo -e "${GREEN}✓ Terraform initialized${NC}"

echo -e "\n${YELLOW}Step 4: Destroying infrastructure...${NC}"

export TF_CLI_ARGS="-no-color"
terraform destroy -auto-approve

echo -e "${GREEN}✓ Infrastructure destroyed${NC}"

# ============================================================================
# STEP 5: Check for remaining resources
# ============================================================================

echo -e "\n${YELLOW}Step 5: Checking for remaining resources...${NC}"

# Check ECR
ECR_REPO=$(aws ecr describe-repositories \
  --repository-names url-shortener \
  --region ${AWS_REGION} 2>/dev/null || echo "")

if [ -n "$ECR_REPO" ]; then
  echo -e "${YELLOW}⚠ ECR repository still exists${NC}"
  echo -e "Run: ${GREEN}./02-cleanup-resources.sh${NC} to clean up"
else
  echo -e "${GREEN}✓ No ECR repository found${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Destruction Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Run cleanup script: ${GREEN}./02-cleanup-resources.sh${NC}"
echo -e "2. Verify in AWS Console that all resources are deleted"
