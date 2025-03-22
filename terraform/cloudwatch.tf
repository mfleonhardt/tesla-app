resource "aws_cloudwatch_log_group" "tesla_callback_fn" {
    provider = aws.us-west-1
    name = "/aws/lambda/tesla-callback-fn"

    retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "tesla_callback_api" {
    provider = aws.us-west-1
    name = "/aws/apigateway/tesla-callback-api"

    retention_in_days = 30
}