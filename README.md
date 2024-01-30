# aws/backend
Terraform configuration sets up an S3 bucket, a DynamoDB table, and the required IAM roles and policies for a Terraform backend on AWS. Additionally, it defines an output to display the S3 bucket information in a format for S3 backend configuration https://developer.hashicorp.com/terraform/language/settings/backends/s3

This configuration uses provisioned throughput for DynamoDB with low values that fall within the AWS Free Tier limits. The AWS Free Tier provides 25 read capacity units and 25 write capacity units per month for DynamoDB. Ensure that you review the AWS Free Tier limits to stay within the free tier usage.
