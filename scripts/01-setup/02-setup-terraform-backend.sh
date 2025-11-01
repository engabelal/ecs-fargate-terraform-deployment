#!/bin/bash

################################################################################
# Script: 02-setup-terraform-backend.sh
# Description: Setup Terraform backend (S3 + DynamoDB)
# Usage: ./02-setup-terraform-backend.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Terraform Backend Setup${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Get AWS Account ID automatically
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="eu-north-1"  # TODO: Change if needed

echo -e "\n${YELLOW}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"

# ============================================================================
# STEP 1: Navigate to backend-setup directory
# ============================================================================

echo -e "\n${YELLOW}Step 1: Navigating to backend-setup directory...${NC}"

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT/terraform/backend-setup"

# ============================================================================
# STEP 2: Initialize Terraform
# ============================================================================

echo -e "\n${YELLOW}Step 2: Initializing Terraform...${NC}"

terraform init

echo -e "${GREEN}✓ Terraform initialized${NC}"

# ============================================================================
# STEP 3: Plan Terraform changes
# ============================================================================

echo -e "\n${YELLOW}Step 3: Planning Terraform changes...${NC}"

terraform plan \
  -var="aws_account_id=${AWS_ACCOUNT_ID}" \
  -var="aws_region=${AWS_REGION}"

# ============================================================================
# STEP 4: Apply Terraform
# ============================================================================

echo -e "\n${YELLOW}Step 4: Applying Terraform...${NC}"
echo -e "${RED}This will create:${NC}"
echo -e "  - S3 bucket: terraform-state-url-shortener-${AWS_ACCOUNT_ID}"
echo -e "  - DynamoDB table: terraform-state-lock"
echo -e "\n${YELLOW}Do you want to continue? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${RED}Aborted${NC}"
  exit 1
fi

terraform apply \
  -var="aws_account_id=${AWS_ACCOUNT_ID}" \
  -var="aws_region=${AWS_REGION}" \
  -auto-approve

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Backend Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nCreated Resources:"
echo -e "  ${GREEN}✓${NC} S3 Bucket: terraform-state-url-shortener-${AWS_ACCOUNT_ID}"
echo -e "  ${GREEN}✓${NC} DynamoDB Table: terraform-state-lock"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Run: ${GREEN}./03-deploy-infrastructure.sh${NC}"
