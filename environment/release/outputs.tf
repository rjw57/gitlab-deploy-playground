# outputs.tf contain the defined outputs for the module

# A URL pointing to the gitlab deployment.
output "gitlab_url" {
  value = "https://${local.gitlab_external_host}"

  depends_on = [
    "helm_release.gitlab",
  ]
}
