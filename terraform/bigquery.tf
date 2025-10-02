# ========================================
# DATASETS - Medallion Architecture
# ========================================

# Raw Dataset - Datos crudos sin procesar
resource "google_bigquery_dataset" "raw" {
  dataset_id                 = "raw_${var.environment}"
  friendly_name              = "Raw Dataset - ${upper(var.environment)}"
  description               = "Raw data layer - unprocessed data from source systems"
  location                  = var.region
  default_table_expiration_ms = null
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "raw"
    project     = "globant-challenge"
  }
}

# Staging Dataset - Datos en proceso de transformación
resource "google_bigquery_dataset" "stg" {
  dataset_id                 = "stg_${var.environment}"
  friendly_name              = "Staging Dataset - ${upper(var.environment)}"
  description               = "Staging data layer - data in transformation process"
  location                  = var.region
  default_table_expiration_ms = null
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "stg"
    project     = "globant-challenge"
  }
}

# Curated Dataset - Datos limpios y procesados para producción
resource "google_bigquery_dataset" "crt" {
  dataset_id                 = "crt_${var.environment}"
  friendly_name              = "Curated Dataset - ${upper(var.environment)}"
  description               = "Curated data layer - clean, production-ready data"
  location                  = var.region
  default_table_expiration_ms = null
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "crt"
    project     = "globant-challenge"
  }
}

# ========================================
# RAW LAYER TABLES
# ========================================

# Raw: Departments Table
resource "google_bigquery_table" "raw_departments" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "departments"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "raw"
  }
  
  # table_constraints {
  #   primary_key {
  #     columns = ["id"]
  #   }
  # }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "ID of the department"
    },
    {
      name        = "department"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Name of the department"
    },
    {
      name        = "loaded_at"
      type        = "TIMESTAMP"
      mode        = "NULLABLE"
      description = "Timestamp when record was loaded"
    }
  ])
}

# Raw: Jobs Table
resource "google_bigquery_table" "raw_jobs" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "jobs"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "raw"
  }
  
  # table_constraints {
  #   primary_key {
  #     columns = ["id"]
  #   }
  # }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "ID of the job"
    },
    {
      name        = "job"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Name of the job"
    },
    {
      name        = "loaded_at"
      type        = "TIMESTAMP"
      mode        = "NULLABLE"
      description = "Timestamp when record was loaded"
    }
  ])
}

# Raw: Hired Employees Table
resource "google_bigquery_table" "raw_hired_employees" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "hired_employees"
  
  deletion_protection = false
  
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    layer       = "raw"
  }
  
  # table_constraints {
  #   primary_key {
  #     columns = ["id"]
  #   }
  # }
  
  schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "ID of the employee"
    },
    {
      name        = "name"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Name and surname of the employee"
    },
    {
      name        = "datetime"
      type        = "STRING"
      mode        = "NULLABLE"
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
    },
    {
      name        = "loaded_at"
      type        = "TIMESTAMP"
      mode        = "NULLABLE"
      description = "Timestamp when record was loaded"
    }
  ])
  

}