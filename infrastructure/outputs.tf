output "cluster_endpoint" {
  value = "${module.cluster.endpoint}"
}

output "cluster_name" {
  value = "${module.cluster.name}"
}

output "cluster_client_certificate" {
  value = "${base64decode(module.cluster.master_auth_client_certificate)}"
}

output "cluster_client_key" {
  value = "${base64decode(module.cluster.master_auth_client_key)}"
}

output "cluster_ca_certificate" {
  value = "${base64decode(module.cluster.master_auth_cluster_ca_certificate)}"
}

output "cluster_kubeconfig" {
  value = "${module.cluster.master_auth_kubeconfig}"
}

output "sql_instance_name" {
  value = "${module.cloud_sql_instance.name}"
}

output "sql_instance_connection_name" {
  value = "${module.cloud_sql_instance.connection_name}"
}

output "sql_instance_proxy_credentials" {
  value = "${module.cloud_sql_instance.service_account_credentials}"
}
