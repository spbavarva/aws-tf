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

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

// Variable declaration
variable "environment" {
  type        = string
  description = "Environment name"
  default     = "staged"
}

variable "purpose" {
    type = string
    description = "Purpose of the bucket"
    default = "automation"
}

locals {
    bucket_name = "automation-${random_id.bucket_suffix.hex}-${var.environment}-bucket"
    created_name = "sneh"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test_vpc"
  }
}

# Create a S3 bucket
resource "aws_s3_bucket" "automation" {
  bucket = local.bucket_name
#   bucket = var.environment

  tags = {
    Name        = "sneh-tf-bucket LOL"
    environment = var.environment
    created_by  = local.created_name
    purpose     = "automation"
  }
}

# Creating s3 bucket with depends on vpc_id using dynamic argument
resource "aws_s3_bucket" "automation2" {
  bucket = "automation-${aws_vpc.test_vpc.id}-bucket"

  tags = {
    Name        = "sneh-tf-bucket LOL2"
    environment = var.environment
    created_by  = "sneh"
    purpose     = "automation"
  }
}


output "bucket_name" {
  value = local.bucket_name
}

output "env" {
    value = var.environment
}

output "purpose" {
    value = var.purpose
}
