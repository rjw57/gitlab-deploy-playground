# Create service account and role binding as specified at
# https://docs.helm.sh/using_helm/#role-based-access-control
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

locals {
  tiller_service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "kube-system"
    api_group = ""
  }
}

# Run helm init command
resource "null_resource" "init" {
  triggers {
    kubeconfig_path = "${var.kubeconfig_path}"
    service_account = "${local.tiller_service_account}"
    home            = "${var.home}"
  }

  provisioner "local-exec" {
    command = "helm init --kubeconfig '${var.kubeconfig_path}' --wait --service-account '${local.tiller_service_account}' --home '${var.home}'"
  }
}
