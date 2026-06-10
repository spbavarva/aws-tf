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



variable "regions" {
  type = map(string)
  default = {
    primary   = "us-east-1"
    secondary = "us-east-2"
  }
}

variable "vpc_cidr_blocks" {
  default = {
    primary   = "10.0.0.0/16"
    secondary = "10.1.0.0/16"
  }
}

variable "subnet_cidr_blocks" {
  default = {
    primary   = "10.0.1.0/24"
    secondary = "10.1.1.0/24"
  }
}

variable "primary_key_name" {
  type    = string
  default = "east-1-vpc-peering"
}

variable "secondary_key_name" {
  type    = string
  default = "east-2-vpc-peering"
}
