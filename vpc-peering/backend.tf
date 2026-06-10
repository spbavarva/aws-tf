terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.regions.primary
  alias  = "primary"
}

provider "aws" {
  region = var.regions.secondary
  alias  = "secondary"
}
