# Create secrets for deployment

# Initial root password for gitlab
resource "random_string" "initial_root_password" {
  length = 48

  # To facilitate cut/paste and because the gitlab helm charts can sometimes be
  # sensitive to special characters.
  special = false
}

resource "kubernetes_secret" "initial_root_password" {
  metadata {
    name      = "gitlab-gitlab-initial-root-password"
    namespace = "${local.k8s_namespace}"
  }

  data {
    password = "${local.initial_root_password}"
  }
}

resource "kubernetes_secret" "db_password" {
  metadata {
    name      = "postgresql-password"
    namespace = "${local.k8s_namespace}"
  }

  data {
    username = "${local.db_username}"
    password = "${local.db_password}"
  }
}

resource "kubernetes_secret" "db_proxy_credentials" {
  metadata {
    name      = "cloudsql-credentials"
    namespace = "${local.k8s_namespace}"
  }

  data {
    credentials.json = "${var.sql_instance_credentials}"
  }
}

# Bogus s3cmd config for backups
resource "kubernetes_secret" "backups_s3cfg" {
  metadata {
    name      = "backups-s3cfg"
    namespace = "${local.k8s_namespace}"
  }

  # This config is based on the example in
  # https://gitlab.com/charts/gitlab/issues/721. Unfortunately GCS does not
  # support AWS-style authentication for service accounts and so these values
  # need to be manually poked in when running backups.
  #
  # Access and secret key can be generated in the interoperability
  # https://console.cloud.google.com/storage/settings
  # See Docs: https://cloud.google.com/storage/docs/interoperability
  data {
    s3cfg = <<EOF
[default]
access_key = $AWS_ACCESS_KEY_ID
secret_key = $AWS_SECRET_KEY

host_base = storage.googleapis.com
host_bucket = storage.googleapis.com
use_https = True
signature_v2 = True
enable_multipart = False
EOF
  }
}
