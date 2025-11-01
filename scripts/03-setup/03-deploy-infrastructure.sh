#!/bin/bash

################################################################################
# Script: 03-deploy-infrastructure.sh
# Description: Deploy AWS infrastructure using Terraform
# Usage: ./03-deploy-infrastructure.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Infrastructure Deployment${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# CONFIGURATION - UPDATE terraform.tfvars FIRST!
# ============================================================================

ENVIRONMENT="dev"  # TODO: Change to staging/prod if needed
AWS_REGION="eu-north-1"

echo -e "\n${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Region: ${AWS_REGION}${NC}"

# ============================================================================
# STEP 1: Navigate to environment directory
# ============================================================================

echo -e "\n${YELLOW}Step 1: Navigating to ${ENVIRONMENT} environment...${NC}"

cd terraform/environments/${ENVIRONMENT}

# ============================================================================
# STEP 2: Check terraform.tfvars
# ============================================================================

echo -e "\n${YELLOW}Step 2: Checking terraform.tfvars...${NC}"

if [ ! -f "terraform.tfvars" ]; then
  echo -e "${RED}✗ terraform.tfvars not found!${NC}"
  echo -e "\n${YELLOW}Please create terraform.tfvars with:${NC}"
  echo -e "  - domain_name"
  echo -e "  - subdomain"
  echo -e "  - certificate_arn (from ACM)"
  echo -e "  - vpc_cidr"
  echo -e "  - public_subnet_cidrs"
  echo -e "  - availability_zones"
  echo -e "  - container_image (ECR URL)"
  exit 1
fi

echo -e "${GREEN}✓ terraform.tfvars found${NC}"

# ============================================================================
# STEP 3: Initialize Terraform
# ============================================================================

echo -e "\n${YELLOW}Step 3: Initializing Terraform...${NC}"

terraform init

echo -e "${GREEN}✓ Terraform initialized${NC}"

# ============================================================================
# STEP 4: Validate Terraform
# ============================================================================

echo -e "\n${YELLOW}Step 4: Validating Terraform configuration...${NC}"

terraform validate

echo -e "${GREEN}✓ Configuration is valid${NC}"

# ============================================================================
# STEP 5: Plan Terraform changes
# ============================================================================

echo -e "\n${YELLOW}Step 5: Planning Terraform changes...${NC}"

terraform plan -out=tfplan

# ============================================================================
# STEP 6: Review and Apply
# ============================================================================

echo -e "\n${YELLOW}Step 6: Applying Terraform...${NC}"
echo -e "${RED}This will create:${NC}"
echo -e "  - VPC with 2 subnets"
echo -e "  - Application Load Balancer"
echo -e "  - ECS Fargate Cluster & Service"
echo -e "  - DynamoDB Table"
echo -e "  - CodeDeploy Application"
echo -e "  - Route53 DNS Record"
echo -e "  - IAM Roles & Security Groups"
echo -e "\n${YELLOW}Estimated time: 5-7 minutes${NC}"
echo -e "\n${YELLOW}Do you want to continue? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${RED}Aborted${NC}"
  rm -f tfplan
  exit 1
fi

terraform apply tfplan

rm -f tfplan

# ============================================================================
# STEP 7: Display Outputs
# ============================================================================

echo -e "\n${YELLOW}Step 7: Getting outputs...${NC}"

terraform output

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Infrastructure Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Build and push Docker image: ${GREEN}cd ../../../scripts/deploy && ./01-build-and-push-image.sh${NC}"
echo -e "2. Or push code to GitHub to trigger CI/CD"
