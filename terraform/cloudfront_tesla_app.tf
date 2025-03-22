locals {
    bucket_origin_id = "S3-${aws_s3_bucket.tesla_app.bucket}"
}

resource "aws_cloudfront_origin_access_control" "tesla_app" {
    provider = aws.us-east-1
    name = "tesla-app"
    description = "Origin Access Control for Tesla App"
    signing_behavior = "always"
    signing_protocol = "sigv4"
    origin_access_control_origin_type = "s3"
}

resource "aws_cloudfront_cache_policy" "tesla_app" {
    provider = aws.us-east-1
    name = "tesla-app"
    min_ttl = 1
    parameters_in_cache_key_and_forwarded_to_origin {
        cookies_config {
            cookie_behavior = "none"
        }
        headers_config {
            header_behavior = "none"
        }
        query_strings_config {
            query_string_behavior = "none"
        }
    }
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
    provider = aws.us-east-1
    name = "tesla-app-security-headers"

  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self'; img-src 'self' data:; script-src 'self'; style-src 'self'; font-src 'self'; object-src 'none'; connect-src 'self' https://*.tesla.com"
      override = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override = true
    }

    strict_transport_security {
      access_control_max_age_sec = 63072000 # 2 years
      include_subdomains = true
      preload = true
      override = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "tesla_app_distribution" {
    provider = aws.us-east-1
    origin {
        domain_name = aws_s3_bucket.tesla_app.bucket_regional_domain_name
        origin_id = local.bucket_origin_id
        origin_access_control_id = aws_cloudfront_origin_access_control.tesla_app.id
    }

    enabled = true
    is_ipv6_enabled = true
    default_root_object = "index.html"
    aliases = [var.tesla_app_subdomain]
    price_class = "PriceClass_100"

    restrictions {
        geo_restriction {
            locations = []
            restriction_type = "none"
        }
    }

    default_cache_behavior {
        allowed_methods = ["HEAD", "GET", "OPTIONS"]
        cached_methods = ["HEAD", "GET", "OPTIONS"]
        cache_policy_id = aws_cloudfront_cache_policy.tesla_app.id
        target_origin_id = local.bucket_origin_id
        viewer_protocol_policy = "redirect-to-https"
        response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    }

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.tesla_app.arn
        ssl_support_method = "sni-only"
    }

    custom_error_response {
        error_code = 403
        response_code = 200
        response_page_path = "/index.html"
    }

    custom_error_response {
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
    }

    logging_config {
        bucket = "${data.aws_s3_bucket.logs.bucket}.s3.amazonaws.com"
        include_cookies = false
        prefix = "tesla-app/cloudfront/"
    }
}
