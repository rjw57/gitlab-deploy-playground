# outputs.tf contain the defined outputs for the module

# JSON-formatted credentials for a service account which can connect to the
# instance via the Cloud SQL proxy.
output "service_account_credentials" {
  value = "${base64decode(google_service_account_key.cloud-sql-client.private_key)}"
}

# The full connection name for the instance as passed to the Cloud SQL proxy.
output "connection_name" {
  value = "${google_sql_database_instance.instance.connection_name}"
}

# The name of the GCP resource representing this instance.
output "name" {
  value = "${google_sql_database_instance.instance.name}"
}
