# Secure static web hosting with AWS

This module quickly creates everything you need for secure static hosting in AWS. A simple, low-traffic site will cost less than $1/mo. Use it to host a static site, run a CDN, or act as a domain-wide redirect that supports HTTPS. Run this module, put your files in the S3 bucket, and you're live. It uses S3, CloudFront, ACM, and Route 53, but you don't need to worry about any of that if you don't want to.

Minimal configuration intended; opinionated defaults.

## Prerequisites

1. A [Route 53 zone](https://console.aws.amazon.com/route53/home#hosted-zones:) for your domain
2. A registered domain using the nameservers for the Route 53 zone above
3. [Terraform](https://www.terraform.io/) (`brew install terraform`)
4. AWS API key [accessible to terraform](https://www.terraform.io/docs/providers/aws/index.html#authentication)

## Examples

#### Create secure static hosting for an apex domain

```
module "example_com" {
  source      = "github.com/jcardinal/terraform-aws-secure-static-hosting"
  domain_name = "example.com"
}
```

#### Create https-enabled website redirect for a www subdomain

```
module "www_example_com" {
  source               = "github.com/jcardinal/terraform-aws-secure-static-hosting"
  domain_name          = "www.example.com"
  redirect_destination = "https://example.com"
}
```

#### Putting it all together

A complete terraform configuration, including provider definition, static hosting on an apex domain, and a redirect from the www subdomain to the apex domain

```
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

module "example_com" {
  source      = "github.com/jcardinal/terraform-aws-secure-static-hosting"
  domain_name = "example.com"
}

module "www_example_com" {
  source               = "github.com/jcardinal/terraform-aws-secure-static-hosting"
  domain_name          = "www.example.com"
  redirect_destination = "https://example.com"
}
```

## Notes

- this module assumes your homepage is `index.html` and error pages should serve `404.html`. If you need to modify this, use `index_document = "your_index_file.html"` and `error_document = "your_error_file.html"` in your module call
- If you don't put your content in the S3 bucket before attempting to load your site, CloudFront will cache the error and you'll have to do an invalidation after your files are loaded to get the site loading
