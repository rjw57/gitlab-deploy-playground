# main.tf contains the top-level resources created by this module.

# Kubernetes namespace for deployment
resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "${var.name}"
  }
}

# Run helm init command to install tiller. It's unfortunate that this is
# required but the helm provider does not seem to support tiller being installed
# via a service account very well just yet.
#
# The sorts of errors you'll get are documented in the following issues with
# some workarounds:
#
# https://github.com/terraform-providers/terraform-provider-helm/issues/122
# https://github.com/helm/helm/issues/3985
resource "null_resource" "init" {
  triggers {
    service_account = "${var.tiller_service_account}"
  }

  provisioner "local-exec" {
    command = <<EOF
TMPFILE="$(mktemp -p "${var.secrets_dir}" kubeconfig.XXXXX)" &&
echo "$KUBECONFIG_CONTENT" >"$TMPFILE" &&
KUBECONFIG="$TMPFILE" helm init --wait --service-account "${var.tiller_service_account}" &&
rm "$TMPFILE"
EOF

    environment {
      KUBECONFIG_CONTENT = "${var.kubeconfig_content}"
    }
  }
}

resource "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"

  depends_on = ["null_resource.init"]
}

resource "helm_release" "gitlab" {
  name      = "${var.name}"
  chart     = "${var.chart}"
  namespace = "${local.k8s_namespace}"

  timeout = 1200

  version = "${local.gitlab_chart_version}"

  # By default, new users cannot create groups. This does not affect the ability
  # of existing group owners to create subgroups and it does not change the "can
  # create groups" bit for existing users.
  set {
    name  = "global.appConfig.defaultCanCreateGroup"
    value = "false"
  }

  # Users (unless invited by others) will have their usernames match their
  # crsids. In general, we want to discourage changing usernames.
  set {
    name  = "global.appConfig.usernameChangingEnabled"
    value = "false"
  }

  # Components which should not be installed
  set {
    name  = "gitlab-runner.install"
    value = "false"
  }

  set {
    name  = "postgresql.install"
    value = "false"
  }

  set {
    name  = "global.minio.enabled"
    value = "false"
  }

  # Certmanager issuer
  set {
    name  = "certmanager-issuer.email"
    value = "${var.certmanager_email}"
  }

  # Database configuration
  set {
    name  = "global.psql.host"
    value = "${local.db_proxy_service}"
  }

  set {
    name  = "global.psql.password.secret"
    value = "${local.db_password_secret}"
  }

  set {
    name  = "global.psql.password.key"
    value = "password"
  }

  set {
    name  = "global.psql.database"
    value = "${local.db_name}"
  }

  set {
    name  = "global.psql.username"
    value = "${local.db_username}"
  }

  # Domain and external IP
  set {
    name  = "global.hosts.domain"
    value = "${local.gitlab_domain}"
  }

  set {
    name  = "global.hosts.externalIP"
    value = "${google_compute_address.static-ip.address}"
  }

  # Persistence
  set {
    name  = "redis.persistence.storageClass"
    value = "${var.storage_class}"
  }

  set {
    name  = "gitlab.gitaly.persistence.storageClass"
    value = "${var.storage_class}"
  }

  set {
    name  = "gitlab.gitaly.persistence.size"
    value = "${var.gitaly_persistence_size}"
  }

  # Backup object storage
  set {
    name  = "global.appConfig.backups.bucket"
    value = "${google_storage_bucket.backup.name}"
  }

  set {
    name  = "global.appConfig.backups.tmpBucket"
    value = "${google_storage_bucket.backup_temp.name}"
  }

  set {
    name  = "gitlab.task-runner.backups.objectStorage.config.secret"
    value = "${local.backups_s3cfg_secret}"
  }

  set {
    name  = "gitlab.task-runner.backups.objectStorage.config.key"
    value = "s3cfg"
  }

  # Uploads object storage
  set {
    name  = "global.appConfig.uploads.bucket"
    value = "${local.uploads_storage_bucket}"
  }

  set {
    name  = "global.appConfig.uploads.connection.secret"
    value = "${local.uploads_storage_secret}"
  }

  set {
    name  = "global.appConfig.uploads.connection.key"
    value = "${local.uploads_storage_key}"
  }

  # Lfs object storage
  set {
    name  = "global.appConfig.lfs.bucket"
    value = "${local.lfs_storage_bucket}"
  }

  set {
    name  = "global.appConfig.lfs.connection.secret"
    value = "${local.lfs_storage_secret}"
  }

  set {
    name  = "global.appConfig.lfs.connection.key"
    value = "${local.lfs_storage_key}"
  }

  # Artifacts object storage
  set {
    name  = "global.appConfig.artifacts.bucket"
    value = "${local.artifacts_storage_bucket}"
  }

  set {
    name  = "global.appConfig.artifacts.connection.secret"
    value = "${local.artifacts_storage_secret}"
  }

  set {
    name  = "global.appConfig.artifacts.connection.key"
    value = "${local.artifacts_storage_key}"
  }

  # Packages object storage
  set {
    name  = "global.appConfig.packages.bucket"
    value = "${local.packages_storage_bucket}"
  }

  set {
    name  = "global.appConfig.packages.connection.secret"
    value = "${local.packages_storage_secret}"
  }

  set {
    name  = "global.appConfig.packages.connection.key"
    value = "${local.packages_storage_key}"
  }

  # Configuration for docker image registry storage
  set {
    name  = "registry.storage.secret"
    value = "${local.registry_storage_secret}"
  }

  set {
    name  = "registry.storage.key"
    value = "${local.registry_storage_key}"
  }

  set {
    name  = "registry.storage.extraKey"
    value = "${local.registry_storage_extra_key}"
  }

  set {
    name  = "global.registry.bucket"
    value = "${local.registry_storage_bucket}"
  }

  # SAML configuration
  set {
    name  = "gitlab.unicorn.omniauth.enabled"
    value = "true"
  }

  set {
    name  = "gitlab.unicorn.omniauth.allowSingleSignOn[0]"
    value = "saml"
  }

  set {
    name  = "gitlab.unicorn.omniauth.blockAutoCreatedUsers"
    value = "false"
  }

  set {
    name  = "gitlab.unicorn.omniauth.autoLinkSamlUser"
    value = "true"
  }

  set {
    name  = "gitlab.unicorn.omniauth.providers[0].secret"
    value = "${local.saml_config_secret}"
  }

  set {
    name  = "gitlab.unicorn.omniauth.providers[0].key"
    value = "config"
  }

  depends_on = [
    "kubernetes_secret.initial_root_password",
    "kubernetes_service.cloud_sql_proxy",
    "google_dns_record_set.wildcard",
    "helm_repository.gitlab",
  ]
}
