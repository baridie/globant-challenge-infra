#!/bin/bash

set -e

# Load configuration
if [ ! -f ~/api-keys.txt ]; then
    echo "Error: ~/api-keys.txt not found"
    exit 1
fi

source ~/api-keys.txt

# Get API URLs directly from Terraform
echo "Getting API URLs from Terraform..."
UPLOAD_API_URL=$(cd terraform && terraform output -raw upload_api_url 2>/dev/null)
QUERY_API_URL=$(cd terraform && terraform output -raw query_api_url 2>/dev/null)

echo "=========================================="
echo "Testing Globant Challenge APIs"
echo "=========================================="
echo "Upload API: $UPLOAD_API_URL"
echo "Query API: $QUERY_API_URL"
echo "=========================================="

# Test function with error handling
test_endpoint() {
    local name=$1
    local url=$2
    
    echo ""
    echo "$name..."
    response=$(curl -s -w "\n%{http_code}" "$url")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    echo "Status: $http_code"
    if [ "$http_code" -eq 200 ]; then
        echo "$body" | jq .
    else
        echo "ERROR: Expected 200, got $http_code"
        return 1
    fi
}

# Run tests
test_endpoint "1. Testing Upload API Health" "$UPLOAD_API_URL/health"
test_endpoint "2. Testing Query API Health" "$QUERY_API_URL/health"

# Test authentication
echo ""
echo "3. Testing authentication (should fail without API key)..."
test_endpoint "Authentication test" "$UPLOAD_API_URL/api/v1/upload/departments" || true

echo ""
echo "=========================================="
echo "Basic health checks completed!"
echo "For full testing with file uploads, use the test_from_pc.py script"
echo "=========================================="