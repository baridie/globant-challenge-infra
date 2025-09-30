output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

output "environment" {
  description = "Environment"
  value       = var.environment
}

# BigQuery Outputs
output "bigquery_dataset_id" {
  description = "BigQuery Dataset ID"
  value       = google_bigquery_dataset.globant.dataset_id
}

output "bigquery_dataset_location" {
  description = "BigQuery Dataset Location"
  value       = google_bigquery_dataset.globant.location
}

# Cloud Run Outputs
output "upload_api_url" {
  description = "Upload API URL"
  value       = google_cloud_run_service.upload_api.status[0].url
}

output "query_api_url" {
  description = "Query API URL"
  value       = google_cloud_run_service.query_api.status[0].url
}

output "upload_api_service_name" {
  description = "Upload API Service Name"
  value       = google_cloud_run_service.upload_api.name
}

output "query_api_service_name" {
  description = "Query API Service Name"
  value       = google_cloud_run_service.query_api.name
}

# Service Account Outputs
output "upload_api_service_account" {
  description = "Upload API Service Account Email"
  value       = google_service_account.upload_api_sa.email
}

output "query_api_service_account" {
  description = "Query API Service Account Email"
  value       = google_service_account.query_api_sa.email
}

# Secret Manager Outputs
output "upload_api_key_secret" {
  description = "Upload API Key Secret Name"
  value       = google_secret_manager_secret.upload_api_key.secret_id
}

output "query_api_key_secret" {
  description = "Query API Key Secret Name"
  value       = google_secret_manager_secret.query_api_key.secret_id
}

# Artifact Registry Outputs
output "artifact_registry_url" {
  description = "Artifact Registry URL"
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/globant-challenge"
}

# Storage Outputs
output "data_bucket_name" {
  description = "Data Storage Bucket Name"
  value       = google_storage_bucket.data_bucket.name
}

output "data_bucket_url" {
  description = "Data Storage Bucket URL"
  value       = google_storage_bucket.data_bucket.url
}

# Commands to retrieve API Keys
output "get_upload_api_key_command" {
  description = "Command to retrieve Upload API Key"
  value       = "gcloud secrets versions access latest --secret=${google_secret_manager_secret.upload_api_key.secret_id} --project=${var.project_id}"
}

output "get_query_api_key_command" {
  description = "Command to retrieve Query API Key"
  value       = "gcloud secrets versions access latest --secret=${google_secret_manager_secret.query_api_key.secret_id} --project=${var.project_id}"
}

# Summary
output "deployment_summary" {
  description = "Deployment Summary"
  value = {
    upload_api = {
      url             = google_cloud_run_service.upload_api.status[0].url
      service_account = google_service_account.upload_api_sa.email
    }
    query_api = {
      url             = google_cloud_run_service.query_api.status[0].url
      service_account = google_service_account.query_api_sa.email
    }
    bigquery = {
      dataset  = google_bigquery_dataset.globant.dataset_id
      location = google_bigquery_dataset.globant.location
    }
  }
}