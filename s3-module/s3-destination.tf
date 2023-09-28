resource "aws_s3_bucket" "destination" {
  provider = aws.dest
  bucket = "tf-bucket-destination-12345"
  acl    = "private"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.dest
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

provider "aws" {
  region = var.aws-destination-region
  alias  = "dest"
}