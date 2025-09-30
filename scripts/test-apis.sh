#!/bin/bash

set -e

# Load configuration
if [ ! -f ~/api-keys.txt ]; then
    echo "Error: ~/api-keys.txt not found"
    exit 1
fi

source ~/api-keys.txt

# Get API URLs from Terraform outputs
UPLOAD_API_URL=$(grep "upload_api_url" ~/terraform-outputs.txt | awk '{print $3}' | tr -d '"')
QUERY_API_URL=$(grep "query_api_url" ~/terraform-outputs.txt | awk '{print $3}' | tr -d '"')

echo "=========================================="
echo "Testing Globant Challenge APIs"
echo "=========================================="
echo "Upload API: $UPLOAD_API_URL"
echo "Query API: $QUERY_API_URL"
echo "=========================================="

# Test Upload API Health
echo ""
echo "1. Testing Upload API Health..."
curl -s "$UPLOAD_API_URL/health" | jq

# Test Query API Health
echo ""
echo "2. Testing Query API Health..."
curl -s "$QUERY_API_URL/health" | jq

# Test authentication (should fail without API key)
echo ""
echo "3. Testing authentication (should fail)..."
curl -s "$UPLOAD_API_URL/api/v1/upload/departments" | jq

# Note: File uploads would require actual CSV files
echo ""
echo "=========================================="
echo "Basic health checks completed!"
echo "For full testing with file uploads, use the test_from_pc.py script"
echo "=========================================="