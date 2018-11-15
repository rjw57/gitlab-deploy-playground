# main.tf contains the top-level resources created by this module.

# The GCP project. Since this creates resources outside of the project proper,
# most obviously the project itself, we need to use a provider with elevated
# access.
#
# This module will create the GCP project, create a new delegated DNS zone for
# it and create a managed DNS zone resource within the project.
module "project" {
  source = "./project"

  project_name = "${var.project_name}"
  folder_id    = "${var.project_folder_id}"

  generated_project_id_prefix = "${var.generated_project_id_prefix}"

  # Additional services to enable in the project. This list is
  # non-authoritative; any services enabled manually in the console or via
  # Google's infrastructure will not be disabled.
  additional_services = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
  ]

  # This list is non-authoritative; if someone has the role/editor role on the
  # project but does not appear on this list, they won't lose that role binding.
  editors = []

  providers = {
    google      = "google.admin"
    google-beta = "google-beta.admin"
  }
}

# A new DNS managed zone for this project. This module will use the google.admin
# and google-beta.admin providers when creating the NS records in our main zone
# for the project-specific zone.
module "zone" "zone" {
  source = "./zone"

  generated_dns_name_prefix = "${var.generated_dns_name_prefix}"
}

# A Cloud SQL instance.
module "sqlinstance" {
  source = "./sqlinstance"

  region = "${local.region}"
  tier   = "${var.db_tier}"
}

# A Kubernetes cluster.
module "cluster" {
  source = "./k8s_cluster"

  project = "${local.project}"
  region  = "${local.region}"

  machine_type = "${var.k8s_node_machine_type}"
}

# An appropriate storage class to be used for the persistent volume claims in
# the release.
module "retained_storage_class" {
  source = "./retained_storage_class"

  kubeconfig_content = "${local.kubeconfig_content}"
  secrets_dir        = "${var.secrets_dir}"
}

# Create service account and role binding as specified at
# https://docs.helm.sh/using_helm/#role-based-access-control
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "kube-system"
    api_group = ""
  }
}

# The helm gitlab release itself
module "release" {
  source = "./release"

  zone     = "${local.zone_name}"
  dns_name = "${local.dns_name}"

  gitlab_domain = "${var.gitlab_domain}"

  storage_class = "${module.retained_storage_class.name}"

  gitaly_persistence_size = "${var.gitaly_persistence_size}"

  sql_instance                 = "${module.sqlinstance.name}"
  sql_instance_connection_name = "${module.sqlinstance.connection_name}"
  sql_instance_credentials     = "${module.sqlinstance.service_account_credentials}"

  kubeconfig_content     = "${local.kubeconfig_content}"
  tiller_service_account = "${local.tiller_service_account}"
  secrets_dir            = "${var.secrets_dir}"
}
