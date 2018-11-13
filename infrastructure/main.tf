# Configuration from project state
locals {
  dns_name  = "${var.dns_name}"
  zone_name = "${var.zone_name}"
  project   = "${var.project}"
  region    = "${var.region}"
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
