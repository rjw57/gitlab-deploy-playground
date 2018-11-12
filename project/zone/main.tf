# A dedicated DNS zone for the project wired up to the DNS by means of the zone
# in our infrastructure repo.

# Get information about our parent zone.
data "google_dns_managed_zone" "parent_zone" {
  project = "${var.parent_project}"
  name    = "${var.parent_zone}"
}

# A random (but short!) zone name
resource "random_id" "zone_name" {
  byte_length = 4
  prefix      = "${var.generated_dns_name_prefix}"
}

# The DNS name we use is made up of a random name and the parent managed zone's
# DNS name.
locals {
  zone_name = "${random_id.zone_name.hex}"
  dns_name  = "${local.zone_name}.${data.google_dns_managed_zone.parent_zone.dns_name}"
}

# Create a managed zone for DNS records
resource "google_dns_managed_zone" "zone" {
  project  = "${var.project}"
  name     = "${local.zone_name}"
  dns_name = "${local.dns_name}"
}

# Add the zone NS records to the infrastructure project
resource "google_dns_record_set" "zone" {
  project = "${var.parent_project}"

  managed_zone = "${var.parent_zone}"

  name    = "${google_dns_managed_zone.zone.dns_name}"
  type    = "NS"
  rrdatas = ["${google_dns_managed_zone.zone.name_servers}"]
  ttl     = 300
}
