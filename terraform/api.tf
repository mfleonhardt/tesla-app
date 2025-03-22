resource "aws_apigatewayv2_api" "tesla_callback" {
    provider = aws.us-west-1
    name = "tesla-callback"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "tesla_callback" {
    provider = aws.us-west-1
    api_id = aws_apigatewayv2_api.tesla_callback.id

    name = "$default"
    auto_deploy = true

    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.tesla_callback_api.arn
        format = jsonencode({
            requestId = "$context.requestId"
            sourceIp = "$context.identity.sourceIp"
            requestTime = "$context.requestTime"
            protocol = "$context.protocol"
            httpMethod = "$context.httpMethod"
            resourcePath = "$context.resourcePath"
            routeKey = "$context.routeKey"
            status = "$context.status"
            responseLength = "$context.responseLength"
            integrationErrorMessage = "$context.integrationErrorMessage"
        })
    }
}

resource "aws_apigatewayv2_integration" "tesla_callback" {
    provider = aws.us-west-1
    api_id = aws_apigatewayv2_api.tesla_callback.id

    integration_uri = aws_lambda_function.tesla_callback_fn.invoke_arn
    integration_type = "AWS_PROXY"
    integration_method = "POST"
}

resource "aws_apigatewayv2_route" "tesla_callback" {
    provider = aws.us-west-1
    api_id = aws_apigatewayv2_api.tesla_callback.id

    route_key = "GET /tesla-app/auth/callback"
    target = "integrations/${aws_apigatewayv2_integration.tesla_callback.id}"
}
