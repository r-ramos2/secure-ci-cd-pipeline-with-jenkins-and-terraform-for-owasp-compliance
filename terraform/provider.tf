// provider.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws    = { source = "hashicorp/aws",    version = ">= 4.0" }
    tls    = { source = "hashicorp/tls" }
    random = { source = "hashicorp/random" }
    local  = { source = "hashicorp/local" }
  }
}
provider "aws" {
  # AWS region for resources
  region = var.region
}
