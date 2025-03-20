data "aws_s3_bucket" "logs" {
    provider = aws.us-west-1
    bucket = "mleonhardt-app-logs"
}

# Give CloudFront permission to write to logs bucket
resource "aws_s3_bucket_ownership_controls" "logs" {
    provider = aws.us-west-1
    bucket = data.aws_s3_bucket.logs.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "logs" {
    provider = aws.us-west-1
    depends_on = [aws_s3_bucket_ownership_controls.logs]

    bucket = data.aws_s3_bucket.logs.id
    acl    = "log-delivery-write"
}
