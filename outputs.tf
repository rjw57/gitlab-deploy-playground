output "gitlab_url" {
  value = "${module.gitlab_release.gitlab_url}"
}

output "initial_root_password" {
  sensitive = true
  value     = "${module.gitlab_release.initial_root_password}"
}
