resource "aws_cloudwatch_log_group" "tesla_callback_fn" {
    name = "/aws/lambda/tesla-callback-fn"

    retention_in_days = 30
}

