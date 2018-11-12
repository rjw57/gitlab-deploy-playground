# Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  project = "${var.project}"
  region  = "${var.region}"

  name             = "${var.name}"
  database_version = "POSTGRES_9_6"

  settings {
    tier              = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_autoresize   = true

    backup_configuration {
      enabled = true
    }
  }
}

# Service account for database user
resource "google_service_account" "cloud-sql-client" {
  project      = "${var.project}"
  account_id   = "cloud-sql-client-${var.name}"
  display_name = "Cloud SQL client"
}

resource "google_project_iam_member" "cloud-sql-client" {
  project = "${var.project}"
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud-sql-client.email}"
}

resource "google_service_account_key" "cloud-sql-client" {
  service_account_id = "${google_service_account.cloud-sql-client.name}"
}
