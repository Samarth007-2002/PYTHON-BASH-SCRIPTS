#!/bin/bash

# Variables
REGION="us-west-2"  # Replace with your preferred AWS region

# Fetch all existing repositories
echo "Fetching existing ECR repositories..."
REPO_LIST=$(aws ecr describe-repositories --region $REGION --query 'repositories[*].repositoryName' --output text)

if [ $? -ne 0 ]; then
  echo "Failed to fetch ECR repositories."
  exit 1
fi

# Loop through each repository and enable scanning
for REPO_NAME in $REPO_LIST
do
  echo "Enabling image scanning for repository: $REPO_NAME"

  # Enable basic image scanning (scanOnPush=true)
  aws ecr put-image-scanning-configuration \
    --repository-name $REPO_NAME \
    --image-scanning-configuration scanOnPush=true \
    --region $REGION

  if [ $? -ne 0 ]; then
    echo "Failed to enable image scanning for repository: $REPO_NAME."
    continue
  fi

  echo "Basic image scanning enabled for repository: $REPO_NAME."
done

echo "Image scanning enabled for all repositories."
