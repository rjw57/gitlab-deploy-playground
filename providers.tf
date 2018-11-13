# Provider configuration for Google Cloud Platform. Adapted from Google
# documentation at
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#
# Both the google and google-beta provider are configured identically with a
# project-specific service account.
provider "google" {
  credentials = "${module.project.owner_service_account_credentials}"

  project = "${module.project.project_id}"
  region  = "${module.project.region}"
}

provider "google-beta" {
  credentials = "${module.project.owner_service_account_credentials}"

  project = "${module.project.project_id}"
  region  = "${module.project.region}"
}

# Additional "admin" google providers which use the terraform admin service
# account. These are used to create the Google project itself and any resources
# outside of the Google project.
provider "google" {
  alias       = "admin"
  credentials = "${file("${path.module}/secrets/terraform-admin-service-account-credentials.json")}"
}

provider "google-beta" {
  alias       = "admin"
  credentials = "${file("${path.module}/secrets/terraform-admin-service-account-credentials.json")}"
}

# K8s provider configured to use the admin user created by GKE.
provider "kubernetes" {
  config_path = "${local.kubeconfig_path}"
}

# Helm configured to use the same admin user as the k8s provider. Uses a
# directory within the repository for the helm "home" directory to avoid
# polluting the local user's ~/.helm directory.
provider "helm" {
  service_account = "${module.helm.service_account}"

  home = "${module.helm.home}"

  install_tiller = false

  kubernetes {
    config_path = "${local.kubeconfig_path}"
  }
}
