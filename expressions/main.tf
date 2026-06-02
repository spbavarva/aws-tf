resource "aws_instance" "web_1" {
  ami = "ami-0c55b159cbfafe1f0"
  # instance_type = var.allowed_vm_types[0]
  instance_type = var.environment == "dev" ? var.allowed_vm_types[0] : var.allowed_vm_types[1]
  count         = var.instance_count
  region        = var.region
  tags          = var.tags_ec2

}

resource "aws_security_group" "ingress" {
  name        = "web_sg"
  description = "Security group for web instances"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
}

locals {
  all_instance_ids = aws_instance.web_1[*].id
}

output "all_instance_ids" {
  value = local.all_instance_ids
}
