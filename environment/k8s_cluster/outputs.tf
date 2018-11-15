# outputs.tf contain the defined outputs for the module

# This list of outputs is based on the ones in
# https://github.com/hashicorp/terraform-guides/blob/master/infrastructure-as-code/k8s-cluster-gke/outputs.tf

# Some outputs depend not only on the cluster but also on the cluster node pool
# so that we don't try to deploy resources before there's a pool ready to accept
# them.

# Endpoint for talking to the cluster.
output "endpoint" {
  value = "${google_container_cluster.cluster.endpoint}"

  depends_on = [
    "google_container_cluster.cluster",
    "google_container_node_pool.cluster-pool-1",
  ]
}

# The GCP name for the cluster.
output "name" {
  value = "${google_container_cluster.cluster.name}"
}

# The k8s version deployed on the master.
output "master_version" {
  value = "${google_container_cluster.cluster.master_version}"
}

# A PEM-encoded certificate for the admin user.
output "master_auth_client_certificate" {
  value = "${base64decode(google_container_cluster.cluster.master_auth.0.client_certificate)}"
}

# The corresponding key for master_auth_client_certificate.
output "master_auth_client_key" {
  value     = "${base64decode(google_container_cluster.cluster.master_auth.0.client_key)}"
  sensitive = true
}

# A root CA certificate for the cluster.
output "master_auth_cluster_ca_certificate" {
  value = "${base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)}"
}

# The contents of a kubeconfig file which can be used to connect to the cluster.
output "master_auth_kubeconfig" {
  value = "${data.template_file.kubeconfig.rendered}"
}
