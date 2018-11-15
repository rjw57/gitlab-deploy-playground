# outputs.tf contains top-level outputs from the deployment
#
# Use of these outputs are documented in README.md.

# URL for production gitlab instance.
output "production_gitlab_url" {
  value = "${module.production.gitlab_url}"
}

# Initial root password for production gitlab instance.
output "production_initial_root_password" {
  value     = "${module.production.initial_root_password}"
  sensitive = true
}

# Kubeconfig file contents which allow connection to the production k8s cluster.
output "production_kubeconfig_content" {
  value     = "${module.production.kubeconfig_content}"
  sensitive = true
}

# URL for test gitlab instance.
output "test_gitlab_url" {
  value = "${module.test.gitlab_url}"
}

# Initial root password for test gitlab instance.
output "test_initial_root_password" {
  value     = "${module.test.initial_root_password}"
  sensitive = true
}

# Kubeconfig file contents which allow connection to the test k8s cluster.
output "test_kubeconfig_content" {
  value     = "${module.test.kubeconfig_content}"
  sensitive = true
}
