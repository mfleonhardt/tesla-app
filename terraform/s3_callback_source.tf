resource "aws_s3_bucket" "tesla_callback_fn" {
    provider = aws.us-west-1
    bucket = "tesla-callback-fn-${random_id.tesla_app_suffix.hex}"

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "tesla_callback_fn" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_callback_fn.id
    versioning_configuration {
        status = "Disabled" # Intentional. This bucket will be deployed to from version control
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tesla_callback_fn" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_callback_fn.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "tesla_callback_fn" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_callback_fn.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true

    lifecycle {
        prevent_destroy = true
    }
}

data "archive_file" "tesla_callback_fn" {
    type = "zip"
    source_dir = "${path.root}/../build/auth-callback"
    output_path = "${path.root}/../build/auth-callback.zip"
}

resource "aws_s3_object" "tesla_callback_fn" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_callback_fn.id
    key = "auth-callback.zip"
    source = data.archive_file.tesla_callback_fn.output_path

    etag = filemd5(data.archive_file.tesla_callback_fn.output_path)
}
