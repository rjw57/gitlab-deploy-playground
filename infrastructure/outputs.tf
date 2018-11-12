output "cluster_endpoint" {
  value = "${module.cluster.endpoint}"
}

output "cluster_name" {
  value = "${module.cluster.name}"
}

output "cluster_ca_certificate" {
  value = "${base64decode(module.cluster.master_auth_cluster_ca_certificate)}"
}

output "gitlab_url" {
  value = "${module.gitlab.gitlab_url}"
}

output "initial_root_password" {
  sensitive = true
  value     = "${module.gitlab.initial_root_password}"
}
