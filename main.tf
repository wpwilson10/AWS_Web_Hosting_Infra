########################################################################################################################
# S3 Bucket - Contains website client files and setup as a static website
# See https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteAccessPermissionsReqd.html#bucket-policy-static-site
########################################################################################################################

module "client_files_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.10.0"

  bucket_prefix = lower("${var.project_name}-client-files-")
  force_destroy = true

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  # S3 bucket-level Public Access Block configuration
  # block_public_acls       = true
  # ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# Bucket policy allowing only reads of objects from public clients
# Created as a seperate resource to avoid reference cycle error
resource "aws_s3_bucket_policy" "public_read" {
  bucket = module.client_files_s3_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::${module.client_files_s3_bucket.s3_bucket_id}/*"
      }
    ]
  })
}

# Loads client files making them available as objects
# https://registry.terraform.io/modules/hashicorp/dir/template/latest
module "client_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = var.client_file_directory
}

# Upload the client files to the S3 bucket
resource "aws_s3_object" "client_files" {
  bucket   = module.client_files_s3_bucket.s3_bucket_id
  for_each = module.client_files.files

  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  source_hash  = each.value.digests.md5 # stores hash so object gets updated when file is updated
}

############################################
# Route53 DNS Zone - Enables DNS for domain
############################################

module "route53_zone" {
  source  = "terraform-aws-modules/route53/aws"
  version = "6.4.0"

  name = var.domain_name
}

####################################################################
# ACM SSL/TLS Certificate - Used by project's networking components
####################################################################

module "acm_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name = var.domain_name
  zone_id     = module.route53_zone.id

  subject_alternative_names = [
    "*.${var.domain_name}",
    local.www_domain_name,
    local.api_domain_name,
  ]

  validation_method   = "DNS"
  wait_for_validation = true
}

#############################################################################################################
# CloudFront Distribution - for more effective website hosting
# Based on https://docs.aws.amazon.com/AmazonS3/latest/userguide/website-hosting-cloudfront-walkthrough.html
#############################################################################################################

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.4.0"

  enabled             = true
  wait_for_deployment = false

  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_100" # Use only North America and Europe

  aliases             = [var.domain_name, "www.${var.domain_name}"]
  default_root_object = "index.html"

  origin = {
    s3_website_endpoint = {
      domain_name = module.client_files_s3_bucket.s3_bucket_website_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_website_endpoint"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_name          = "Managed-CachingOptimized"
    origin_request_policy_name = "Managed-CORS-CustomOrigin"
  }

  viewer_certificate = {
    acm_certificate_arn      = module.acm_certificate.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  custom_error_response = [{
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }]
}

# Point our domain to the cloudfront distribution in Route53
module "cloudfront_route53_record" {
  source  = "terraform-aws-modules/route53/aws"
  version = "6.4.0"

  create_zone = false
  name        = var.domain_name

  records = {
    root = {
      full_name = var.domain_name
      type      = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    }
    www = {
      name = "www"
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    }
  }
}

####################################################
# API Gateway - Connects Client to Lambda Functions
# Routes & Integrations added in other modules
####################################################

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "6.1.0"

  name          = "${var.project_name}-Gateway"
  description   = "HTTP API Gateway that handles lights schedule configuration requests"
  protocol_type = "HTTP"

  # Custom domain
  domain_name = local.api_domain_name
  # Route53 Zone
  hosted_zone_name = module.route53_zone.name
  # ACM certificate
  domain_name_certificate_arn = module.acm_certificate.acm_certificate_arn
  # Disable creation of the ACM certificate for the custom domain since we have one already
  create_certificate = false

  cors_configuration = {
    allow_headers = ["content-type", "x-custom-auth"]
    allow_methods = ["GET", "OPTIONS", "POST"]
    allow_origins = [local.site_URL, local.site_www_URL, "http://${module.client_files_s3_bucket.s3_bucket_website_endpoint}"]
  }

  # Fixes - Error: no matching Route 53 Hosted Zone found
  depends_on = [module.route53_zone]
}
