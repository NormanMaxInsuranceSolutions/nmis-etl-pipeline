output "snowflake_storage_role_arn" {
  description = "IAM role ARN to use in Snowflake storage integration (snowpipe.sql step 1)"
  value       = aws_iam_role.snowflake_storage.arn
}

output "data_lake_bucket" {
  description = "S3 data lake bucket name to use in Snowflake storage integration allowed locations"
  value       = aws_s3_bucket.data_lake.bucket
}