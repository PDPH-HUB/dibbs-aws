resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.project}-tfstate-${var.owner}-${var.identifier}"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://avd.aquasec.com/misconfig/aws/s3/avd-aws-0132/
# trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.tfstate.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "default" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.tfstate_logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

#checkov:skip=CKV_AWS_18:access-log destination bucket
resource "aws_s3_bucket" "tfstate_logs" {
  bucket = "${var.project}-tfstate-${var.owner}-${var.identifier}-logs"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tfstate_logs" {
  bucket = aws_s3_bucket.tfstate_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create a DynamoDB table for locking the state file
resource "aws_dynamodb_table" "tfstate_lock" {
  name         = "${var.project}-tfstate-lock-${var.owner}-${var.identifier}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
