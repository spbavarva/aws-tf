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
  region = "us-east-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test_vpc"
  }
}

# Create a S3 bucket
resource "aws_s3_bucket" "automation" {
  bucket = "automation-test-tf-bucket"

  tags = {
    Name        = "sneh-tf-bucket LOL"
    environment = "dev"
    created_by  = "sneh"
    purpose     = "automation"
  }
}

resource "aws_s3_bucket" "automation2" {
  bucket = "automation-${aws_vpc.test_vpc.id}-bucket"

  tags = {
    Name        = "sneh-tf-bucket LOL2"
    environment = "dev"
    created_by  = "sneh"
    purpose     = "automation"
  }
}