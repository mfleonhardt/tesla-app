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

resource "aws_iam_role" "lambda_exec" {
    provider = aws.us-west-1
    name = "lambda_exec"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
    provider = aws.us-west-1
    role = aws_iam_role.lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
    provider = aws.us-west-1
    name = "lambda_s3_policy"
    role = aws_iam_role.lambda_exec.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    aws_s3_bucket.tesla_callback_fn.arn,
                    "${aws_s3_bucket.tesla_callback_fn.arn}/*"
                ]
            }
        ]
    })
}
