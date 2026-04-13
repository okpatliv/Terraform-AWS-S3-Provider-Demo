variable "aws_region" {
  description = "AWS-Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name des S3-Buckets"
  type        = string
}

variable "bucket_tags" {
  description = "Tags für den S3-Bucket"
  type        = map(string)
  default = {
    project = "terraform-demo"
    owner   = "demo"
  }
}