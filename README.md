# Secure static web hosting with S3, CloudFront, ACM, and Route 53
A module to create the infrastructure for secure static hosting in AWS. The ideal form of this module is that you give it a domain and it creates everything needed, leaving you with an S3 bucket to put your static files in. Minimal configuration intended; opinionated defaults.

## Notes
* `domain_name` must be an existing public (authoritative) Route 53 zone in your AWS account
* first `terraform apply` may fail due to slow validation of DNS records for ACM; have to run a second `apply` after validation completes
* you'll want (need) to put your content in the S3 bucket before attempting to load the domain via CloudFront, or else the first attempt will cache an error and you'll need to do an invalidation
