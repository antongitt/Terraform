terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "tf-state-${data.aws_caller_identity.current.account_id}-${var.region}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = "terraform-lock-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
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
  bucket = aws_s3_bucket.terraform_state.bucket

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
      "Resource": "${aws_s3_bucket.terraform_state.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.terraform_state.arn}/*",
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

resource "local_file" "backend_tf" {
  filename        = "../${var.project}/backend.tf"
  file_permission = "0644"
  content         = <<EOT
terraform {
  backend "s3" {
    bucket         = "${aws_s3_bucket.terraform_state.id}"
    key            = "projects/${var.project}/.tfstate"
    region         = "${var.region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_lock_table.name}"
  }
}
EOT
}
