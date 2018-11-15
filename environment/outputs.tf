# outputs.tf contain the defined outputs for the module

# A URL pointing to the gitlab deployment.
output "gitlab_url" {
  value = "${module.release.gitlab_url}"
}

# The initial password for the "root" user. Note that if the root user *changes*
# their password, this output does not update.
output "initial_root_password" {
  sensitive = true
  value     = "${module.release.initial_root_password}"
}

# The contents of a kubeconfig file which can be used to talk to the cluster.
output "kubeconfig_content" {
  sensitive = true
  value     = "${local.kubeconfig_content}"
}
