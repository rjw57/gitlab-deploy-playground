# Local variables used elsewhere in the configuration
locals {
  db_name = "${var.name}"
}

# Initial root password for gitlab
resource "random_string" "initial_root_password" {
  length = 48
}

locals {
  initial_root_password = "${random_string.initial_root_password.result}"
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

# Interpolate values for Gitlab chart
data "template_file" "chart_values" {
  template = "${file("${path.module}/chart-values.template.yaml")}"

  vars {
    domain        = "${var.domain}"
    ip_address    = "${google_compute_address.static-ip.address}"
    storage_class = "${var.storage_class}"
  }
}

resource "helm_release" "gitlab" {
  name      = "gitlab"
  chart     = "${var.chart}"
  namespace = "${local.k8s_namespace}"

  timeout = 1200

  values = [
    "${data.template_file.chart_values.rendered}",
  ]

  depends_on = [
    "kubernetes_secret.initial_root_password",
  ]
}
