output "service_account_credentials" {
  value = "${base64decode(google_service_account_key.cloud-sql-client.private_key)}"
}

output "connection_name" {
  value = "${google_sql_database_instance.instance.connection_name}"
}

output "name" {
  value = "${google_sql_database_instance.instance.name}"
}
