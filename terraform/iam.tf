# Service Account for Upload API
resource "google_service_account" "upload_api_sa" {
  account_id   = "upload-api-sa-${var.environment}"
  display_name = "Upload API Service Account - ${upper(var.environment)}"
  description  = "Service account for Upload API to write to BigQuery"
}

# Service Account for Query API
resource "google_service_account" "query_api_sa" {
  account_id   = "query-api-sa-${var.environment}"
  display_name = "Query API Service Account - ${upper(var.environment)}"
  description  = "Service account for Query API to read from BigQuery"
}

# Permissions for Upload API - Write access
resource "google_bigquery_dataset_iam_member" "upload_api_data_editor" {
  dataset_id = google_bigquery_dataset.globant.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

resource "google_project_iam_member" "upload_api_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

# Permissions for Query API - Read only access
resource "google_bigquery_dataset_iam_member" "query_api_data_viewer" {
  dataset_id = google_bigquery_dataset.globant.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.query_api_sa.email}"
}

resource "google_project_iam_member" "query_api_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.query_api_sa.email}"
}

# Storage permissions for data bucket
resource "google_storage_bucket_iam_member" "upload_api_bucket_admin" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

resource "google_storage_bucket_iam_member" "query_api_bucket_viewer" {
  bucket = google_storage_bucket.data_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.query_api_sa.email}"
}

# Secret Manager for API Keys
resource "google_secret_manager_secret" "upload_api_key" {
  secret_id = "upload-api-key-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    api         = "upload"
  }
}

resource "google_secret_manager_secret_version" "upload_api_key" {
  secret      = google_secret_manager_secret.upload_api_key.id
  secret_data = var.upload_api_key
}

resource "google_secret_manager_secret" "query_api_key" {
  secret_id = "query-api-key-${var.environment}"
  
  replication {
    auto {}
  }
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    api         = "query"
  }
}

resource "google_secret_manager_secret_version" "query_api_key" {
  secret      = google_secret_manager_secret.query_api_key.id
  secret_data = var.query_api_key
}

# Permissions to access secrets
resource "google_secret_manager_secret_iam_member" "upload_api_secret_accessor" {
  secret_id = google_secret_manager_secret.upload_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "query_api_secret_accessor" {
  secret_id = google_secret_manager_secret.query_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.query_api_sa.email}"
}