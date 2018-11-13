# Create appropriate storage class. We have to use kubectl directly since the
# kubernetes_storage_class resource does not yet have the functionality we
# require.
resource "null_resource" "storage_class" {
  provisioner "local-exec" {
    command     = "kubectl apply -f storage_class.yaml"
    working_dir = "${path.module}"

    environment {
      KUBECONFIG = "${var.kubeconfig_path}"
    }
  }
}

# Provide storage class name as a data source so that it may be implicitly
# depended on by reference.
data "null_data_source" "storage_class" {
  inputs {
    name = "retain-ssd"
  }

  depends_on = ["null_resource.storage_class"]
}
