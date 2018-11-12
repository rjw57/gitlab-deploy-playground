# Configuration of the terraform state storage backend.

# The bucket used here was created with the following commands:
#
# $ gsutil mb -p uis-automation-dm -l europe-west2 gs://terraform-state-gitlab-uuk1useh
# $ gsutil versioning set on gs://terraform-state-gitlab-uuk1useh
#
# The service account for terraform should have the Storage Admin role according
# to https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
#
# The following must be kept in sync with infrastructure/remote_backend.tf.
terraform {
  backend "gcs" {
    bucket      = "terraform-state-gitlab-uuk1useh"
    prefix      = "terraform/gitlab/project/state"
    project     = "uis-automation-dm"
    credentials = "../secrets/terraform-admin-service-account-credentials.json"
    region      = "europe-west2"
  }
}
