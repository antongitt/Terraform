variable "aws_region" {
  description = "The AWS region where resources will be created."
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing Terraform state."
}

variable "s3_key" {
  description = "The key/path for storing the Terraform state file in the S3 bucket."
}
