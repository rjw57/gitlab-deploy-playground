# A random prefix for buckets
resource "random_id" "bucket_prefix" {
  byte_length = 4
  prefix      = "gitlab-${var.name}-"
}

locals {
  bucket_prefix = "${random_id.bucket_prefix.hex}"
}

# Docker image registry
module "registry_service_account" {
  source       = "./service_account"
  account_id   = "registry-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "registry" {
  project       = "${var.project}"
  name          = "${local.bucket_prefix}-registry"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "registry" {
  bucket = "${google_storage_bucket.registry.name}"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.registry_service_account.email}"
}

resource "kubernetes_secret" "registry" {
  metadata {
    name      = "registry-storage"
    namespace = "${local.k8s_namespace}"
  }

  data {
    credentials.json = "${module.registry_service_account.private_key}"

    config = <<EOF
gcs:
  bucket: "${google_storage_bucket.registry.name}"
  keyfile: "/etc/docker/registry/storage/credentials.json"
EOF
  }
}

locals {
  registry_storage_bucket    = "${google_storage_bucket.registry.name}"
  registry_storage_secret    = "${kubernetes_secret.registry.metadata.0.name}"
  registry_storage_key       = "config"
  registry_storage_extra_key = "credentials.json"
}
