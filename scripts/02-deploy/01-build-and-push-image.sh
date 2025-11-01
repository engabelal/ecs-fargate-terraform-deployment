#!/bin/bash

################################################################################
# Script: 01-build-and-push-image.sh
# Description: Build Docker image and push to ECR
# Usage: ./01-build-and-push-image.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build and Push Docker Image${NC}"
echo -e "${GREEN}========================================${NC}"

# ============================================================================
# CONFIGURATION
# ============================================================================

# Get AWS Account ID automatically
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="eu-north-1"  # TODO: Change if needed
ECR_REPOSITORY="url-shortener"
IMAGE_TAG="latest"

# ECR URL
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_URL}/${ECR_REPOSITORY}:${IMAGE_TAG}"

echo -e "\n${YELLOW}AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}ECR Repository: ${ECR_REPOSITORY}${NC}"
echo -e "${YELLOW}Image Tag: ${IMAGE_TAG}${NC}"

# ============================================================================
# STEP 1: Login to ECR
# ============================================================================

echo -e "\n${YELLOW}Step 1: Logging in to ECR...${NC}"

aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${ECR_URL}

echo -e "${GREEN}✓ Logged in to ECR${NC}"

# ============================================================================
# STEP 2: Build Docker Image
# ============================================================================

echo -e "\n${YELLOW}Step 2: Building Docker image...${NC}"

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

cd "$PROJECT_ROOT/app"

docker build --platform linux/amd64 -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

echo -e "${GREEN}✓ Docker image built${NC}"

# ============================================================================
# STEP 3: Tag Image
# ============================================================================

echo -e "\n${YELLOW}Step 3: Tagging image...${NC}"

docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${FULL_IMAGE_NAME}

echo -e "${GREEN}✓ Image tagged${NC}"

# ============================================================================
# STEP 4: Push to ECR
# ============================================================================

echo -e "\n${YELLOW}Step 4: Pushing image to ECR...${NC}"

docker push ${FULL_IMAGE_NAME}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Image Pushed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nImage: ${GREEN}${FULL_IMAGE_NAME}${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "1. Push code to GitHub to trigger Blue/Green deployment"
echo -e "2. Or manually trigger deployment: ${GREEN}./02-trigger-deployment.sh${NC}"
