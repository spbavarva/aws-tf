resource "aws_instance" "web_1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.allowed_vm_types[0]
  region        = var.region
  tags          = var.tags_ec2

  lifecycle {
    create_before_destroy = true
  }

}
