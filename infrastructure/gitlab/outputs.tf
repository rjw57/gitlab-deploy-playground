output "gitlab_url" {
  value = "https://gitlab.${var.domain}"

  depends_on = [
    "helm_release.gitlab",
  ]
}

output "initial_root_password" {
  sensitive = true
  value     = "${local.initial_root_password}"
}
