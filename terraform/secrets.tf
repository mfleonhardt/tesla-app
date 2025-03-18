resource "aws_secretsmanager_secret" "tesla_app" {
    provider = aws.us-west-1
    name = "tesla-app-private-key"
}

resource "aws_secretsmanager_secret_version" "tesla_app" {
    provider = aws.us-west-1
    secret_id = aws_secretsmanager_secret.tesla_app.id
    secret_string = tls_private_key.tesla_app.private_key_pem
}
