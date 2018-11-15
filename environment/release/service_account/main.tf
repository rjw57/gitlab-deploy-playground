# Convenience module to create a Google service account and generate a key for
# it in one go.
resource "google_service_account" "account" {
  account_id   = "${var.account_id}"
  display_name = "${var.display_name}"
}

resource "google_service_account_key" "account" {
  service_account_id = "${google_service_account.account.name}"
}
