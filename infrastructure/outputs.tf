output "cluster_endpoint" {
  value = "${module.cluster.endpoint}"
}

output "cluster_ca_certificate" {
  value = "${base64decode(module.cluster.master_auth_cluster_ca_certificate)}"
}
