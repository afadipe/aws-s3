# s3 bucket for terraform backend
resource "aws_s3_bucket" "source_bucket" {
  bucket = "devopsbootcamp32-${lower(var.env)}-${random_integer.priority.result}"
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name        = "My s3 backend"
    Environment = "Dev-Test"
  }
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "mylearning-345-tf-log-bucket"
   lifecycle {
    prevent_destroy = true
  }
  acl    = "private"
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

#2. create s3 bucket acl
resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.source_bucket.id
  acl    = "private"
}

#3. block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.source_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#4. kms key for bucket encryption
resource "aws_kms_key" "my_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

#5. bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt_config" {
  bucket = aws_s3_bucket.source_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#6. bucket versioning
resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Random integer for bucket naming convention
resource "random_integer" "priority" {
  min = 1
  max = 5000
  keepers = {
    Environment = var.env
  }
}

## configuring replication

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.source_versioning]
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source_bucket.id
  rule {
    id     = "tf-s3-replication-rule"
    status = "Enabled"
    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
      access_control_translation {
        owner = "Destination"
      }
    }
    source_selection_criteria {
      sse_kms_encrypted_objects {
        enabled = false
      }
    }

  }
}