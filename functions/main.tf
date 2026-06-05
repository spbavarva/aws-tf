locals {
  formatted_project_name = lower(replace(var.project_name, " ", "-"))
  custom_tag             = merge(var.default_tags, var.environment_tags)
  clean_bucket_name      = substr(replace(replace(replace(lower(var.s3_bucket_name), " ", ""), "!", ""), ",", ""), 0, 63)
  split_ports_list       = split(",", var.allowed_ports)
  sg_rules = [for port in local.split_ports_list : {
    name = "port-${port}"
    port = port
  }]
  instance_size    = lookup(var.instance_sizes, var.environment)
  all_locations    = concat(var.user_locations, var.default_locations)
  unique_locations = toset(local.all_locations)
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${local.formatted_project_name}-${timestamp()}"
  # bucket = "${local.formatted_project_name}-468789745"

  tags = local.custom_tag

}

resource "aws_s3_bucket" "complex_bucket_name" {
  bucket = local.clean_bucket_name
}

