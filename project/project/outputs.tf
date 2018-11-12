# Project id for managed project.
output "project_id" {
  value = "${google_project.project.project_id}"

  depends_on = [
    # The services for the project must be enabled before we try to make use of
    # them. Make the project id depend on the services to allow for this.
    "google_project_service.project",

    # The owner service account must have the owner role before we can create
    # any resources. Make the project id depend on the IAM binding to allow for
    # this.
    "google_project_iam_member.owner",
  ]
}

# JSON credentials for owner service account.
output "owner_service_account_credentials" {
  sensitive = true
  value     = "${base64decode(google_service_account_key.owner.private_key)}"
}
