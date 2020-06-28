variable "domain_name" {
  type        = string
  description = "The fully qualified domain name to set up static hosting for."
}

variable "index_document" {
  type        = string
  default     = "index.html"
  description = "The name of the S3 object you want to return when an end user requests the root URL."
}

variable "error_document" {
  type        = string
  default     = "404.html"
  description = "The name of the S3 object you want to return for 4XX class errors."
}

variable "redirect_destination" {
  type        = string
  default     = null
  description = "This sets the domain to do https redirects. The value should be a URL, such as https://example.com."
}

locals {
  domain_elements = split(".", var.domain_name)
  zone_name       = length(local.domain_elements) == 2 ? "${var.domain_name}." : "${local.domain_elements[length(local.domain_elements) - 2]}.${local.domain_elements[length(local.domain_elements) - 1]}."
}
