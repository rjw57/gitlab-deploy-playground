# Configure a remote backend for terraform which allows outputs from the project
# creation to be used.

data "terraform_remote_state" "project" {
  backend = "gcs"

  # The following must be kept in sync with project/backend.tf.
  config = {
    bucket      = "terraform-state-gitlab-uuk1useh"
    prefix      = "terraform/gitlab/project/state"
    project     = "uis-automation-dm"
    credentials = "../secrets/terraform-admin-service-account-credentials.json"
    region      = "europe-west2"
  }
}
