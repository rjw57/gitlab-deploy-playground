output "service_account" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

output "cluster_role_binding" {
  value = "${kubernetes_cluster_role_binding.tiller.metadata.0.name}"
}
