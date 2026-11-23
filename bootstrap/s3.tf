resource "aws_s3_bucket" "atlas_platform" {
  bucket = "atlas-platform-${data.aws_caller_identity.current.account_id}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "atlas_platform" {
  bucket = aws_s3_bucket.atlas_platform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "atlas_platform" {
  bucket = aws_s3_bucket.atlas_platform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "atlas_platform" {
  bucket = aws_s3_bucket.atlas_platform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}