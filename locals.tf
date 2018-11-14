# locals.tf contain definitions for local variables which are of general utility
# within the configuration.

locals {
  # The project id and region as created by the project module.
  project = "${module.project.project_id}"
  region  = "${module.project.region}"

  # The DNS name and GCP name of the managed DNS zone created for this project.
  dns_name  = "${module.project.dns_name}"
  zone_name = "${module.project.zone_name}"

  # A kubeconfig file which contains configuration allowing admin user access to
  # the GKE cluster for the project.
  #
  # If this local is used in a resource then the resource will have an implicit
  # dependency on both the cluster creation *and* the creation of all the
  # related node pools.
  kubeconfig_path = "${local_file.kubeconfig.filename}"

  # The "helm home" which is configured to allow installation of our vendored
  # charts.
  #
  # If this local is used in a resource then the resource will have an implicit
  # dependency on the local helm client being appropriately configured.
  helm_home = "${module.helm.home}"
}
