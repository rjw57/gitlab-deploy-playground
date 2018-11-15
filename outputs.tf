# outputs.tf contains top-level outputs from the deployment
#
# Use of these outputs are documented in README.md.

# URL for production gitlab instance.
output "production_gitlab_url" {
  value = "${module.production.gitlab_url}"
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

# Kubeconfig file contents which allow connection to the test k8s cluster.
output "test_kubeconfig_content" {
  value     = "${module.test.kubeconfig_content}"
  sensitive = true
}
