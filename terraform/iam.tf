# ========================================
# SERVICE ACCOUNTS
# ========================================

resource "google_service_account" "upload_api_sa" {
  account_id   = "upload-api-sa-${var.environment}"
  display_name = "Upload API Service Account - ${upper(var.environment)}"
  description  = "Service account for Upload API to write to BigQuery"
}

resource "google_service_account" "query_api_sa" {
  account_id   = "query-api-sa-${var.environment}"
  display_name = "Query API Service Account - ${upper(var.environment)}"
  description  = "Service account for Query API to read from BigQuery"
}

# ========================================
# BIGQUERY PERMISSIONS - UPLOAD API
# ========================================

# Upload API - Write permissions to RAW dataset
resource "google_bigquery_dataset_iam_member" "upload_api_raw_editor" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

# # Upload API - Read permissions to STG and CRT (for validations)
# resource "google_bigquery_dataset_iam_member" "upload_api_stg_viewer" {
#   dataset_id = google_bigquery_dataset.stg.dataset_id
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.upload_api_sa.email}"
# }

# resource "google_bigquery_dataset_iam_member" "upload_api_crt_viewer" {
#   dataset_id = google_bigquery_dataset.crt.dataset_id
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.upload_api_sa.email}"
# }

resource "google_project_iam_member" "upload_api_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.upload_api_sa.email}"
}

# ========================================
# BIGQUERY PERMISSIONS - QUERY API
# ========================================

# Query API - Read permissions to all datasets
# resource "google_bigquery_dataset_iam_member" "query_api_raw_viewer" {
#   dataset_id = google_bigquery_dataset.raw.dataset_id
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.query_api_sa.email}"
# }

# resource "google_bigquery_dataset_iam_member" "query_api_stg_viewer" {
#   dataset_id = google_bigquery_dataset.stg.dataset_id
#   role       = "roles/bigquery.dataViewer"
#   member     = "serviceAccount:${google_service_account.query_api_sa.email}"
# }

resource "google_bigquery_dataset_iam_member" "query_api_crt_viewer" {
  dataset_id = google_bigquery_dataset.crt.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.query_api_sa.email}"
}

resource "google_project_iam_member" "query_api_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.query_api_sa.email}"
}

# ========================================
# STORAGE PERMISSIONS
# ========================================

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

# ========================================
# SECRET MANAGER
# ========================================

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

resource "google_secret_manager_secret_version" "upload_api_key_version" {
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

resource "google_secret_manager_secret_version" "query_api_key_version" {
  secret      = google_secret_manager_secret.query_api_key.id
  secret_data = var.query_api_key
}

# Secret Manager IAM
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
