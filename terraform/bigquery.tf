# BigQuery Dataset
resource "google_bigquery_dataset" "globant" {
  dataset_id                 = "globant_${var.environment}"
  friendly_name              = "Globant Challenge Dataset - ${upper(var.environment)}"
  description               = "Dataset for Globant Data Engineering Challenge"
  location                  = var.region
  default_table_expiration_ms = null
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = "globant-challenge"
  }
  
  access {
    role          = "OWNER"
    user_by_email = google_service_account.upload_api_sa.email
  }
  
  access {
    role          = "READER"
    user_by_email = google_service_account.query_api_sa.email
  }
}

# Departments Table
resource "google_bigquery_table" "departments" {
  dataset_id = google_bigquery_dataset.globant.dataset_id
  table_id   = "departments"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "REQUIRED"
      description = "ID of the department"
    },
    {
      name        = "department"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Name of the department"
    }
  ])
}

# Jobs Table
resource "google_bigquery_table" "jobs" {
  dataset_id = google_bigquery_dataset.globant.dataset_id
  table_id   = "jobs"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "REQUIRED"
      description = "ID of the job"
    },
    {
      name        = "job"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Name of the job"
    }
  ])
}

# Hired Employees Table
resource "google_bigquery_table" "hired_employees" {
  dataset_id = google_bigquery_dataset.globant.dataset_id
  table_id   = "hired_employees"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
  }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "REQUIRED"
      description = "ID of the employee"
    },
    {
      name        = "name"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Name and surname of the employee"
    },
    {
      name        = "datetime"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Hire datetime in ISO format"
    },
    {
      name        = "department_id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "ID of the department"
    },
    {
      name        = "job_id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "ID of the job"
    }
  ])
  
  time_partitioning {
    type  = "DAY"
    field = "datetime"
  }
  
  clustering = ["department_id", "job_id"]
}