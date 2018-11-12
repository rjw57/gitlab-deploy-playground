# For convenience, define the project and region we pass into other modules
# here for easy editing.
locals {
  project = "${module.project.project_id}"
}

# The Google cloud zone DNS name which all resources will live in
locals {
  dns_name = "${module.zone.dns_name}"
  zone     = "${module.zone.name}"
}

# Google project for the deployment. Unlike resources elsewhere, resources
# created by this module use the terraform admin service account.
module "project" {
  source                      = "./project"
  project_name                = "${local.project_name}"
  billing_account             = "${local.billing_account}"
  folder_id                   = "${local.folder_id}"
  generated_project_id_prefix = "${local.generated_project_id_prefix}"
  region                      = "${local.region}"

  # Additional services to enable in the project. Any services enabled manually
  # or via Google's infrastructure will not be disabled.
  additional_services = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
  ]

  # This list is non-authoritative; if someone has the role/editor role on the
  # project but does not appear on this list, they won't lose that role binding.
  editors = []
}

# A new DNS zone for this project.
module "zone" "zone" {
  project = "${local.project}"
  source  = "./zone"
}
