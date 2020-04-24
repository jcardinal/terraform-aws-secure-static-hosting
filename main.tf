resource "aws_s3_bucket" "bucket" {
  bucket = var.domain_name
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${var.domain_name}/*"]
    }
  ]
}
POLICY

  website {
    index_document = var.index_document
    error_document = var.error_document
  }
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.domain_name}"
  acl    = "public-read"

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "domain_validation" {
  zone_id = data.aws_route53_zone.zone.zone_id
  type    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_type
  name    = aws_acm_certificate.certificate.domain_validation_options[0].resource_record_name
  records = [aws_acm_certificate.certificate.domain_validation_options[0].resource_record_value]
  ttl     = "600"
}

resource "aws_route53_record" "www_domain_validation" {
  zone_id = data.aws_route53_zone.zone.zone_id
  type    = aws_acm_certificate.certificate.domain_validation_options[1].resource_record_type
  name    = aws_acm_certificate.certificate.domain_validation_options[1].resource_record_name
  records = [aws_acm_certificate.certificate.domain_validation_options[1].resource_record_value]
  ttl     = "600"
}

resource "aws_cloudfront_distribution" "distribution" {
  aliases         = [var.domain_name]
  price_class     = "PriceClass_100"
  comment         = var.domain_name
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.bucket.website_endpoint
    origin_id   = "S3-Website-Endpoint-${aws_s3_bucket.bucket.website_endpoint}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website-Endpoint-${var.domain_name}.s3-website-us-east-1.amazonaws.com"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "www_distribution" {
  aliases         = ["www.${var.domain_name}"]
  price_class     = "PriceClass_100"
  comment         = "www.${var.domain_name}"
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.www_bucket.website_endpoint
    origin_id   = "S3-Website-Endpoint-${aws_s3_bucket.www_bucket.website_endpoint}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website-Endpoint-www.${var.domain_name}.s3-website-us-east-1.amazonaws.com"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "zone" {
  name = "${var.domain_name}."
}

resource "aws_route53_record" "domain_a" {
  zone_id = data.aws_route53_zone.zone.zone_id
  type    = "A"
  name    = var.domain_name

  alias {
    name                   = "${aws_cloudfront_distribution.distribution.domain_name}."
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_domain_a" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${var.domain_name}."
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.www_distribution.domain_name}."
    zone_id                = aws_cloudfront_distribution.www_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
