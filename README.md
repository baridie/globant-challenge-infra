# Globant Challenge - Infrastructure

Infrastructure as Code (IaC) for the Globant Data Engineering Challenge using Terraform and Google Cloud Platform.

## 📋 Prerequisites

- GCP Account with billing enabled
- gcloud CLI installed
- Terraform >= 1.0
- Project ID: `globant-challenge-473721`

## 🏗️ Architecture

## 🚀 Quick Start

### 1. Initial Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd globant-challenge-infra

# Run setup script
chmod +x scripts/setup-gcp.sh
./scripts/setup-gcp.sh

# Load environment variables
source ~/api-keys.txt