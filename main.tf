# main.tf contains the top-level resources created as part of the deployment. ot
# much work is actually done here; instead, we wire multiple modules together.

module "infrastructure" {
  source = "./infrastructure"

  project = "${local.project}"
  region  = "${local.region}"

  owner_service_account_credentials = "${module.project.owner_service_account_credentials}"

  dns_name  = "${local.dns_name}"
  zone_name = "${local.zone_name}"
}

# Create a kubeconfig for talking to the cluster
resource "local_file" "kubeconfig" {
  content  = "${module.infrastructure.cluster_kubeconfig}"
  filename = "${path.module}/secrets/kubeconfig"
}

module "retained_storage_class" {
  source = "./retained_storage_class"

  kubeconfig_path = "${local.kubeconfig_path}"
}

locals {
  release_name = "prod"
}

# Random id generator used to generate random domain for gitlab
resource "random_id" "domain" {
  byte_length = 2
  prefix      = "${local.release_name}-"

  # HACK: make this dependent on the chart deps having been updated so that we
  # don't try to perform a release before they've been updated.
  #
  # This works around the fact that modules cannot have a depends_on value set
  # directly so we have to se one on a dependent resource.
  depends_on = ["null_resource.gitlab_chart_deps"]
}

# Release
module "gitlab_release" {
  source = "./gitlab_release"

  name  = "${local.release_name}"
  chart = "${path.module}/charts/gitlab"

  zone   = "${local.zone_name}"
  domain = "${random_id.domain.hex}.${local.dns_name}"

  storage_class = "${module.retained_storage_class.name}"

  sql_instance                 = "${module.infrastructure.sql_instance_name}"
  sql_instance_connection_name = "${module.infrastructure.sql_instance_connection_name}"
  sql_instance_credentials     = "${module.infrastructure.sql_instance_proxy_credentials}"
}
