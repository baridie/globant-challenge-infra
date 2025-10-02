# Globant Data Engineering Challenge - Infrastructure

## Overview

This repository contains the Infrastructure as Code (IaC) implementation for the Globant Data Engineering Challenge using Terraform and Google Cloud Platform. The solution deploys a serverless architecture with two REST APIs for historical data migration and analytics.

## Architecture Components

The infrastructure deploys the following GCP resources:

**Cloud Run Services**: Two serverless container services deployed in `us-central1`:
- Upload API: Handles CSV file uploads and batch data insertion (1-1000 rows per request)
- Query API: Provides analytics endpoints for business intelligence queries

Both services use auto-scaling (0-10 instances) with 1 CPU and 512MB memory per instance.

**BigQuery Dataset**: SQL data warehouse containing three tables:
- `departments`: id (INTEGER), department (STRING)
- `jobs`: id (INTEGER), job (STRING)  
- `hired_employees`: id (INTEGER), name (STRING), datetime (TIMESTAMP), department_id (INTEGER), job_id (INTEGER)

The hired_employees table is partitioned by datetime and clustered by department_id and job_id for optimal query performance.

**Cloud Storage**: GCS bucket for temporary data file storage with versioning enabled and 30-day lifecycle policy for automatic cleanup.

**Artifact Registry**: Docker image repository for storing application container images.

**IAM & Security**:
- Separate service accounts for Upload API (write access) and Query API (read-only access)
- API keys stored in Secret Manager with automatic rotation capability
- Principle of least privilege access controls

**State Management**: Terraform state stored in GCS bucket with versioning enabled for collaboration and rollback capabilities.

## Prerequisites

- GCP account with billing enabled
- gcloud CLI installed and configured
- Terraform >= 1.0
- Project ID: `globant-challenge-473721`

## Quick Start

### Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd globant-challenge-infra

# Run GCP setup script
chmod +x scripts/setup-gcp.sh
./scripts/setup-gcp.sh

# Load environment variables
source ~/api-keys.txt
```

The setup script will:
- Enable required GCP APIs
- Create Terraform service account with necessary permissions
- Generate and save API keys to `~/api-keys.txt`
- Create GCS bucket for Terraform state

### Deploy Infrastructure

Using Make commands:

```bash
make init      # Initialize Terraform
make plan      # Preview infrastructure changes
make apply     # Deploy infrastructure
make outputs   # Display deployment outputs
make test      # Test API endpoints
make destroy   # Tear down infrastructure
```

Or using Terraform directly:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## API Functionality

**Upload API Endpoints**:
- `POST /api/v1/upload/departments` - Upload departments CSV
- `POST /api/v1/upload/jobs` - Upload jobs CSV
- `POST /api/v1/upload/hired_employees` - Upload employees CSV
- Supports batch inserts from 1 to 1000 rows per request

**Query API Endpoints**:
- `GET /api/v1/query/employees-by-quarter` - Employees hired by job and department in 2021, grouped by quarter
- `GET /api/v1/query/departments-above-mean` - Departments that hired more than the mean in 2021

All endpoints require API key authentication via header.

## Configuration

Key variables configured in `terraform/variables.tf`:

- `project_id`: GCP project identifier (default: globant-challenge-473721)
- `region`: Deployment region (default: us-central1)
- `environment`: Environment name (dev/prod)
- `upload_api_key`: API key for upload operations (sensitive)
- `query_api_key`: API key for query operations (sensitive)

## Security

The infrastructure implements multiple security layers:

- API keys stored in Secret Manager, never in code or logs
- Service accounts with minimal required permissions (Upload API has write access, Query API has read-only)
- Terraform state stored remotely in GCS with versioning
- Sensitive variables marked as sensitive in Terraform
- Cloud Run services use dedicated service accounts
- Storage bucket with uniform bucket-level access

## Outputs

After deployment, the following information is available:

```bash
make outputs
```

Key outputs include:
- Upload API URL
- Query API URL  
- BigQuery dataset ID
- Service account emails
- Storage bucket name
- Commands to retrieve API keys from Secret Manager

## Cost Optimization

The architecture is designed for cost efficiency:

- Cloud Run scales to zero when not in use (no idle charges)
- BigQuery charges only for queries executed and data stored
- Cloud Storage lifecycle policy deletes files after 30 days
- Partitioning and clustering reduce BigQuery scan costs

## Monitoring

Access logs and metrics through GCP Console:

- Cloud Run: Request latency, error rates, instance count
- BigQuery: Query performance, slot usage, storage size
- Cloud Storage: Request metrics, storage usage

## Cleanup

To remove all infrastructure:

```bash
make destroy
```

This will delete all resources except the Terraform state bucket (manual deletion required for safety).
