# Declare AWS provider
provider "aws" {
  version = "~> 2.34"
  region  = var.AWS_REGION
}

terraform {
  required_version = "~> 0.12.13"
}
