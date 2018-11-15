output "name" {
  value = "${google_service_account.account.name}"
}

output "email" {
  value = "${google_service_account.account.email}"
}

output "private_key" {
  value = "${base64decode(google_service_account_key.account.private_key)}"
}
