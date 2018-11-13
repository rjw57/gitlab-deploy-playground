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

resource "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"

  depends_on = ["module.helm"]
}

# Update dependencies in the gitlab chart which we have vendored in
resource "null_resource" "gitlab_chart_deps" {
  triggers {
    home            = "${local.helm_home}"
    kubeconfig_path = "${local.kubeconfig_path}"
  }

  provisioner "local-exec" {
    command     = "helm --home '${local.helm_home}' --kubeconfig '${local.kubeconfig_path}' dependencies update charts/gitlab"
    working_dir = "${path.module}"
  }

  depends_on = ["helm_repository.gitlab"]
}
