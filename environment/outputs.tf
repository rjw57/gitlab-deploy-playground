# outputs.tf contain the defined outputs for the module

# A URL pointing to the gitlab deployment.
output "gitlab_url" {
  value = "${module.release.gitlab_url}"
}

# The contents of a kubeconfig file which can be used to talk to the cluster.
output "kubeconfig_content" {
  sensitive = true
  value     = "${local.kubeconfig_content}"
}
