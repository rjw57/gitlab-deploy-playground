# GCP project id
variable "project" {}

# Region to create resources in
variable "region" {}

# Name of cluster
variable "name" {
  default = "cluster"
}

# Default machine type
variable "machine_type" {}
