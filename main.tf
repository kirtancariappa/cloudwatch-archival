provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "log_archive" {
  bucket = "cw-log-archive-prod"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_archive.id

  rule {
    id     = "log-archive-transition"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      expired_object_delete_marker = false
    }
  }
}
