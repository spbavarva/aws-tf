resource "aws_instance" "test_instance" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = var.allowed_vm_types[0]
    region = var.region
    count = var.instance_count
    monitoring = var.monitoring_enabled
    associate_public_ip_address = var.associate_public_ip

    tags = merge(var.tags_ec2, {
        name = "test_instance-${count.index}"
    })
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
    created_by = "sneh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.cidr_block[1]
  from_port         = var.ingress_rules[0]
  ip_protocol       = var.ingress_rules[1]
  to_port           = var.ingress_rules[2]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
