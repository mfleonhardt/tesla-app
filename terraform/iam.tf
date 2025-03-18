data "aws_iam_policy_document" "tesla_app" {
    provider = aws.us-west-1
    statement {
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }

        actions = ["s3:GetObject"]

        resources = [
            "${aws_s3_bucket.tesla_app.arn}/*",
            aws_s3_bucket.tesla_app.arn
        ]

        condition {
            test = "StringEquals"
            variable = "aws:SourceArn"
            values = [aws_cloudfront_distribution.tesla_app_distribution.arn]
        }
    }
}