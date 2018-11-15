# database.tf contains configuration for the  database and database user.

# A password for the database user. Note that terraform uses a cryptographic
# random string generator.
resource "random_string" "db_password" {
  length = 48

  # Empirically, bits of the chart have trouble with special characters in the
  # database password(!)
  special = false
}

# Create a database and user for release
resource "google_sql_database" "gitlab" {
  name     = "${var.name}"
  instance = "${var.sql_instance}"
}

# Corresponding database user.
resource "google_sql_user" "gitlab" {
  name     = "${var.name}"
  instance = "${var.sql_instance}"
  password = "${random_string.db_password.result}"
}
