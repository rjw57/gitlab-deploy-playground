# outputs.tf contain root-level outputs for the configuration. They can be
# queried via the "terraform output" command.

# A URL pointing to the gitlab deployment.
output "gitlab_url" {
  value = "${module.gitlab_release.gitlab_url}"
}

# The initial password for the "root" user. Note that if the root user *changes*
# their password, this output does not update.
output "initial_root_password" {
  sensitive = true
  value     = "${module.gitlab_release.initial_root_password}"
}
