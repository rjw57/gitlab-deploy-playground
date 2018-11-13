# Configure database and database user

# A password for the database user. Note that terraform uses a cryptographic
# random string generator.
resource "random_string" "db_password" {
  length = 32

  # Empirically, bits of the chart have trouble with special characters in the
  # database password(!)
  special = false
}

locals {
  db_password = "${random_string.db_password.result}"
}

# Create a database and user for release
resource "google_sql_database" "gitlab" {
  project  = "${var.project}"
  name     = "${local.db_name}"
  instance = "${var.sql_instance}"
}

# Corresponding database user.
resource "google_sql_user" "gitlab" {
  project  = "${var.project}"
  name     = "${local.db_username}"
  instance = "${var.sql_instance}"
  password = "${local.db_password}"
}
