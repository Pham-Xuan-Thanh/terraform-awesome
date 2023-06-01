resource "google_compute_address" "static" {
  name         = "ipv4-address"
  address_type = "EXTERNAL"

}
resource "google_compute_network" "default" {
  name                    = "test-tf"
  description             = "A network for testing create from terraform"
  auto_create_subnetworks = true
  mtu                     = 1460
  routing_mode            = "REGIONAL"

}

resource "google_compute_subnetwork" "default" {
  name          = "test-tf-sea1"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.default.id

}

resource "google_compute_firewall" "default" {
  name        = "allow-http"
  network     = google_compute_network.default.self_link
  description = "Allow http requests"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]

}
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-on-public"
  network = google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
