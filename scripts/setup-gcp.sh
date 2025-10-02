#!/bin/bash

set -e

PROJECT_ID="globant-challenge-473721"
REGION="us-central1"

echo "=========================================="
echo "Setting up GCP for Globant Challenge"
echo "=========================================="

# Configure project
echo "→ Configuring GCP project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "→ Enabling required APIs..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  secretmanager.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com

# Create Service Account for Terraform
echo "→ Creating Terraform Service Account..."
if gcloud iam service-accounts describe terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com &>/dev/null; then
    echo "  Service account already exists"
else
    gcloud iam service-accounts create terraform-sa \
      --display-name="Terraform Service Account"
fi

# Assign roles
# Rol general de editor
echo "→ Assigning roles to Service Account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/editor"

# Permitir que Terraform use cuentas de servicio
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Cloud Run (crear y administrar servicios)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Cloud Build (ejecutar builds y usar workers)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

# Artifact Registry (manejar imágenes y repositorios)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

# Storage (crear buckets y objetos)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Secret Manager (crear y acceder a secretos)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/secretmanager.admin"

# BigQuery (crear datasets/tablas)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"

# Compute (redes, instancias, VPC)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# IAM (crear cuentas de servicio y llaves)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountAdmin"

# Resource Manager (gestionar IAM bindings a nivel de proyecto)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/resourcemanager.projectIamAdmin"


# Create key
echo "→ Creating Service Account key..."
if [ -f ~/terraform-key.json ]; then
    echo "  Key already exists at ~/terraform-key.json"
else
    gcloud iam service-accounts keys create ~/terraform-key.json \
      --iam-account=terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com
    echo "  ✓ Key created: ~/terraform-key.json"
fi

# Create Terraform state bucket
echo "→ Creating Terraform state bucket..."
if gsutil ls gs://${PROJECT_ID}-terraform-state &>/dev/null; then
    echo "  Bucket already exists"
else
    gsutil mb -p $PROJECT_ID -l $REGION gs://${PROJECT_ID}-terraform-state
    gsutil versioning set on gs://${PROJECT_ID}-terraform-state
    echo "  ✓ Bucket created: gs://${PROJECT_ID}-terraform-state"
fi

# Generate API Keys
echo "→ Generating API Keys..."
UPLOAD_API_KEY=$(openssl rand -hex 32)
QUERY_API_KEY=$(openssl rand -hex 32)

# Save API keys
cat > ~/api-keys.txt <<EOF
export UPLOAD_API_KEY="$UPLOAD_API_KEY"
export QUERY_API_KEY="$QUERY_API_KEY"
EOF

chmod 600 ~/api-keys.txt

echo ""
echo "=========================================="
echo "✓ GCP Setup Complete!"
echo "=========================================="
echo "API Keys saved to: ~/api-keys.txt"
echo "Terraform key saved to: ~/terraform-key.json"
echo ""
echo "Next steps:"
echo "  1. source ~/api-keys.txt"
echo "  2. cd terraform && terraform init"
echo "  3. Run ./scripts/deploy.sh"
echo "=========================================="