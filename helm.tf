# helm.tf ensures that helm is present in the GKE cluster and correctly
# configured. It also initialises the local helm install into a state where it
# can deploy our vendored gitlab chart.

# Configure helm without polluting local ~/.helm directory
module "helm" {
  source = "./helm"

  home = "${path.module}/helm-home"

  kubeconfig_path = "${local.kubeconfig_path}"
}

# Add the upstream gitlab repository to the helm configuration.
resource "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"

  depends_on = ["module.helm"]
}

# Update dependencies in the gitlab chart which we have vendored in
resource "null_resource" "gitlab_chart_deps" {
  # Only run the command if any of the following values change.
  triggers {
    home            = "${local.helm_home}"
    kubeconfig_path = "${local.kubeconfig_path}"
  }

  provisioner "local-exec" {
    command = <<EOF
helm \
  --home '${local.helm_home}' --kubeconfig '${local.kubeconfig_path}' \
  dependencies update charts/gitlab"
EOF

    working_dir = "${path.module}"
  }

  depends_on = ["helm_repository.gitlab"]
}
