resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name

  tags = var.bucket_tags
}