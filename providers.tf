# providers.tf contains configuration for all the terraform providers used by
# the deployment.

# A GCP provider which is configured to use the shared terraform admin account.
# This admin account has elevated permissions. For example, it is allowed to
# create projects. We use this provider only when creating resources outside of
# the main GCP project.
#
# The service account credentials are configured in backend.tf.
#
# Both the google and google-beta provider are configured identically.
provider "google" {
  version = "~> 1.19"

  alias       = "admin"
  credentials = "${local.admin_service_account_credentials}"
}

provider "google-beta" {
  version = "~> 1.19"

  alias       = "admin"
  credentials = "${local.admin_service_account_credentials}"
}

# A GCP provider which is configured to use a project-specific service account
# within the GCP project. The service account has project owner permissions but
# no privileges outside of the project. For most resources, thi is the provider
# which is used which helms ensure that we don't accidentally configure anything
# outside of our deployment project.
#
# Both the google and google-beta provider are configured identically.
provider "google" {
  version = "~> 1.19"

  credentials = "${module.project.owner_service_account_credentials}"

  project = "${module.project.project_id}"
  region  = "${module.project.region}"
}

provider "google-beta" {
  version = "~> 1.19"

  credentials = "${module.project.owner_service_account_credentials}"

  project = "${module.project.project_id}"
  region  = "${module.project.region}"
}

# K8s provider configured to use the admin user created by GKE.
provider "kubernetes" {
  version = "~> 1.3"

  config_path = "${local.kubeconfig_path}"
}

# Helm configured to use the same admin user as the k8s provider. Uses a
# directory within the repository for the helm "home" directory to avoid
# polluting the local user's ~/.helm directory.
provider "helm" {
  version = "~> 0.6"

  service_account = "${module.helm.service_account}"

  home = "${local.helm_home}"

  install_tiller = false

  kubernetes {
    config_path = "${local.kubeconfig_path}"
  }
}
