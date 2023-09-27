# s3 bucket for terraform backend
resource "aws_s3_bucket" "backend" {
  count  = var.create_vpc ? 1 : 0
  bucket = "devopsbootcamp32-${lower(var.env)}-${random_integer.priority.result}"
  tags = {
    Name        = "My s3 backend"
    Environment = "Dev-Test"
  }
}

# kms key for bucket encryption
resource "aws_kms_key" "my_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

#bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt_config" {
  bucket = aws_s3_bucket.backend[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#bucket versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.backend[0].id
  versioning_configuration {
    status = var.versioning
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
