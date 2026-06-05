output "formatted_project_name" {
  value = local.formatted_project_name
}

output "s3_bucket_name" {
  value = [
    aws_s3_bucket.web_bucket.bucket,
    aws_s3_bucket.complex_bucket_name.bucket
  ]
}

output "sg_rules" {
  value = local.sg_rules
}

output "split_ports" {
  value = local.split_ports_list
}

output "instance_size" {
  value = local.instance_size
}

output "creds" {
  value     = var.credentials
  sensitive = true
}

output "unique_locations" {
  value = local.unique_locations
}
