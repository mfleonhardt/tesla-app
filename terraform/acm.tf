resource "aws_acm_certificate" "tesla_app" {
    provider = aws.us-east-1
    domain_name = var.root_domain
    subject_alternative_names = ["*.${var.root_domain}"]
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_acm_certificate_validation" "tesla_app" {
    provider = aws.us-east-1
    certificate_arn = aws_acm_certificate.tesla_app.arn
    validation_record_fqdns = ["_11dfaee928779fafa562ccfc0fe306be.${var.root_domain}."]
}
