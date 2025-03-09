variable "api_domain_prefix" {
  description = "Prefix used for the api services domain for the website (e.g. api_domain_prefix.domain_name.com)"
  type        = string
  default     = "api"
}

variable "client_file_directory" {
  description = "Relative location of the directory containing website client files"
  type        = string
  default     = "../client/dist/"
}

# Uses the access credential values in the profile located at
#  "~/.aws/credentials" (Linux) or "%USERPROFILE%\.aws\credentials" (Windows).
# See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
variable "credentials_profile" {
  description = "Profile to use from the AWS credentials file"
  type        = string
  default     = "default"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository managing this project"
  type        = string
}

variable "project_name" {
  description = "Name for this project which will be prepended to new resources"
  type        = string
  default     = "SPA-Demo"
}

variable "region" {
  description = "AWS Region to use for this account"
  type        = string
  default     = "us-east-1"
}
