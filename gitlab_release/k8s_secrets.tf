# Create secrets for deployment

resource "kubernetes_secret" "initial_root_password" {
  metadata {
    name      = "gitlab-gitlab-initial-root-password"
    namespace = "${local.k8s_namespace}"
  }

  data {
    password = "${local.initial_root_password}"
  }
}

locals {
  initial_root_password_secret = "${kubernetes_secret.initial_root_password.metadata.0.name}"
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

locals {
  db_password_secret = "${kubernetes_secret.db_password.metadata.0.name}"
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

locals {
  db_proxy_credentials_secret = "${kubernetes_secret.db_proxy_credentials.metadata.0.name}"
}

# Bogus s3cmd config for backups
resource "kubernetes_secret" "backups_s3cfg" {
  metadata {
    name      = "backups-s3cfg"
    namespace = "${local.k8s_namespace}"
  }

  data {
    s3cfg = <<EOF
[default]
access_key = BOGUS_ACCESS_KEY
secret_key = BOGUS_SECRET_KEY
bucket_location = us-east-1
EOF
  }
}

locals {
  backups_s3cfg_secret = "${kubernetes_secret.backups_s3cfg.metadata.0.name}"
}
