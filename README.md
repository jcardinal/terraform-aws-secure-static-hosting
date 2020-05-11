# Secure static web hosting with AWS
A module to create the infrastructure for secure static hosting in AWS, using S3, CloudFront, ACM, and Route 53.

The intended use of this module is that you give it a domain and it creates everything needed, leaving you with an S3 bucket to put your static files in. Minimal configuration intended; opinionated defaults.

## Notes
* The apex domain portion of `domain_name` must be an existing public (authoritative) Route 53 zone in your AWS account. While this module could conceivably create the zone for you, it's not able to update the nameservers for the registered domain, so our ACM certificate validation would still fail. Register your domain, create the Route 53 zone for it, set the nameservers for the domain to those provided by the Route 53 zone, then use this module to create secure static hosting.
* you'll want (need) to put your content in the S3 bucket before attempting to load the domain via CloudFront, or else the first attempt will cache an error and you'll need to do an invalidation

## Examples
Create secure static hosting for an apex domain
```
module "example_com" {
  source      = "app.terraform.io/uptime/secure-static-hosting/aws"
  domain_name = "example.com"
}
```

Create https-enabled website redirect for a www subdomain
```
module "www_example_com" {
  source               = "app.terraform.io/uptime/secure-static-hosting/aws"
  domain_name          = "www.example.com"
  redirect_destination = "https://example.com"
}
```
