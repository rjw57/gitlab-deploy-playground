# locals.tf contain definitions for local variables which are of general utility
# within the configuration.

locals {
  # The project id and region as created by the project module.
  project = "${module.project.project_id}"
  region  = "${module.project.region}"

  # The DNS name (with trailing ".") created for this project.
  dns_name = "${module.zone.dns_name}"

  # The name of the GCP managed DNS zone created for this project.
  zone_name = "${module.zone.name}"

  # The name of the tiller service account.
  tiller_service_account = "${kubernetes_cluster_role_binding.tiller.subject.0.name}"

  # A kubeconfig-style configuration which can be used to connect to the k8s
  # cluster.
  kubeconfig_content = "${module.cluster.master_auth_kubeconfig}"
}
