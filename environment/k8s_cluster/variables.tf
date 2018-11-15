# variables.tf contains definitions of variables used by the module.

# Project for cluster. Cannot be inferred from Google provider since there is no
# way to interpolate provider-level configuration.
variable "project" {}

# Region for cluster. Cannot be inferred from Google provider since there is no
# way to interpolate provider-level configuration.
variable "region" {}

# Name of cluster.
variable "name" {
  default = "cluster"
}

# Default machine type.
variable "machine_type" {}
