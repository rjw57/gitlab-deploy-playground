# main.tf contains the top-level resources created by this module.

# Annoyingly, the kubernetes provider does not directly support reclaimPolicy so
# we have to perform some trickery.
#
# See https://github.com/terraform-providers/terraform-provider-kubernetes/issues/131

# Create appropriate storage class. We have to use kubectl directly since the
# kubernetes_storage_class resource does not yet have the functionality we
# require.
resource "null_resource" "retained" {
  # HACK: the kubernetes_storage_class resource doesn't allow configuring
  # retention policy or volume expansion. We do this manually instead. Since
  # local file resources do not play well with terraform remote state, we have
  # to write the kubeconfig file out here in the same command. Ugly but we can
  # remove this when the kubernetes provider is updated.
  provisioner "local-exec" {
    command = <<EOF
TMPFILE="$(mktemp -p "${var.secrets_dir}" kubeconfig.XXXXX)" && (
  echo "$KUBECONFIG_CONTENT" >"$TMPFILE" &&
  KUBECONFIG=$TMPFILE kubectl apply -f ./storage_class.yaml &&
  rm "$TMPFILE"
)
EOF

    working_dir = "${path.module}"

    environment {
      KUBECONFIG_CONTENT = "${var.kubeconfig_content}"
    }
  }
}
