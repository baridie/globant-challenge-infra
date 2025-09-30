provider "google" {
  project = var.project_id
  region  = var.region
}

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "repo" {
  location      = var.artifact_registry_location
  repository_id = "globant-challenge"
  description   = "Docker repository"
  format        = "DOCKER"
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}

# Cloud Storage bucket for data files
resource "google_storage_bucket" "data_bucket" {
  name          = "${var.project_id}-data-${var.environment}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
}