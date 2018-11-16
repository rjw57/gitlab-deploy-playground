# outputs.tf contain the defined outputs for the module

# A URL pointing to the gitlab deployment.
output "gitlab_url" {
  value = "https://${local.gitlab_external_host}"

  depends_on = [
    "helm_release.gitlab",
  ]
}

# The initial password for the "root" user. Note that if the root user *changes*
# their password, this output does not update.
output "initial_root_password" {
  sensitive = true
  value     = "${local.initial_root_password}"
}
