terraform {
  backend "gcs" {
    bucket = "globant-challenge-473721-terraform-state"
    prefix = "terraform/state"
  }
}