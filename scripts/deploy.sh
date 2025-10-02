#!/bin/bash

set -e

PROJECT_ID="globant-challenge-473721"
REGION="us-central1"
ENVIRONMENT="dev"

echo "=========================================="
echo "Deploying Globant Challenge Infrastructure"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "Error: Must run from terraform directory"
    exit 1
fi

# Load API keys
if [ ! -f ~/api-keys.txt ]; then
    echo "Error: ~/api-keys.txt not found. Run setup-gcp.sh first"
    exit 1
fi

source ~/api-keys.txt

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/terraform-key.json

# Initialize Terraform
echo "→ Initializing Terraform..."
terraform init

# Validate configuration
echo "→ Validating Terraform configuration..."
terraform validate

# Plan
echo "→ Planning infrastructure changes..."
terraform plan \
  -var="project_id=$PROJECT_ID" \
  -var="region=$REGION" \
  -var="environment=$ENVIRONMENT" \
  -var="upload_api_key=$UPLOAD_API_KEY" \
  -var="query_api_key=$QUERY_API_KEY" \
  -out=tfplan

# Ask for confirmation
echo ""
read -p "Apply these changes? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Apply
echo "→ Applying infrastructure changes..."
terraform apply tfplan

# Save outputs
echo "→ Saving outputs..."
terraform output > ~/terraform-outputs.txt
terraform output -json > ~/terraform-outputs.json

# Display summary
echo ""
echo "=========================================="
echo "✓ Deployment Complete!"
echo "=========================================="
terraform output upload_api_url
terraform output query_api_url
terraform output bigquery_dataset_id
echo ""
echo "Outputs saved to:"
echo "  - ~/terraform-outputs.txt"
echo "  - ~/terraform-outputs.json"
echo "=========================================="