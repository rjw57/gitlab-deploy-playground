# Provider configuration for Google Cloud Platform. Adapted from Google
# documentation at
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#
# Both the google and google-beta provider are configured identically with a
# project-specific service account.

provider "google" {
  credentials = "${data.terraform_remote_state.project.owner_service_account_credentials}"
}

provider "google-beta" {
  credentials = "${data.terraform_remote_state.project.owner_service_account_credentials}"
}

# K8s provider configured to have access to the cluster created by the cluster
# module.

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = "${module.cluster.endpoint}"
  token                  = "${data.google_client_config.current.access_token}"
  cluster_ca_certificate = "${base64decode(module.cluster.master_auth_cluster_ca_certificate)}"
}

provider "helm" {
  service_account = "${module.tiller.service_account}"

  kubernetes {
    host                   = "${module.cluster.endpoint}"
    token                  = "${data.google_client_config.current.access_token}"
    cluster_ca_certificate = "${base64decode(module.cluster.master_auth_cluster_ca_certificate)}"
  }
}
