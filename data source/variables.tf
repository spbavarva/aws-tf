variable "project_name" {
  type    = string
  default = "Learning TF Functions"
}

variable "default_tags" {
  default = {
    created_by = "Sneh"
    goes_by    = "mystic_mido"
  }
}

variable "environment_tags" {
  default = {
    environment = "dev"
  }
}

variable "s3_bucket_name" {
  default = "Mido, We are going to do it!!"
}

variable "allowed_ports" {
  default = "80,443,22"
}

variable "environment" {
  default = "dev"
}

variable "instance_sizes" {
  default = {
    dev   = "t2.micro"
    prod  = "t2.medium"
    stage = "t2.small"
  }
}

variable "instance_type" {
  default = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 15
    error_message = "Instance type must be between 2 and 15 characters long"
  }
  validation {
    condition     = can(regex("^t[2-3]\\.", var.instance_type))
    error_message = "Instance type must start with t2 or t3."
  }
}

variable "credentials" {
  default = "/home/ubuntu/keys/midokey.pem"
}

variable "user_locations" {
  default = ["us-east-1", "us-east-2", "us-west-1", "us-west-1"]
}

variable "default_locations" {
  default = ["us-east-1"]
}
