variable "project" {
  description = "Project ID"
  type        = string
}
variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
}
variable "aws_secret_key" {
  description = "AWS secret compatible with aws_access_key "
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region which the resources will be set"
  default     = "ap-southeast-1"
  type        = string
  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2", "ap-east-1", "ap-south-1", "ap-northeast-3", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-south-1", "eu-west-3", "me-south-1", "sa-east-1"], var.region)
    error_message = "Unknown region"
  }
}
variable "vpc_cidr" {
  description = "VPC CIDR ip range without 10.128.0.0/9"
  default     = "172.52.0.0/16"
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}$", var.vpc_cidr))
    error_message = "Invalid IP address. Please enter a valid CIDR notation IP address."
  }
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR ip range without 10.128.0.0/9"
  default     = "172.52.0.0/16"
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}$", var.public_subnet_cidr))
    error_message = "Invalid IP address. Please enter a valid CIDR notation IP address."
  }
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR ip range without 10.128.0.0/9"
  default     = "172.52.0.0/16"
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}$", var.private_subnet_cidr))
    error_message = "Invalid IP address. Please enter a valid CIDR notation IP address."
  }
}
variable "private_subnet_availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "ap-southeast-1b"
}
