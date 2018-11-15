# storage.tf configures Google Cloud storage buckets and associated kubernetes
# secrets which contain credentials of users with access to the buckets.
#
# TODO: create backup buckets.

# A random prefix for buckets
resource "random_id" "bucket_prefix" {
  byte_length = 4
  prefix      = "gitlab-${var.name}-"
}

locals {
  bucket_prefix = "${random_id.bucket_prefix.hex}"
}

# Backup buckets
resource "google_storage_bucket" "backup" {
  name          = "${local.bucket_prefix}-backup"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket" "backup_temp" {
  name          = "${local.bucket_prefix}-backup-temp"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

# Docker image registry
module "registry_service_account" {
  source       = "./service_account"
  account_id   = "registry-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "registry" {
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

# Uploads
module "uploads_service_account" {
  source       = "./service_account"
  account_id   = "uploads-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "uploads" {
  name          = "${local.bucket_prefix}-uploads"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "uploads" {
  bucket = "${google_storage_bucket.uploads.name}"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.uploads_service_account.email}"
}

resource "kubernetes_secret" "uploads" {
  metadata {
    name      = "uploads-storage"
    namespace = "${local.k8s_namespace}"
  }

  data {
    config = <<EOF
provider: Google
google_project: "${google_storage_bucket.uploads.project}"
google_client_email: "${module.uploads_service_account.email}"
google_json_key_string: '${module.uploads_service_account.private_key}'
EOF
  }
}

locals {
  uploads_storage_bucket = "${google_storage_bucket.uploads.name}"
  uploads_storage_secret = "${kubernetes_secret.uploads.metadata.0.name}"
  uploads_storage_key    = "config"
}

# LFS
module "lfs_service_account" {
  source       = "./service_account"
  account_id   = "lfs-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "lfs" {
  name          = "${local.bucket_prefix}-lfs"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "lfs" {
  bucket = "${google_storage_bucket.lfs.name}"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.lfs_service_account.email}"
}

resource "kubernetes_secret" "lfs" {
  metadata {
    name      = "lfs-storage"
    namespace = "${local.k8s_namespace}"
  }

  data {
    config = <<EOF
provider: Google
google_project: "${google_storage_bucket.lfs.project}"
google_client_email: "${module.lfs_service_account.email}"
google_json_key_string: '${module.lfs_service_account.private_key}'
EOF
  }
}

locals {
  lfs_storage_bucket = "${google_storage_bucket.uploads.name}"
  lfs_storage_secret = "${kubernetes_secret.uploads.metadata.0.name}"
  lfs_storage_key    = "config"
}

# Artifacts
module "artifacts_service_account" {
  source       = "./service_account"
  account_id   = "artifacts-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "artifacts" {
  name          = "${local.bucket_prefix}-artifacts"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "artifacts" {
  bucket = "${google_storage_bucket.artifacts.name}"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.artifacts_service_account.email}"
}

resource "kubernetes_secret" "artifacts" {
  metadata {
    name      = "artifacts-storage"
    namespace = "${local.k8s_namespace}"
  }

  data {
    config = <<EOF
provider: Google
google_project: "${google_storage_bucket.artifacts.project}"
google_client_email: "${module.artifacts_service_account.email}"
google_json_key_string: '${module.artifacts_service_account.private_key}'
EOF
  }
}

locals {
  artifacts_storage_bucket = "${google_storage_bucket.artifacts.name}"
  artifacts_storage_secret = "${kubernetes_secret.artifacts.metadata.0.name}"
  artifacts_storage_key    = "config"
}

# Packages
module "packages_service_account" {
  source       = "./service_account"
  account_id   = "packages-storage"
  display_name = "Docker Image Registry Storage"
}

resource "google_storage_bucket" "packages" {
  name          = "${local.bucket_prefix}-packages"
  location      = "europe-west2"
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_iam_member" "packages" {
  bucket = "${google_storage_bucket.packages.name}"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.packages_service_account.email}"
}

resource "kubernetes_secret" "packages" {
  metadata {
    name      = "packages-storage"
    namespace = "${local.k8s_namespace}"
  }

  data {
    config = <<EOF
provider: Google
google_project: "${google_storage_bucket.packages.project}"
google_client_email: "${module.packages_service_account.email}"
google_json_key_string: '${module.packages_service_account.private_key}'
EOF
  }
}

locals {
  packages_storage_bucket = "${google_storage_bucket.packages.name}"
  packages_storage_secret = "${kubernetes_secret.packages.metadata.0.name}"
  packages_storage_key    = "config"
}
