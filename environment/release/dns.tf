# dns.tf contains configuration for a wildcard DNS entry for Gitlab endpoints
# and a static IP for that entry to point to.

# Static IP
resource "google_compute_address" "static-ip" {
  name = "gitlab-${var.name}"
}

# DNS record for IP
resource "google_dns_record_set" "wildcard" {
  name         = "*.${var.dns_name}"
  ttl          = 300
  type         = "A"
  managed_zone = "${var.zone}"
  rrdatas      = ["${google_compute_address.static-ip.address}"]
}
