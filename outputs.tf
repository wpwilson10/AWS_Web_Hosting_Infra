output "client_files_s3_bucket_name" {
  value       = module.client_files_s3_bucket.s3_bucket_id
  description = "Name of the S3 bucket hosting the website's client files"
}
