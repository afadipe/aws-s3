resource "aws_s3_bucket" "destination" {
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_19:Ensure all data stored in the S3 bucket is securely encrypted at rest
  #checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  provider = aws.dest
  bucket = "tf-bucket-destination-12345"
}

resource "aws_s3_bucket" "dest_log_bucket" {
  bucket = "dest-tf-log-bucket"
   lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "dest_log_bucket_acl" {
  bucket = aws_s3_bucket.dest_log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "dest_bucket_logging" {
  #checkov:skip=CKV_AWS_18:Ensure the S3 bucket has access logging enabled
  #checkov:skip=CKV_AWS_19:Ensure all data stored in the S3 bucket is securely encrypted at rest
  #checkov:skip=CKV_AWS_21:Ensure all data stored in the S3 bucket have versioning enabled
  bucket = aws_s3_bucket.destination.id
  target_bucket = aws_s3_bucket.dest_log_bucket.id
  target_prefix = "log/"
}


resource "aws_s3_bucket_acl" "destination_acl" {
  bucket = aws_s3_bucket.destination.id
  acl    = "private"
}

#3. block public access
resource "aws_s3_bucket_public_access_block" "dest_public_access" {
  bucket                  = aws_s3_bucket.destination.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "destination_versioning" {
  provider = aws.dest
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

#5. bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "dest_bucket_encrypt_config" {
  bucket = aws_s3_bucket.destination.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

provider "aws" {
  region = var.aws-destination-region
  alias  = "dest"
}