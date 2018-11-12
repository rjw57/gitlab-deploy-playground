# Local variables used elsewhere in the configuration
locals {
  db_name     = "gitlab-${var.name}"
  db_username = "gitlab-${var.name}"
}

# Initial root password for gitlab
resource "random_string" "initial_root_password" {
  length = 48
}

locals {
  initial_root_password = "${random_string.initial_root_password.result}"
}

# Interpolate values for Gitlab chart
data "template_file" "chart_values" {
  template = "${file("${path.module}/chart-values.template.yaml")}"

  vars {
    domain        = "${var.domain}"
    ip_address    = "${google_compute_address.static-ip.address}"
    storage_class = "${var.storage_class}"

    db_name                     = "${local.db_name}"
    db_username                 = "${local.db_username}"
    db_connection_name          = "${var.sql_instance_connection_name}"
    db_proxy_service            = "${local.db_proxy_service}"
    db_proxy_credentials_secret = "${local.db_proxy_credentials_secret}"
    db_password_secret          = "${local.db_password_secret}"
    db_password_key             = "password"
  }
}

resource "helm_release" "gitlab" {
  name      = "gitlab"
  chart     = "${var.chart}"
  namespace = "${local.k8s_namespace}"

  timeout       = 1200
  recreate_pods = true

  values = [
    "${data.template_file.chart_values.rendered}",
  ]

  depends_on = [
    "kubernetes_secret.initial_root_password",
    "kubernetes_secret.db_password",
    "kubernetes_secret.db_proxy_credentials",
    "kubernetes_service.cloud_sql_proxy",
  ]
}
