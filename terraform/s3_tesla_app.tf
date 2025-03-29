resource "aws_s3_bucket" "tesla_app" {
    provider = aws.us-west-1
    bucket = "tesla-app-${random_id.tesla_app_suffix.hex}"

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_policy" "tesla_app" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id
    policy = data.aws_iam_policy_document.tesla_app.json
}

resource "aws_s3_bucket_versioning" "tesla_app" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id
    versioning_configuration {
        status = "Disabled" # Intentional. This bucket will be deployed to from version control
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tesla_app" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_bucket_public_access_block" "tesla_app" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_object" "public_key" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id
    key = ".well-known/appspecific/com.tesla.3p.public-key.pem"
    content = tls_private_key.tesla_app.public_key_pem
    content_type = "text/plain"
    cache_control = "max-age=86400"
}

resource "aws_s3_object" "tesla_app" {
    provider = aws.us-west-1
    bucket = aws_s3_bucket.tesla_app.id
    for_each = fileset("${path.root}/../app/dist", "**/*")
    key = each.value
    source = "${path.root}/../app/dist/${each.value}"
    etag = filemd5("${path.root}/../app/dist/${each.value}")
    content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "application/octet-stream")
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain"
    ".pdf"  = "application/pdf"
  }
}
