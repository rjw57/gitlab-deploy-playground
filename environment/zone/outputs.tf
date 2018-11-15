# outputs.tf contain the defined outputs for the module

# The DNS name (with trailing ".") for the created zone.
output "dns_name" {
  value = "${google_dns_managed_zone.zone.dns_name}"
}

# The name of the zone resource
output "name" {
  value = "${google_dns_managed_zone.zone.name}"
}
