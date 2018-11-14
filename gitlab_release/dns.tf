# Configure a wildcard DNS entry for Gitlab endpoints

# Static IP
resource "google_compute_address" "static-ip" {
  name = "gitlab-${var.name}"
}

# DNS record for IP
resource "google_dns_record_set" "wildcard" {
  # Note: we need the trailing "."
  name         = "*.${var.domain}."
  ttl          = 300
  type         = "A"
  managed_zone = "${var.zone}"
  rrdatas      = ["${google_compute_address.static-ip.address}"]
}
