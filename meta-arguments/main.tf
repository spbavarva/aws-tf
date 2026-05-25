resource "aws_s3_bucket" "task_bucket_1" {
  count = 2
  bucket = var.bucket_name[count.index]

  tags = var.common_tags
}

resource "aws_s3_bucket" "task_bucket_2" {
  for_each = var.new_bucket_name
  bucket = each.value

  tags = var.common_tags

  depends_on = [
    aws_s3_bucket.task_bucket_1
  ]
}