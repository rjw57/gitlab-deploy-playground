# main.tf contains the top-level resources created by this module.

# Determine the versions of K8s available in the region.
data "google_container_engine_versions" "region_versions" {
  provider = "google-beta" # required for regional clusters

  project = "${var.project}"
  region  = "${var.region}"
}

# The cluster itself. We use the regional versions query above to request that
# the master be upgraded to the latest version available in the region.
resource "google_container_cluster" "cluster" {
  provider = "google-beta" # required for regional clusters

  project = "${var.project}"
  region  = "${var.region}"

  # This is required to allow the created admin user to perform administrative
  # tasks within the cluster.
  enable_legacy_abac = true

  # Supplying blank username and passwords disables basic authentication and
  # instead will mandate certificate-based authentication.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  name               = "${var.name}"
  min_master_version = "${data.google_container_engine_versions.region_versions.latest_master_version}"

  # Terraform sometimes gets confused about this setting. The default value is
  # "default" but when it refreshes state it gets back the full self link to the
  # network. Specify the self link to the default network.
  network = "projects/${var.project}/global/networks/default"

  addons_config {
    # We never use the k8s dashboard directly so disable it.
    kubernetes_dashboard {
      disabled = true
    }
  }

  # We use a pool configured elsewhere so remove the default one. The
  # initial_node_count is therefore irrelevant but must be set to a non-zero
  # value to stop the Google API complaining.
  remove_default_node_pool = true

  initial_node_count = 1
}

# The node pool associated with the cluster. We do not specify a node version
# here because we enable auto-upgrade of the nodes so they will always be at the
# latest version.
resource "google_container_node_pool" "cluster-pool-1" {
  provider = "google-beta" # required for regional clusters

  project = "${var.project}"
  region  = "${var.region}"

  name    = "pool-1"
  cluster = "${google_container_cluster.cluster.name}"

  # Note that this is multiplied by the number of zones in the region.
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    # Scaling a node pool machine type requires that a new node pool be created.
    # As it is not readily changed by a user of this module, it isn't really
    # "variable" so we instead call it a default.
    machine_type = "${var.machine_type}"

    oauth_scopes = [
      # These four scopes are required for the cluster to function correctly.
      "https://www.googleapis.com/auth/compute",

      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# kubeconfig-style configuration
data "template_file" "kubeconfig" {
  template = "${file("${path.module}/kubeconfig.template.yaml")}"

  vars {
    name = "${google_container_cluster.cluster.name}"

    client_certificate = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
    client_key         = "${google_container_cluster.cluster.master_auth.0.client_key}"

    ca_certificate = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
    endpoint       = "${google_container_cluster.cluster.endpoint}"
  }
}
