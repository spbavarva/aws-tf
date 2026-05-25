output "_01_bucket_names" {
   value = concat(
    [for bucket in aws_s3_bucket.task_bucket_1 : bucket.bucket],
    [for bucket in aws_s3_bucket.task_bucket_2 : bucket.bucket]
   )
}

output "_02_bucket_ids" {
    value = concat(
        [for bucket in aws_s3_bucket.task_bucket_1 : bucket.id],
        [for bucket in aws_s3_bucket.task_bucket_2 : bucket.id]
    )
}