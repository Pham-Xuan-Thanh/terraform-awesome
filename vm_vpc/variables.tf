variable "google-creds" {}

variable "private_key_path" {}

variable "project" {}

variable "region" {
  default = "asia-southeast1"
  type    = string
}

variable "zone" {
  default = "asia-southeast1-b"
  type    = string
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
  type    = string
}

variable "subnet_cidr" {
  default = "172.16.0.0/24"
  type    = string
}
