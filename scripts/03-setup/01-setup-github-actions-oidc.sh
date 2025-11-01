#!/bin/bash

################################################################################
# Script: 01-setup-github-actions-oidc.sh
# Description: Setup GitHub Actions OIDC provider and IAM role
# Usage: ./01-setup-github-actions-oidc.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}GitHub Actions OIDC Setup${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# CONFIGURATION - UPDATE THESE VALUES
# ============================================================================

# Get AWS Account ID from your AWS account
AWS_ACCOUNT_ID="501235162976"  # TODO: Replace with your AWS Account ID

# Your GitHub repository (format: username/repo-name)
GITHUB_REPO="engabelal/ecs-fargate-terraform-deployment"  # TODO: Replace with your repo

# IAM Role name for GitHub Actions
ROLE_NAME="github-actions-ecs-deploy"

# AWS Region
AWS_REGION="eu-north-1"

# ============================================================================
# STEP 1: Create OIDC Provider
# ============================================================================

echo -e "\n${YELLOW}Step 1: Creating OIDC Provider...${NC}"

# Check if OIDC provider already exists
OIDC_EXISTS=$(aws iam list-open-id-connect-providers \
  --query "OpenIDConnectProviderList[?contains(Arn, 'token.actions.githubusercontent.com')].Arn" \
  --output text)

if [ -z "$OIDC_EXISTS" ]; then
  aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
  
  echo -e "${GREEN}✓ OIDC Provider created${NC}"
else
  echo -e "${YELLOW}⚠ OIDC Provider already exists${NC}"
fi

# ============================================================================
# STEP 2: Create IAM Role
# ============================================================================

echo -e "\n${YELLOW}Step 2: Creating IAM Role...${NC}"

# Create trust policy
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

# Check if role already exists
ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME 2>/dev/null || echo "")

if [ -z "$ROLE_EXISTS" ]; then
  aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file:///tmp/trust-policy.json \
    --description "Role for GitHub Actions to deploy ECS applications"
  
  echo -e "${GREEN}✓ IAM Role created${NC}"
else
  echo -e "${YELLOW}⚠ IAM Role already exists${NC}"
fi

# ============================================================================
# STEP 3: Attach Permissions Policy
# ============================================================================

echo -e "\n${YELLOW}Step 3: Attaching permissions policy...${NC}"

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Path to the policy file
POLICY_FILE="$PROJECT_ROOT/terraform/modules/iam/github-actions-policy.json"

if [ ! -f "$POLICY_FILE" ]; then
  echo -e "${RED}✗ Policy file not found: $POLICY_FILE${NC}"
  echo -e "${YELLOW}Current directory: $(pwd)${NC}"
  echo -e "${YELLOW}Looking for: $POLICY_FILE${NC}"
  exit 1
fi

aws iam put-role-policy \
  --role-name $ROLE_NAME \
  --policy-name CodeDeployPermissions \
  --policy-document file://$POLICY_FILE

echo -e "${GREEN}✓ Permissions policy attached${NC}"

# ============================================================================
# STEP 4: Display Role ARN
# ============================================================================

echo -e "\n${YELLOW}Step 4: Getting Role ARN...${NC}"

ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nRole ARN: ${GREEN}${ROLE_ARN}${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Add this ARN to your GitHub Actions workflow (.github/workflows/build-and-push.yml)"
echo -e "2. Update the 'role-to-assume' parameter with this ARN"
echo -e "\nExample:"
echo -e "  ${GREEN}role-to-assume: ${ROLE_ARN}${NC}"

# Cleanup
rm -f /tmp/trust-policy.json
