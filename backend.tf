# backend.tf configures the teraform remote state backend.
#
# The bucket used in this file should have versioning enabled and the service
# account for terraform should have the Storage Admin role as per
# https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform.
#
# See the README.md file for instructions on how the terraform admin user and
# bucket was created in the first place.
terraform {
  backend "gcs" {
    bucket      = "uis-devops-terraform-state-you6phet"
    prefix      = "experimental/gitlab/state"
    project     = "uis-automation-dm"
    credentials = "./secrets/terraform-admin-service-account-credentials.json"
    region      = "europe-west2"
  }
}

# We define an additional local here which is the full path to the matching
# service account credentials. This is placed here as opposed to a separate
# locals.tf to try to keep it in sync with the configuration above. Ideally,
# we'd have some way of interpolating backend configuration but it's not obvious
# in the terraform docs if this s possible.
locals {
  admin_service_account_credentials = "${file("${path.module}/secrets/terraform-admin-service-account-credentials.json")}"
}
