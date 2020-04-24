variable "AWS_REGION" {
  default = "us-east-1"
}

variable "domain_name" {
  type = string
}

# variable "www_redirect" {
#   type    = bool
#   default = false
# }

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document" {
  type    = string
  default = "404.html"
}