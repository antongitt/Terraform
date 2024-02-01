# aws/mario
To apply the configuration, run the following commands:
```bash
git clone https://github.com/antongitt/Terraform.git
cd Terraform/aws/mario
sudo chmod +x script.sh
```

# aws/backend
Terraform configuration sets up an S3 bucket, a DynamoDB table, and the required IAM roles and policies for a Terraform backend on AWS. Additionally, it creates the backend file in a format for S3 backend configuration https://developer.hashicorp.com/terraform/language/settings/backends/s3

This configuration uses provisioned throughput for DynamoDB with low values that fall within the AWS Free Tier limits. The AWS Free Tier provides 25 read capacity units and 25 write capacity units per month for DynamoDB. Ensure that you review the AWS Free Tier limits to stay within the free tier usage.

Before applying this configuration, make sure that you have the AWS CLI configured with the necessary credentials.

To stage the configuration, run the following commands:
```bash
git clone https://github.com/antongitt/Terraform.git
cd Terraform/aws/backend/
```

The configuration requres the ```terraform.tfvars``` file with ```project_name``` and ```aws_region``` variables, which can be set via CLI:
```bash
echo 'project_name = "mario"' > terraform.tfvars
echo 'aws_region   = "us-east-1"' >> terraform.tfvars
```

To apply the configuration, run the following commands:
```terraform
terraform init
terraform apply -auto-approve
```
When you apply this Terraform configuration, it will create or modify the ```../${var.project_name}/backend.tf``` file. The file will contain the generated Terraform backend configuration based on the values of the specified resources and variables.
