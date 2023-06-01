provider "google" {
  credentials = file(var.google-creds)

  project = var.project
  region  = var.region
  zone    = var.zone
}
