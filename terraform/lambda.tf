resource "aws_lambda_function" "tesla_callback_fn" {
    provider = aws.us-west-1
    function_name = "tesla-callback-fn"

    s3_bucket = aws_s3_bucket.tesla_callback_fn.id
    s3_key = aws_s3_object.tesla_callback_fn.key

    runtime = "nodejs22.x"
    handler = "callback.handler"

    source_code_hash = data.archive_file.tesla_callback_fn.output_base64sha256

    role = aws_iam_role.lambda_exec.arn
}


