resource "aws_acm_certificate" "tesla_app" {
    provider = aws.us-east-1
    domain_name = "mattleonhardt.codes"
    subject_alternative_names = ["*.mattleonhardt.codes"]
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "tesla_app" {
    provider = aws.us-east-1
    certificate_arn = aws_acm_certificate.tesla_app.arn
    validation_record_fqdns = ["_11dfaee928779fafa562ccfc0fe306be.mattleonhardt.codes."]
}
