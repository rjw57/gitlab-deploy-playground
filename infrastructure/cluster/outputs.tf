# This list of outputs is based on the ones in
# https://github.com/hashicorp/terraform-guides/blob/master/infrastructure-as-code/k8s-cluster-gke/outputs.tf

# Some outputs depend not only on the cluster but also on the cluster node pool
# so that we don't try to deploy resources before there's a pool ready to accept
# them.

output "endpoint" {
  value = "${google_container_cluster.cluster.endpoint}"

  depends_on = [
    "google_container_cluster.cluster",
    "google_container_node_pool.cluster-pool-1",
  ]
}

output "master_auth_kubeconfig" {
  value     = "${data.template_file.kubeconfig.rendered}"
  sensitive = true

  depends_on = [
    "google_container_cluster.cluster",
    "google_container_node_pool.cluster-pool-1",
  ]
}

output "name" {
  value = "${google_container_cluster.cluster.name}"
}

output "master_version" {
  value = "${google_container_cluster.cluster.master_version}"
}

output "master_auth_client_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
}

output "master_auth_client_key" {
  value     = "${google_container_cluster.cluster.master_auth.0.client_key}"
  sensitive = true
}

output "master_auth_cluster_ca_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
}
