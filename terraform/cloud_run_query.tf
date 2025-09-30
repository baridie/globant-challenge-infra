# Cloud Run Service - Query API
resource "google_cloud_run_service" "query_api" {
  name     = "globant-query-api-${var.environment}"
  location = var.region
  
  template {
    spec {
      service_account_name = google_service_account.query_api_sa.email
      
      containers {
        image = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/globant-challenge/query-api:latest"
        
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
          value = google_secret_manager_secret.query_api_key.secret_id
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
        api         = "query"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
    ]
  }
}

# Allow unauthenticated access (API Key will be validated in the app)
resource "google_cloud_run_service_iam_member" "query_api_public_access" {
  service  = google_cloud_run_service.query_api.name
  location = google_cloud_run_service.query_api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}