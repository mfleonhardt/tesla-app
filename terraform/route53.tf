data "aws_route53_zone" "mlcodes" {
    provider = aws.us-west-1
    name = "mattleonhardt.codes"
}

# We're not creating validation records as they already exist in Route53

resource "aws_route53_record" "tesla_app" {
    provider = aws.us-west-1
    zone_id = data.aws_route53_zone.mlcodes.zone_id
    name = "tesla.mattleonhardt.codes"
    type = "A"
    alias {
        name = aws_cloudfront_distribution.tesla_app_distribution.domain_name
        zone_id = aws_cloudfront_distribution.tesla_app_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}

resource "aws_route53_record" "tesla_callback" {
    provider = aws.us-west-1
    zone_id = data.aws_route53_zone.mlcodes.zone_id
    name = "tesla-api.mattleonhardt.codes"
    type = "A"
    alias {
        name = aws_cloudfront_distribution.tesla_callback_distribution.domain_name
        zone_id = aws_cloudfront_distribution.tesla_callback_distribution.hosted_zone_id
        evaluate_target_health = false
    }
}
