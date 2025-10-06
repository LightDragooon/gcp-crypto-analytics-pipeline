# main.tf

# Variables
variable "gcp_project_id" {
  type        = string
  description = "ID of my GCP project"
}

variable "gcp_region" {
  type        = string
  description = "Region of GCP to deploy the resources (us-east1)."
}

# Google configuration 
provider "google" {
  project = var.gcp_project_id # "data-engineer-demo-a"
  region  = var.gcp_region # "us-east1"
}

# Enable necessary APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "artifactregistry.googleapis.com"
  ])
  service                    = each.key
  disable_dependent_services = true
}

# Resource: Pub/Sub topic that will buffer the messages
resource "google_pubsub_topic" "crypto_ingest" {
  name    = "crypto-ingest-topic"
  depends_on = [
    google_project_service.apis
  ]
}

# Resource: Big Query dataset for the data warehouse
resource "google_bigquery_dataset" "data_warehouse" {
  dataset_id = "crypto_data_warehouse"
  depends_on = [
    google_project_service.apis
  ]
}

# Resource: Landing table in Big Query for RAW data
resource "google_bigquery_table" "raw_data_landing" {
  dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  table_id   = "raw_price_data"
  schema = jsonencode([
    {
      "name" : "payload",
      "type" : "JSON",
      "mode" : "NULLABLE"
    },
    {
      "name" : "ingestion_timestamp",
      "type" : "TIMESTAMP",
      "mode" : "NULLABLE"
    }
  ])
  depends_on = [
    google_bigquery_dataset.data_warehouse
  ]
}

# Resource: Store the coingecko API Key in Secret Manager
resource "google_secret_manager_secret" "coingecko_api_key" {
  secret_id = "coingecko-api-key"
  replication {
    auto {}
  }
  depends_on = [
    google_project_service.apis
  ]
}

# Resource: Cloud Scheduler for invoking the ingest function
# Note: Configuration of target URL will occur after deploying the Cloud Function
resource "google_cloud_scheduler_job" "ingest_scheduler" {
  name        = "invoke-crypto-ingest-function"
  schedule    = "*/2 * * * *" # Every 2 minutes
  time_zone   = "Etc/UTC"
  description = "Triggers the CoinGecko API ingest function."

  http_target {
    http_method = "GET"
    uri         = "https://${var.gcp_region}-${var.gcp_project_id}.cloudfunctions.net/ingest-api-data"
  }
  depends_on = [
    google_project_service.apis
  ]
}

# Output: Show the names of the resources created
output "pubsub_topic_name" {
  value = google_pubsub_topic.crypto_ingest.name
}

output "bigquery_dataset_id" {
  value = google_bigquery_dataset.data_warehouse.dataset_id
}

output "bigquery_raw_table_id" {
  value = google_bigquery_table.raw_data_landing.table_id
}

output "secret_id" {
  value = google_secret_manager_secret.coingecko_api_key.secret_id
}