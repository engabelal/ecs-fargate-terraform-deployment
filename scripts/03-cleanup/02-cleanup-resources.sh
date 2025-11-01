#!/bin/bash

################################################################################
# Script: 02-cleanup-resources.sh
# Description: Cleanup remaining AWS resources (ECR, Route53, S3)
# Usage: ./02-cleanup-resources.sh
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Cleanup Remaining Resources${NC}"
echo -e "${YELLOW}========================================${NC}"

# ============================================================================
# CONFIGURATION
# ============================================================================

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="eu-north-1"
ECR_REPOSITORY="url-shortener"
HOSTED_ZONE_ID="Z08774931MPILO50GC8SS"  # TODO: Replace with your Hosted Zone ID (if exists)

# ============================================================================
# STEP 1: Delete ECR Images and Repository
# ============================================================================

echo -e "\n${YELLOW}Step 1: Cleaning up ECR...${NC}"

# Check if ECR repository exists
ECR_EXISTS=$(aws ecr describe-repositories \
  --repository-names ${ECR_REPOSITORY} \
  --region ${AWS_REGION} 2>/dev/null || echo "")

if [ -n "$ECR_EXISTS" ]; then
  echo -e "${YELLOW}Deleting ECR images...${NC}"
  
  # Delete all images
  aws ecr batch-delete-image \
    --repository-name ${ECR_REPOSITORY} \
    --region ${AWS_REGION} \
    --image-ids "$(aws ecr list-images \
      --repository-name ${ECR_REPOSITORY} \
      --region ${AWS_REGION} \
      --query 'imageIds[*]' \
      --output json)" 2>/dev/null || true
  
  # Delete repository
  aws ecr delete-repository \
    --repository-name ${ECR_REPOSITORY} \
    --region ${AWS_REGION} \
    --force
  
  echo -e "${GREEN}✓ ECR repository deleted${NC}"
else
  echo -e "${GREEN}✓ No ECR repository found${NC}"
fi

# ============================================================================
# STEP 2: Delete Route53 Records (Optional)
# ============================================================================

echo -e "\n${YELLOW}Step 2: Cleaning up Route53...${NC}"
echo -e "${YELLOW}Do you want to delete Route53 hosted zone? (yes/no)${NC}"
read -r DELETE_ROUTE53

if [ "$DELETE_ROUTE53" = "yes" ]; then
  # Check if hosted zone exists
  HZ_EXISTS=$(aws route53 get-hosted-zone \
    --id ${HOSTED_ZONE_ID} 2>/dev/null || echo "")
  
  if [ -n "$HZ_EXISTS" ]; then
    echo -e "${YELLOW}Deleting non-default records...${NC}"
    
    # Get all records except NS and SOA
    RECORDS=$(aws route53 list-resource-record-sets \
      --hosted-zone-id ${HOSTED_ZONE_ID} \
      --query "ResourceRecordSets[?Type != 'NS' && Type != 'SOA']" \
      --output json)
    
    # Delete each record (simplified - may need manual cleanup)
    echo -e "${YELLOW}⚠ Manual cleanup may be required for Route53 records${NC}"
    echo -e "${YELLOW}Visit: https://console.aws.amazon.com/route53${NC}"
    
    # Try to delete hosted zone
    aws route53 delete-hosted-zone \
      --id ${HOSTED_ZONE_ID} 2>/dev/null || \
      echo -e "${YELLOW}⚠ Hosted zone has records, delete them manually first${NC}"
  else
    echo -e "${GREEN}✓ No hosted zone found${NC}"
  fi
else
  echo -e "${YELLOW}⊘ Skipping Route53 cleanup${NC}"
fi

# ============================================================================
# STEP 3: Delete DynamoDB State Lock Table
# ============================================================================

echo -e "\n${YELLOW}Step 3: Cleaning up DynamoDB state lock table...${NC}"
echo -e "${YELLOW}Do you want to delete DynamoDB state lock table? (yes/no)${NC}"
read -r DELETE_DYNAMODB

if [ "$DELETE_DYNAMODB" = "yes" ]; then
  TABLE_NAME="terraform-state-lock"
  
  # Check if table exists
  TABLE_EXISTS=$(aws dynamodb describe-table \
    --table-name ${TABLE_NAME} \
    --region ${AWS_REGION} 2>/dev/null || echo "")
  
  if [ -n "$TABLE_EXISTS" ]; then
    echo -e "${YELLOW}Deleting DynamoDB table...${NC}"
    
    aws dynamodb delete-table \
      --table-name ${TABLE_NAME} \
      --region ${AWS_REGION}
    
    echo -e "${GREEN}✓ DynamoDB table deleted${NC}"
  else
    echo -e "${GREEN}✓ No DynamoDB table found${NC}"
  fi
else
  echo -e "${YELLOW}⊘ Skipping DynamoDB cleanup${NC}"
fi

# ============================================================================
# STEP 4: Delete S3 Backend Bucket (Optional)
# ============================================================================

echo -e "\n${YELLOW}Step 4: Cleaning up S3 backend...${NC}"
echo -e "${RED}⚠️  This will delete Terraform state!${NC}"
echo -e "${YELLOW}Do you want to delete S3 backend bucket? (yes/no)${NC}"
read -r DELETE_S3

if [ "$DELETE_S3" = "yes" ]; then
  BUCKET_NAME="terraform-state-url-shortener-${AWS_ACCOUNT_ID}"
  
  # Check if bucket exists
  BUCKET_EXISTS=$(aws s3 ls s3://${BUCKET_NAME} 2>/dev/null || echo "")
  
  if [ -n "$BUCKET_EXISTS" ]; then
    echo -e "${YELLOW}Emptying S3 bucket...${NC}"
    
    # Delete all objects
    aws s3 rm s3://${BUCKET_NAME} --recursive
    
    # Delete bucket
    aws s3 rb s3://${BUCKET_NAME} --force 2>/dev/null || \
      echo -e "${YELLOW}⚠ Bucket may have versioned objects, check AWS Console${NC}"
    
    echo -e "${GREEN}✓ S3 bucket deleted${NC}"
  else
    echo -e "${GREEN}✓ No S3 bucket found${NC}"
  fi
else
  echo -e "${YELLOW}⊘ Skipping S3 cleanup${NC}"
fi

# ============================================================================
# STEP 5: Summary
# ============================================================================

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Verify in AWS Console:${NC}"
echo -e "1. ECR: https://console.aws.amazon.com/ecr"
echo -e "2. Route53: https://console.aws.amazon.com/route53"
echo -e "3. DynamoDB: https://console.aws.amazon.com/dynamodb"
echo -e "4. S3: https://console.aws.amazon.com/s3"
echo -e "5. CloudWatch Logs: https://console.aws.amazon.com/cloudwatch"
