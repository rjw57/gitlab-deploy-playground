# Project id for managed project.
output "project_id" {
  value = "${module.project.project_id}"
}

# Region the project resources are created in
output "region" {
  value = "${local.region}"
}

# Owner service account credentials
output "owner_service_account_credentials" {
  sensitive = true
  value     = "${module.project.owner_service_account_credentials}"
}

# DNS name for managed zone (*without* trailing ".")
output "dns_name" {
  value = "${replace(module.zone.dns_name, "/\\.$/", "")}"
}

# Name of Cloud DNS resource in created project
output "zone_name" {
  value = "${module.zone.name}"
}
