#!/bin/bash

# Build and push Docker image to ECR
# Usage: ./scripts/build-and-push.sh [version]

set -e

VERSION=${1:-v1}
AWS_REGION="eu-north-1"
AWS_ACCOUNT="501235162976"
ECR_REPO="url-shortener"
IMAGE_URI="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

echo "🔨 Building Docker image..."
docker build --platform linux/amd64 -t ${ECR_REPO}:${VERSION} ./app

echo "🏷️  Tagging image..."
docker tag ${ECR_REPO}:${VERSION} ${IMAGE_URI}:${VERSION}
docker tag ${ECR_REPO}:${VERSION} ${IMAGE_URI}:latest

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${IMAGE_URI}

echo "📤 Pushing image to ECR..."
docker push ${IMAGE_URI}:${VERSION}
docker push ${IMAGE_URI}:latest

echo "✅ Done! Image pushed: ${IMAGE_URI}:${VERSION}"
