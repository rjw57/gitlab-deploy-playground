# Provider configuration for Google Cloud Platform. Adapted from Google
# documentation at
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#
# Both the google and google-beta provider are configured identically with a
# super-powered admin account which can create projects. For this reason, we
# silo the project creation configuration from the rest of the resource
# configuration so that subsequent work cna proceed using a less-privileged
# account.

provider "google" {
  credentials = "${file("${path.module}/../secrets/terraform-admin-service-account-credentials.json")}"
}

provider "google-beta" {
  credentials = "${file("${path.module}/../secrets/terraform-admin-service-account-credentials.json")}"
}
