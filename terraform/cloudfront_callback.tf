resource "aws_cloudfront_cache_policy" "tesla_callback" {
  provider = aws.us-east-1
  name     = "tesla-callback"
  min_ttl  = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_distribution" "tesla_callback_distribution" {
  provider = aws.us-east-1
  origin {
    domain_name = "${aws_apigatewayv2_api.tesla_callback.id}.execute-api.us-west-1.amazonaws.com"
    origin_id   = aws_apigatewayv2_api.tesla_callback.id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  aliases         = [var.tesla_callback_subdomain]
  price_class     = "PriceClass_100"

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_apigatewayv2_api.tesla_callback.id

    cache_policy_id            = aws_cloudfront_cache_policy.tesla_callback.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    viewer_protocol_policy     = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.tesla_app.arn
    ssl_support_method  = "sni-only"
  }

  logging_config {
    bucket          = "${data.aws_s3_bucket.logs.bucket}.s3.amazonaws.com"
    include_cookies = false
    prefix          = "tesla-app/cloudfront-callback/"
  }
}
