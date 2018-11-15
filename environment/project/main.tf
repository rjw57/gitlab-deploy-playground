# main.tf contains the top-level resources created by this module.

# Random id generator used to generate random project id.
resource "random_id" "default_project_id" {
  byte_length = 4
  prefix      = "${var.generated_project_id_prefix}-"
}

# The GitLab project which houses all of the resources.
resource "google_project" "project" {
  name            = "${var.project_name}"
  project_id      = "${var.project_id == "" ? random_id.default_project_id.hex : var.project_id}"
  billing_account = "${var.billing_account}"
  folder_id       = "${var.folder_id}"
}

# Additional services on the project.
resource "google_project_service" "project" {
  count              = "${length(var.additional_services)}"
  project            = "${google_project.project.project_id}"
  service            = "${var.additional_services[count.index]}"
  disable_on_destroy = false
}

# A service account owner for the project. This service account can be
# used subsequently to manage resources.
resource "google_service_account" "owner" {
  project      = "${google_project.project.project_id}"
  account_id   = "terraform-admin"
  display_name = "Project-specific terraform service account"
}

# The owner service account must have the "roles/owner" role.
resource "google_project_iam_member" "owner" {
  project = "${google_project.project.project_id}"
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.owner.email}"
}

# A key which can be used to authenticate as the owner service account.
resource "google_service_account_key" "owner" {
  service_account_id = "${google_service_account.owner.name}"
}

# Project editors
resource "google_project_iam_member" "editors" {
  count   = "${length(var.editors)}"
  project = "${google_project.project.project_id}"
  role    = "roles/editor"
  member  = "${var.editors[count.index]}"
}
