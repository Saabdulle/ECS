output "bucket_name" {
  value = aws_s3_bucket.plane_storage.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.plane_storage.arn
}

output "bucket_region" {
  value = var.aws_region
}