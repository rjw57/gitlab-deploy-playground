# Kubernetes namespace for deployment
resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab-${var.name}"
  }
}

# Keep the namespace in a local variable for convenience
locals {
  k8s_namespace = "${kubernetes_namespace.gitlab.metadata.0.name}"
}
