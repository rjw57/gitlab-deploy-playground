# Configure helm without polluting local user's home directory
module "helm" {
  source = "./helm"

  # Do not pollute the user's ~/.helm with our configuration
  home = "${path.module}/helm-home"

  kubeconfig_path = "${local.kubeconfig_path}"
}

locals {
  helm_home = "${module.helm.home}"
}

# Update dependencies in the gitlab chart which we have vendored in
resource "null_resource" "gitlab_chart_deps" {
  provisioner "local-exec" {
    command     = "helm --home '${local.helm_home}' --kubeconfig '${local.kubeconfig_path}' dependencies update charts/gitlab"
    working_dir = "${path.module}"
  }
}
