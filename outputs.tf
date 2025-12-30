output "client_files_s3_bucket_name" {
  value       = module.client_files_s3_bucket.s3_bucket_id
  description = "Name of the S3 bucket hosting the website's client files"
}

output "cloudfront_distribution_id" {
  value       = module.cloudfront.cloudfront_distribution_id
  description = "CloudFront distribution ID for cache invalidation"
}

output "cloudfront_distribution_domain_name" {
  value       = module.cloudfront.cloudfront_distribution_domain_name
  description = "CloudFront distribution domain name"
}

output "api_gateway_endpoint" {
  value       = module.api_gateway.api_endpoint
  description = "API Gateway endpoint URL"
}

output "route53_zone_nameservers" {
  value       = module.route53_zone.name_servers
  description = "Route53 zone nameservers for DNS delegation"
}
