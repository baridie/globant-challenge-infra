variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "globant-challenge-473721"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment (dev/prd)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "prd"], var.environment)
    error_message = "Environment must be either 'dev' or 'prd'."
  }
}

variable "upload_api_key" {
  description = "API Key for Upload API"
  type        = string
  sensitive   = true
}

variable "query_api_key" {
  description = "API Key for Query API"
  type        = string
  sensitive   = true
}

variable "artifact_registry_location" {
  description = "Location for Artifact Registry"
  type        = string
  default     = "us-central1"
}