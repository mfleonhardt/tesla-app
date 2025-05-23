resource "aws_lambda_function" "tesla_callback_fn" {
    provider = aws.us-west-1
    function_name = "tesla-callback-fn"

    s3_bucket = aws_s3_bucket.tesla_callback_fn.id
    s3_key = aws_s3_object.tesla_callback_fn.key

    runtime = "nodejs22.x"
    handler = "callback.handler"

    source_code_hash = data.archive_file.tesla_callback_fn.output_base64sha256

    role = aws_iam_role.lambda_exec.arn

    environment {
        variables = {
            TESLA_CLIENT_ID = var.tesla_client_id
            TESLA_CLIENT_SECRET = var.tesla_client_secret
            TESLA_REDIRECT_URI = "https://${var.tesla_callback_subdomain}/auth/callback"
            COOKIE_DOMAIN = ".${var.root_domain}"
        }
    }
}

resource "aws_lambda_permission" "tesla_callback_fn" {
    provider = aws.us-west-1
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.tesla_callback_fn.function_name
    principal = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.tesla_callback.execution_arn}/$default/GET/auth/callback"
}
