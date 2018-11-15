# main.tf contains the top-level resources created by this module.

# Create a random name for the sql instance. We make it random because sql
# instance names cannot be re-used immediately.
resource "random_id" "instance_name" {
  byte_length = 4
  prefix      = "sql-"
}

# Cloud SQL instance. We don't specify a name because Cloud SQL instance names
# cannot be re-used for a stupidly long time so its better to let terraform
# generate one.
resource "google_sql_database_instance" "instance" {
  name = "${random_id.instance_name.hex}"

  # This is *required* for Cloud SQL instances, annoyingly.
  region = "${var.region}"

  database_version = "POSTGRES_9_6"

  settings {
    tier              = "${var.tier}"
    availability_type = "REGIONAL"
    disk_autoresize   = true

    backup_configuration {
      enabled = true
    }
  }
}

# Service account for database user with appropriate permissions to connect via
# the Cloud SQL proxy.
resource "google_service_account" "cloud-sql-client" {
  account_id   = "cloud-sql-client-${google_sql_database_instance.instance.name}"
  display_name = "Cloud SQL client"
}

resource "google_project_iam_member" "cloud-sql-client" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.cloud-sql-client.email}"
}

resource "google_service_account_key" "cloud-sql-client" {
  service_account_id = "${google_service_account.cloud-sql-client.name}"
}
