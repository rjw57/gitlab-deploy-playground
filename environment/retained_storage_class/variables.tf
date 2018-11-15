# variables.tf contains definitions of variables used by the module.

# The content of a kubeconfig file which is equivalent to the kubernetes
# provider config. This is required because the kubernetes provider for terrform
# does not yet support all the fields we wisth to set and so we need to hack the
# storage class on creation via kubectl.
variable "kubeconfig_content" {}

# A directory which it is safe to put secrets in.
variable "secrets_dir" {}
