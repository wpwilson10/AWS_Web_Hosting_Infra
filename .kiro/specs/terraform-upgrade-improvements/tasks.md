# Implementation Plan: Terraform Upgrade and Improvements

## Overview

Staged upgrade of Terraform infrastructure: provider first, then modules, then improvements. Each stage includes validation checkpoints.

## Tasks

- [x] 1. Update Terraform and AWS Provider versions

  - [x] 1.1 Update terraform.tf with new version constraints

    - Change required_version to ">= 1.10.0"
    - Change AWS provider version to "~> 6.27"
    - _Requirements: 1.1, 1.3, 2.1, 2.2_

  - [x] 1.2 Run terraform init to download new provider
    - Execute `terraform init -upgrade`
    - Verify no version constraint errors
    - _Requirements: 1.1, 1.2_

- [x] 2. Update S3 Bucket Module

  - [x] 2.1 Update S3 module version in main.tf

    - Change version from "4.2.2" to "5.9.1"
    - Preserve existing section header comment
    - _Requirements: 3.1, 3.3, 13.1_

  - [x] 2.2 Validate S3 module configuration
    - Run `terraform validate`
    - Verify website configuration preserved
    - _Requirements: 3.2_

- [x] 3. Update Route53 Module

  - [x] 3.1 Update Route53 zones module version

    - Change version from "4.1.0" to "6.1.1"
    - Preserve existing section header comment
    - _Requirements: 4.1, 13.1_

  - [x] 3.2 Update Route53 records module version

    - Change version from "4.1.0" to "6.1.1"
    - _Requirements: 4.1_

  - [x] 3.3 Validate Route53 configuration
    - Run `terraform validate`
    - _Requirements: 4.2, 4.3_

- [x] 4. Update ACM Module

  - [x] 4.1 Update ACM module version in main.tf

    - Change version from "5.1.1" to "6.2.0"
    - Preserve existing section header comment
    - _Requirements: 5.1, 13.1_

  - [x] 4.2 Validate ACM configuration
    - Run `terraform validate`
    - _Requirements: 5.2_

- [x] 5. Update CloudFront Module (Breaking Changes)

  - [x] 5.1 Update CloudFront module version

    - Change version from "3.4.1" to "6.0.2"
    - Preserve existing section header comment
    - _Requirements: 6.1, 13.1_

  - [x] 5.2 Update origin configuration

    - Remove deprecated SSL protocols (TLSv1, TLSv1.1, SSLv3)
    - Keep only TLSv1.2 in origin_ssl_protocols
    - _Requirements: 6.2, 8.1, 8.3_

  - [x] 5.3 Update default_cache_behavior

    - Remove use_forwarded_values parameter
    - Remove query_string parameter
    - Keep cache_policy_name and origin_request_policy_name
    - _Requirements: 6.2, 6.3_

  - [x] 5.4 Update viewer_certificate syntax

    - Change colon syntax to equals for minimum_protocol_version and ssl_support_method
    - _Requirements: 6.3_

  - [x] 5.5 Validate CloudFront configuration
    - Run `terraform validate`
    - _Requirements: 6.2_

- [x] 6. Update API Gateway Module

  - [x] 6.1 Update API Gateway module version

    - Change version from "5.2.1" to "6.0.0"
    - Preserve existing section header comment
    - _Requirements: 7.1, 13.1_

  - [x] 6.2 Validate API Gateway configuration
    - Run `terraform validate`
    - _Requirements: 7.2, 7.3_

- [x] 7. Checkpoint - Validate all module updates

  - Run `terraform init -upgrade` to ensure all modules downloaded
  - Run `terraform validate` to verify configuration
  - Run `terraform plan` and review for unexpected changes
  - Ensure all tests pass, ask the user if questions arise
  - _Requirements: 12.1, 12.2, 12.4_

- [x] 8. Add Variable Validations

  - [ ] 8.1 Add validation to region variable

    - Add regex validation for AWS region format
    - _Requirements: 10.1_

  - [ ] 8.2 Add validation to domain_name variable

    - Add regex validation for domain format
    - _Requirements: 10.2_

  - [ ] 8.3 Add validation to api_domain_prefix variable

    - Add regex validation for subdomain format
    - _Requirements: 10.3_

  - [x] 8.4 Test variable validations
    - Verify invalid inputs are rejected with descriptive errors
    - _Requirements: 10.1, 10.2, 10.3_

- [x] 9. Add New Outputs

  - [x] 9.1 Add CloudFront distribution outputs

    - Add cloudfront_distribution_id output
    - Add cloudfront_distribution_domain_name output
    - _Requirements: 9.1, 9.2_

  - [x] 9.2 Add API Gateway endpoint output

    - Add api_gateway_endpoint output
    - _Requirements: 9.3_

  - [x] 9.3 Add Route53 nameservers output

    - Add route53_zone_nameservers output
    - _Requirements: 9.4_

  - [x] 9.4 Validate outputs configuration
    - Run `terraform validate`
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 10. Update README Documentation

  - [x] 10.1 Add version table to README

    - Include current provider and module versions
    - _Requirements: 11.1_

  - [x] 10.2 Update variables documentation

    - Document all required and optional variables with defaults
    - Fix incorrect path reference (./terraform/variables.tf → ./variables.tf)
    - _Requirements: 11.2, 11.4_

  - [x] 10.3 Add troubleshooting section
    - Include common issues and solutions
    - _Requirements: 11.3_

- [ ] 11. Final Checkpoint - Complete Validation
  - Run full `terraform init` → `validate` → `plan` cycle
  - Review plan output for any unexpected changes
  - Verify all outputs are defined correctly
  - Ensure all tests pass, ask the user if questions arise
  - _Requirements: 12.1, 12.2, 12.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- The CloudFront module update (Task 5) has the most breaking changes and requires careful attention
- Always run `terraform plan` before `terraform apply` to review changes
