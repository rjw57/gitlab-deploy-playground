locals {
  # Version of the gitlab chart to install. Manually increase this only after
  # testing.
  gitlab_chart_version = "1.2.4"

  db_name     = "${google_sql_database.gitlab.name}"
  db_username = "${google_sql_user.gitlab.name}"
  db_password = "${google_sql_user.gitlab.password}"

  db_password_secret           = "${kubernetes_secret.db_password.metadata.0.name}"
  db_proxy_credentials_secret  = "${kubernetes_secret.db_proxy_credentials.metadata.0.name}"
  backups_s3cfg_secret         = "${kubernetes_secret.backups_s3cfg.metadata.0.name}"
  saml_config_secret           = "${kubernetes_secret.saml_config.metadata.0.name}"

  # Actual domain we pass to the gitlab chart. Can be overridden.
  gitlab_domain = "${var.gitlab_domain == "" ? replace(var.dns_name, "/\\.$/", "") : var.gitlab_domain}"

  # The name of the cloud SQL proxy service within the k8s cluster.
  db_proxy_service = "${kubernetes_service.cloud_sql_proxy.metadata.0.name}"

  # K8s namespace created for this release.
  k8s_namespace = "${kubernetes_namespace.gitlab.metadata.0.name}"

  # External hostname of gitlab frontend
  gitlab_external_host = "gitlab.${local.gitlab_domain}"
}
