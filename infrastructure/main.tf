# Configuration for this module
locals {
  release_name = "production"
}

# Configuration from project state
locals {
  dns_name  = "${data.terraform_remote_state.project.dns_name}"
  zone_name = "${data.terraform_remote_state.project.zone_name}"
  project   = "${data.terraform_remote_state.project.project_id}"
  region    = "${data.terraform_remote_state.project.region}"
}

# K8s cluster
module "cluster" {
  source  = "./cluster"
  project = "${local.project}"
  region  = "${local.region}"

  machine_type = "n1-standard-2"
}

# Cloud SQL instance
module "cloud_sql_instance" {
  source = "./sqlinstance"

  project = "${local.project}"
  region  = "${local.region}"

  name = "psql"
}

# Tiller
module "tiller" {
  source = "./tiller"
}


# Random id generator used to generate random project id.
resource "random_id" "domain" {
  byte_length = 4
  prefix      = "${local.release_name}-"
}

# Release
module "gitlab" {
  source = "./gitlab"

  project = "${local.project}"
  region  = "${local.region}"

  name  = "${local.release_name}"
  chart = "${path.module}/../charts/gitlab"

  zone   = "${local.zone_name}"
  domain = "${random_id.domain.hex}.${local.dns_name}"

  # BUG: this needs to be created outside of terraform for the moment.
  # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/131
  storage_class = "retain-ssd"

  sql_instance                 = "${module.cloud_sql_instance.name}"
  sql_instance_connection_name = "${module.cloud_sql_instance.connection_name}"
  sql_instance_credentials     = "${module.cloud_sql_instance.service_account_credentials}"
}
