# aws/backend
Terraform configuration sets up an S3 bucket, a DynamoDB table, and the required IAM roles and policies for a Terraform backend on AWS. Additionally, it defines an output to display the S3 bucket information in a format for S3 backend configuration https://developer.hashicorp.com/terraform/language/settings/backends/s3

This configuration uses provisioned throughput for DynamoDB with low values that fall within the AWS Free Tier limits. The AWS Free Tier provides 25 read capacity units and 25 write capacity units per month for DynamoDB. Ensure that you review the AWS Free Tier limits to stay within the free tier usage.

Before applying this configuration, make sure that you have the AWS CLI configured with the necessary credentials.

To apply the configuration, run the following commands:
```
terraform init
terraform apply
```
During the terraform apply process, Terraform will prompt you to confirm the changes. Type yes and press Enter to proceed.

Once applied, you can retrieve the Terraform backend S3 information using:
```
terraform output terraform_backend_s3
```
This will display the S3 bucket information, including the bucket name, key, region, and DynamoDB table name.
