terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket
  enabled = true
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  billing_mode = "PROVISIONED"

  attribute {
    name = "LockID"
    type = "S"
  }

  provisioned_throughput {
    read_capacity  = 5
    write_capacity = 5
  }
}

resource "aws_iam_role" "terraform_backend_role" {
  name = "terraform-backend-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform_backend_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.terraform_backend_role.name
}

resource "aws_s3_bucket_policy" "terraform_backend_policy" {
  bucket = aws_s3_bucket.terraform_state_bucket.bucket

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "dynamodb.amazonaws.com"
      },
      "Action": "s3:GetBucketVersioning",
      "Resource": "${aws_s3_bucket.terraform_state_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.terraform_state_bucket.arn}/*",
      "Condition": {
        "StringEquals": {
          "aws:PrincipalARN": "${aws_iam_role.terraform_backend_role.arn}"
        }
      }
    }
  ]
}
EOF
}

output "terraform_backend_s3" {
  value = {
    bucket         = aws_s3_bucket.terraform_state_bucket.bucket
    key            = var.s3_key
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_lock_table.name
  }
}


