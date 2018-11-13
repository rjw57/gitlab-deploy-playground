# Create appropriate storage class. We have to use kubectl directly since the
# kubernetes_storage_class resource does not yet have the functionality we
# require.
resource "null_resource" "storage_class" {
  triggers {
    contents        = "${file("${path.module}/storage_class.yaml")}"
    kubeconfig_path = "${var.kubeconfig_path}"
  }

  provisioner "local-exec" {
    command     = "kubectl apply -f ./storage_class.yaml"
    working_dir = "${path.module}"

    environment {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
  }
}

locals {
  name = "retain-ssd"
}
