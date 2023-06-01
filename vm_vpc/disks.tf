resource "google_compute_disk" "default" {
  name  = "test-disk"
  type  = "pd-balanced"
  zone  = "asia-southeast1-b"
  image = "ubuntu-os-cloud/ubuntu-2004-lts"
  size  = 30
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}