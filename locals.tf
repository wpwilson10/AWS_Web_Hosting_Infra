locals {
  lambda_runtime      = "python3.13"
  lambda_architecture = ["arm64"]
  lambda_handler      = "lambda_function.lambda_handler" # https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html

  api_domain_name = "${var.api_domain_prefix}.${var.domain_name}"
  site_www_URL    = "https://www.${var.domain_name}"
  site_URL        = "https://${var.domain_name}"
  www_domain_name = "www.${var.domain_name}"
}
