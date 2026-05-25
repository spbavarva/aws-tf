variable "region" {
    type = string
    default = "us-east-1"
}

variable instance_count {
    type = number
    description = "Number of instances to create"
}

variable monitoring_enabled {
    type = bool
    default = true
    description = "Enable monitoring"
}

variable associate_public_ip {
    type = bool
    default = true
    description = "Associate public IP address"
}

variable "cidr_block" {
    type = list(string)
    default = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
    description = "List of CIDR blocks"
}

variable allowed_vm_types {
    type = list(string)
    default = ["t2.micro", "t2.small", "t2.medium"]
    description = "List of allowed VM types"
}

variable "tags_ec2" {
    type = map(string)
    default = {
        created_by = "sneh"
    }
}

variable "ingress_rules" {
    type = tuple([number, string, number])
    default = [ 443, "tcp", 443 ]
}

variable "bucket_name" {
    type = string
    default = "dev"
}