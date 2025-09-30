# Cloud Run Service - Upload API
resource "google_cloud_run_service" "upload_api" {
  name     = "globant-upload-api-${var.environment}"
  location = var.region
  
  template {
    spec {
      service_account_name = google_service_account.upload_api_sa.email
      
      containers {
        # Imagen placeholder - será reemplazada por GitHub Actions
        image = "gcr.io/cloudrun/placeholder"
        
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        
        env {
          name  = "DATASET_ID"
          value = google_bigquery_dataset.globant.dataset_id
        }
        
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        
        env {
          name  = "API_KEY_SECRET"
          value = google_secret_manager_secret.upload_api_key.secret_id
        }
        
        env {
          name  = "BUCKET_NAME"
          value = google_storage_bucket.data_bucket.name
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        ports {
          container_port = 8080
        }
      }
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "10"
        "autoscaling.knative.dev/minScale" = "0"
        "run.googleapis.com/startup-cpu-boost" = "true"
      }
      
      labels = {
        environment = var.environment
        managed-by  = "terraform"
        api         = "upload"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  # IMPORTANTE: Ignorar cambios en la imagen
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}

# Allow unauthenticated access (API Key will be validated in the app)
resource "google_cloud_run_service_iam_member" "upload_api_public_access" {
  service  = google_cloud_run_service.upload_api.name
  location = google_cloud_run_service.upload_api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}